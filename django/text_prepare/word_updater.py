import io
import os
import shlex
import subprocess
import tempfile

import docx

from .exceptions import TextPrepareDocumentUpdateError


def convert_at_codes (text):
    codes = ['a', 'b', 'cnx', 'cor', 'cym', 'deu', 'e', 'eng', 'f', 'fra', 'g',
             'gla', 'gmh', 'gml', 'grc', 'i', 'ita', 'j', 'k', 'l', 'lat', 'm',
             'p', 'por', 'q', 'r', 's', 'sn', 'snc', 'snr', 'spa', 'wlm', 'x',
             'xc', 'xno']
    for code in codes:
        text = text.replace('@{} \\'.format(code), '@{}/'.format(code))
    return text

def convert_to_docx (doc_path):
    with tempfile.TemporaryDirectory() as env_fh:
        command = '''soffice -env:UserInstallation=file://{} --headless
                     --convert-to docx {}'''.format(env_fh, doc_path)
        try:
            subprocess.check_call(shlex.split(command), cwd=os.path.dirname(
                doc_path))
        except subprocess.CalledProcessError as e:
            msg = 'Failed to convert Word document to docx format: {}'
            raise TextPrepareDocumentUpdateError(msg.format(e.output))
    return os.path.splitext(doc_path)[0] + '.docx'

def update_word (doc_path):
    try:
        doc = docx.Document(docx=doc_path)
    except ValueError:
        # doc_file may point to a non-docx file, in which case try to
        # convert it.
        docx_path = convert_to_docx(doc_path)
        doc = docx.Document(docx=docx_path)
        os.remove(docx_path)
    for paragraph in doc.paragraphs:
        paragraph.text = convert_at_codes(paragraph.text)
    output = io.BytesIO()
    doc.save(output)
    return output.getvalue()
