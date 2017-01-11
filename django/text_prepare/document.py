"""Module containing the Document class."""

import os.path
import re
import shlex
import subprocess
import tempfile
import textwrap
import unicodedata

import pyparsing as pp
from lxml import etree

from .document_parser import DocumentParser
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
REMOVE_AB_XSLT_PATH = os.path.join(XSLT_DIR, 'remove_ab.xsl')

TEI_SKELETON = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:base="tei/records/">
  <text>
    <group>{}</group>
  </text>
</TEI>'''


class Document:

    """Represents a Word document and provides methods to validate its
    contents and convert it into TEI XML."""

    # The env argument allows for the command to run (and work) while
    # an interactive instance of LibreOffice is open.
    convert_command = '''soffice -env:UserInstallation=file://{} --headless
                         --cat {}'''

    def __init__(self, base_id=''):
        self._base_id = base_id

    def convert(self, word_file_path, line_length, doc_descs_file_path):
        """Returns the content of the supplied Word document converted into
        TEI XML, along with a possibly updated version of the supplied
        document descriptions TEI XML file.

        :param word_file_path: path to Word file to be converted
        :type file_path: `str`
        :param line_length: number of characters to wrap lines to
        :type line_length: `int`
        :param doc_descs_file_path: path to TEI XML file containing
                                    document descriptions
        :type doc_descs_file_path: `str`
        :rtype: `str`

        """
        text = self._get_text(word_file_path, line_length)
        results = self._validate(text)
        return self._convert(results)

    def _convert(self, results):
        text = TEI_SKELETON.format(''.join(results))
        text = unicodedata.normalize('NFC', text)
        text = self._postprocess_text(text)
        # Do some cosmetic changes that are too hard to do with XSLT
        # 1. This is rather dirty!
        text = re.sub(r'(<ab[^>]*>)[ \t\n\r\f\v]+', r'\1', text)
        text = re.sub(r'[ \t\n\r\f\v]+(</ab>)', r'\1', text)
        return text.encode('utf-8')

    def _get_text(self, file_path, line_length):
        """Returns the plain text conversion of the file at `file_path`.

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

    def _postprocess_text(self, text):
        """Returns `text` modified by applying various XSLT transformations to
        it.

        :param text: TEI XML to post-process
        :type text: `str`
        :rtype: `str`

        """
        tree = etree.ElementTree(etree.fromstring(text))
        tree = self._transform(tree, ADD_AB_XSLT_PATH, ADD_ID_XSLT_PATH,
                               ADD_HEADER_XSLT_PATH,
                               MASSAGE_FOOTNOTE_XSLT_PATH, REMOVE_AB_XSLT_PATH)
        return etree.tostring(tree, encoding='unicode', pretty_print=True)

    def _transform(self, tree, *xslt_paths):
        for path in xslt_paths:
            transform = etree.XSLT(etree.parse(path))
            tree = transform(tree, base_id="'{}'".format(self._base_id))
        return tree

    def validate(self, word_file_path, line_length):
        """Raises an exception if this document does not conform to the @-code
        grammar."""
        text = self._get_text(word_file_path, line_length)
        self._validate(text)

    def _validate(self, text):
        """Returns `text` converted into TEI XML according to the rules
        attached to the @-code grammar. This conversion raises an
        exception if `text` does not conform to the grammar.

        :param text: textual content to be converted
        :type text: `str`
        :rtype: `str`

        """
        parser = DocumentParser()
        try:
            results = parser.parse(text)
        except (pp.ParseException, pp.ParseSyntaxException,
                pp.ParseFatalException) as e:
            # Generate the context of the error, with a pointer to the
            # column identified as its place.
            col = e.column
            line = e.line
            line_number = e.lineno
            line_index = e.lineno - 1
            split_text = text.splitlines()
            lines = []
            lines.append('Line: {}'.format(line_number))
            lines.append('Message: {}\n'.format(e))
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

    def _wrap_text(self, text, line_length):
        """Returns `text` wrapped to the specified line `length`.

        :param text: text to wrap
        :type text: `str`
        :param line_length: length of line to wrap `text` to
        :type line_length: `int`
        :rtype: `str`

        """
        # Due to slight differences in how Word and textwrap wrap
        # lines, it can happen that a closing @-code (eg, "@f \") is
        # split over two lines on the whitespace, which breaks the
        # parsing of this element. Therefore hack around this.
        text = text.replace(' \\', '豈\\')
        wrapper = textwrap.TextWrapper(width=line_length)
        text = '\n'.join([wrapper.fill(line) for line in text.splitlines()])
        text = text.replace('豈\\', ' \\')
        return text
