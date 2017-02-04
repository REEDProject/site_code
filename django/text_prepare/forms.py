from django import forms


class ValidateDocumentForm (forms.Form):

    documents = forms.FileField(
        label='Word documents', widget=forms.FileInput(
            attrs={'multiple': 'multiple'}))
    line_length = forms.IntegerField(
        label='Line length', min_value=10, max_value=300,
        help_text='Maximum number of characters per line in Word document, when using a monospace font - necessary for having accurate line numbers in validation errors.')


class ConvertDocumentForm (ValidateDocumentForm):

    base_id = forms.CharField(
        label='Base xml:id', max_length=20, min_length=4,
        help_text='xml:id for resulting TEI document, used as a base for all other xml:ids; must be unique across the all collections. The saved TEI document must have the same name as this: eg, xml:id of "staff", filename of "staff.xml"')
