from django import forms


class UploadDocumentForm (forms.Form):

    document = forms.FileField(label='Document')
    line_length = forms.IntegerField(
        label='Line length', min_value=10, max_value=300,
        help_text='Maximum number of characters per line in Word document, when using a monospace font - necessary for having accurate line numbers in validation errors.')
