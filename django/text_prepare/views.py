from django.core.files.uploadhandler import TemporaryFileUploadHandler
from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt, csrf_protect

from .document import Document
from .exceptions import (TextPrepareDocumentError,
                         TextPrepareDocumentValidationError)
from .forms import UploadDocumentForm


@csrf_exempt
def convert (request):
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _convert(request)

@csrf_protect
def _convert (request):
    context = {}
    if request.method == 'POST':
        form = UploadDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            doc = request.FILES['document']
            context['filename'] = doc.name
            document = Document(doc.temporary_file_path())
            try:
                tei = document.convert()
                return HttpResponse(tei, content_type='text/xml')
            except TextPrepareDocumentValidationError as error:
                context['invalid'] = True
                context['error'] = error
            except TextPrepareDocumentError as error:
                context['error'] = error
    else:
        form = UploadDocumentForm()
    context['form'] = form
    return render(request, 'text_prepare/convert.html', context)

@csrf_exempt
def validate (request):
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _validate(request)

@csrf_protect
def _validate (request):
    context = {'error': None, 'filename': None, 'validated': False}
    if request.method == 'POST':
        form = UploadDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            doc = request.FILES['document']
            context['filename'] = doc.name
            context['validated'] = True
            document = Document(doc.temporary_file_path())
            try:
                document.validate()
            except TextPrepareDocumentError as error:
                context['error'] = error
    else:
        form = UploadDocumentForm()
    context['form'] = form
    return render(request, 'text_prepare/validate.html', context)
