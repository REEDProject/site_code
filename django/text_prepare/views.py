from django.contrib.auth.decorators import login_required
from django.core.files.uploadhandler import TemporaryFileUploadHandler
from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt, csrf_protect

from .document import Document
from .exceptions import (TextPrepareDocumentError,
                         TextPrepareDocumentValidationError)
from .forms import ValidateDocumentForm, ConvertDocumentForm


@login_required
@csrf_exempt
def convert(request):
    """View to convert a supplied Word document into TEI XML.

    Expects the Word document to be in the form returned by
    `update`.

    """
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _convert(request)


@csrf_protect
def _convert(request):
    context = {}
    if request.method == 'POST':
        form = ConvertDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            line_length = form.cleaned_data['line_length']
            base_id = form.cleaned_data['base_id']
            docs = request.FILES.getlist('documents')
            document = Document(base_id)
            try:
                for doc in docs:
                    context['filename'] = doc.name
                    document.convert(doc.temporary_file_path(), line_length)
                zip_archive = document.generate()
                return HttpResponse(zip_archive,
                                    content_type='application/zip')
            except TextPrepareDocumentValidationError as error:
                context['invalid'] = True
                context['error'] = error
            except TextPrepareDocumentError as error:
                context['error'] = error
    else:
        form = ConvertDocumentForm()
    context['form'] = form
    return render(request, 'text_prepare/convert.html', context)


@login_required
@csrf_exempt
def validate(request):
    """View to validate a supplied Word document against the @-code
    grammar.

    Expects the Word document to be in the form returned by
    `update`.

    """
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _validate(request)


@csrf_protect
def _validate(request):
    context = {'error': None, 'filename': None, 'validated': False}
    if request.method == 'POST':
        form = ValidateDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            line_length = form.cleaned_data['line_length']
            docs = request.FILES.getlist('documents')
            context['validated'] = True
            document = Document()
            try:
                for doc in docs:
                    context['filename'] = doc.name
                    document.validate(doc.temporary_file_path(), line_length)
            except TextPrepareDocumentError as error:
                context['error'] = error
    else:
        form = ValidateDocumentForm()
    context['form'] = form
    return render(request, 'text_prepare/validate.html', context)
