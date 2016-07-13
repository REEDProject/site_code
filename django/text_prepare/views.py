from django.contrib.auth.decorators import login_required
from django.core.files.uploadhandler import TemporaryFileUploadHandler
from django.http import HttpResponse
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt, csrf_protect

from .word_updater import update_word
from .document import Document
from .exceptions import (TextPrepareDocumentError,
                         TextPrepareDocumentValidationError)
from .forms import UpdateDocumentForm, ValidateDocumentForm, ConvertDocumentForm


@login_required
@csrf_exempt
def convert (request):
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _convert(request)

@csrf_protect
def _convert (request):
    context = {}
    if request.method == 'POST':
        form = ConvertDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            line_length = form.cleaned_data['line_length']
            base_id = form.cleaned_data['base_id']
            doc = request.FILES['document']
            context['filename'] = doc.name
            document = Document(doc.temporary_file_path(), line_length, base_id)
            try:
                tei = document.convert()
                return HttpResponse(tei, content_type='text/xml')
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
def update (request):
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _update(request)

@csrf_protect
def _update (request):
    if request.method == 'POST':
        form = UpdateDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            doc = request.FILES['document']
            updated_doc = update_word(doc.temporary_file_path())
            return HttpResponse(updated_doc, content_type='application/vnd.openxmlformats-officedocument.wordprocessingml.document')
    else:
        form = UpdateDocumentForm()
    context = {'form': form}
    return render(request, 'text_prepare/update.html', context)

@login_required
@csrf_exempt
def validate (request):
    # Ensure that any uploaded file is stored as a temporary file.
    request.upload_handlers = [TemporaryFileUploadHandler()]
    return _validate(request)

@csrf_protect
def _validate (request):
    context = {'error': None, 'filename': None, 'validated': False}
    if request.method == 'POST':
        form = ValidateDocumentForm(request.POST, request.FILES)
        if form.is_valid():
            line_length = form.cleaned_data['line_length']
            doc = request.FILES['document']
            context['filename'] = doc.name
            context['validated'] = True
            document = Document(doc.temporary_file_path(), line_length, '')
            try:
                document.validate()
            except TextPrepareDocumentError as error:
                context['error'] = error
    else:
        form = ValidateDocumentForm()
    context['form'] = form
    return render(request, 'text_prepare/validate.html', context)
