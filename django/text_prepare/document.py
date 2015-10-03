import shlex
import subprocess
import tempfile
import unicodedata

import pyparsing as pp

from .document_parser import document_grammar
from .exceptions import (TextPrepareDocumentTextExtractionError,
                         TextPrepareDocumentValidationError)


class Document:

    # The env argument allows for the command to run (and work) while
    # an interactive instance of LibreOffice is open.
    convert_command = '''soffice -env:UserInstallation=file://{} --headless
                         --convert-to txt:Text --cat {}'''

    def __init__ (self, file_path):
        self._file_path = file_path

    def convert (self):
        text = self._get_text(self._file_path)
        results = self._validate(text)
        return self._convert(results)

    def _convert (self, results):
        text = '<TEI>{}</TEI>'.format(''.join(results))
        return unicodedata.normalize('NFC', text)

    def _get_text (self, file_path):
        """Return the plain text conversion of the file at `file_path`.

        The file at `file_path` is converted using LibreOffice, and is
        therefore expected to be in a format that LO can usefully deal
        with.

        :param file_path: path to file to extract text from
        :type file_path: `str`
        :rtype: `str`

        """
        with tempfile.TemporaryDirectory() as env_fh:
            command = self.convert_command.format(env_fh, file_path)
            try:
                text = subprocess.check_output(shlex.split(command))
            except Exception as e:
                # In addition to subprocess.CalledProcessError,
                # FileNotFoundError might be raised (if the command is
                # not available) and quite possibly others. Given that
                # any failure here should be handled and reported in
                # the same way, just catch Exception.
                message = 'Failed to extract text from the document:' \
                          ' {}'.format(e.output)
                raise TextPrepareDocumentTextExtractionError(message)
        return text.decode('utf-8')

    def validate (self):
        text = self._get_text(self._file_path)
        self._validate(text)

    def _validate (self, text):
        try:
            results = document_grammar.parseString(text)
        except pp.ParseException as e:
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
            lines = []
            line_length = 90
            marker_index = 30
            start_index = 0
            end_index = line_length
            prev_line = ''
            if col > marker_index:
                start_index = col - marker_index
                end_index = col + line_length - marker_index
                prev_line = line[start_index-line_length:start_index]
            if prev_line:
                lines.append(prev_line)
            lines.append(line[start_index:end_index])
            lines.append(' ' * (col - start_index) + '^')
            next_line = line[end_index:end_index+line_length]
            if next_line:
                lines.append(next_line)
            message = '\n'.join(lines)
            raise TextPrepareDocumentValidationError(message)
        return results
