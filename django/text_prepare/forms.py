from django import forms


class UploadDocumentForm (forms.Form):

    document = forms.FileField(label='Document')
