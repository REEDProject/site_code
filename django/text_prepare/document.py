import os.path
import re
import shlex
import subprocess
import tempfile
import textwrap
import unicodedata

import pyparsing as pp
from lxml import etree

from .document_parser import document_grammar
from .exceptions import (TextPrepareDocumentTextExtractionError,
                         TextPrepareDocumentValidationError)


# Constants for the number of lines of context to display before and
# after the line on which a validation error occurs.
CONTEXT_LINES_BEFORE = 1
CONTEXT_LINES_AFTER = 2

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
XSLT_DIR = os.path.join(BASE_DIR, 'xslt')
ADD_AB_XSLT_PATH = os.path.join(XSLT_DIR, 'add_ab.xsl')
ADD_HEADER_XSLT_PATH = os.path.join(XSLT_DIR, 'add_header.xsl')
ADD_ID_XSLT_PATH = os.path.join(XSLT_DIR, 'add_id.xsl')
MASSAGE_FOOTNOTE_XSLT_PATH = os.path.join(XSLT_DIR, 'massage_footnote.xsl')

TEI_SKELETON = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:base="tei/records/">
  <text>
    <group>{}</group>
  </text>
</TEI>'''


class Document:

    # The env argument allows for the command to run (and work) while
    # an interactive instance of LibreOffice is open.
    convert_command = '''soffice -env:UserInstallation=file://{} --headless
                         --cat {}'''

    def __init__ (self, file_path, line_length, base_id):
        self._file_path = file_path
        self._line_length = line_length
        self._base_id = base_id

    def convert (self):
        text = self._get_text(self._file_path, self._line_length)
        results = self._validate(text)
        return self._convert(results)

    def _convert (self, results):
        text = TEI_SKELETON.format(''.join(results))
        text = unicodedata.normalize('NFC', text)
        text = self._postprocess_text(text)
        # Do some cosmetic changes that are too hard to do with XSLT
        # 1. This is rather dirty!
        text = re.sub(r'(<ab[^>]*>)[ \t\n\r\f\v]+', r'\1', text)
        text = re.sub(r'[ \t\n\r\f\v]+(</ab>)', r'\1', text)
        return text.encode('utf-8')

    def _get_text (self, file_path, line_length):
        """Return the plain text conversion of the file at `file_path`.

        The file at `file_path` is converted using LibreOffice, and is
        therefore expected to be in a format that LO can usefully deal
        with.

        :param file_path: path to file to extract text from
        :type file_path: `str`
        :param line_length: number of characters to wrap lines to
        :type line_length: `int`
        :rtype: `str`

        """
        with tempfile.TemporaryDirectory() as env_fh:
            command = self.convert_command.format(env_fh, file_path)
            env = {'LC_ALL': 'en_US.UTF-8', 'LANGUAGE': 'en_US.UTF-8'}
            message = 'Failed to extract text from the document: {}'
            try:
                text = subprocess.check_output(shlex.split(command), env=env)
            except subprocess.CalledProcessError as e:
                raise TextPrepareDocumentTextExtractionError(message.format(
                    e.output))
            except Exception as e:
                # In addition to subprocess.CalledProcessError,
                # FileNotFoundError might be raised (if the command is
                # not available) and quite possibly others. Given that
                # any failure here should be handled and reported in
                # the same way, just catch Exception.
                raise TextPrepareDocumentTextExtractionError(message.format(e))
        text = text.decode('utf-8')
        return self._wrap_text(text, line_length)

    def _postprocess_text (self, text):
        tree = etree.ElementTree(etree.fromstring(text))
        tree = self._transform(tree, ADD_AB_XSLT_PATH, ADD_ID_XSLT_PATH,
                               ADD_HEADER_XSLT_PATH, MASSAGE_FOOTNOTE_XSLT_PATH)
        return etree.tostring(tree, encoding='unicode', pretty_print=True)

    def _transform (self, tree, *xslt_paths):
        for path in xslt_paths:
            transform = etree.XSLT(etree.parse(path))
            tree = transform(tree, base_id="'{}'".format(self._base_id))
        return tree

    def validate (self):
        text = self._get_text(self._file_path, self._line_length)
        self._validate(text)

    def _validate (self, text):
        try:
            results = document_grammar.parseString(text)
        except (pp.ParseException, pp.ParseSyntaxException) as e:
            # Generate the context of the error, with a pointer to the
            # column identified as its place, in a way that copes with
            # a "line" potentially being very long.
            #
            # Show up to one line (89 characters) before and after the
            # main line that has the position marker following it.
            #
            # Since many validation errors have the column marked not
            # where the error occurred (according to a human), but at
            # the opening code of the range that contains the error,
            # keep the marker within the first 30 characters of the
            # main line.
            col = e.column
            line = e.line
            line_number = e.lineno
            line_index = e.lineno - 1
            split_text = text.splitlines()
            lines = []
            lines.append('Line: {}\n'.format(line_number))
            if line_number > CONTEXT_LINES_BEFORE:
                lines.extend(split_text[
                    line_index-CONTEXT_LINES_BEFORE:line_index])
            lines.append(line)
            lines.append(' ' * col + '^')
            try:
                lines.extend(split_text[
                    line_index+1:line_index+1+CONTEXT_LINES_AFTER])
            except:
                pass
            message = '\n'.join(lines)
            raise TextPrepareDocumentValidationError(message)
        return results

    def _wrap_text (self, text, line_length):
        """Returns `text` wrapped to the specified line `length`."""
        # Due to slight differences in how Word and textwrap wrap
        # lines, it can happen that a closing @-code (eg, "@f \") is
        # split over two lines on the whitespace, which breaks the
        # parsing of this element. Therefore hack around this.
        text = text.replace(' \\', '豈\\')
        wrapper = textwrap.TextWrapper(width=line_length)
        text = '\n'.join([wrapper.fill(line) for line in text.splitlines()])
        text = text.replace('豈\\', ' \\')
        return text
