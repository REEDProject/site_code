from django import forms


class GitLoginForm (forms.Form):

    username = forms.CharField(label='Git username', max_length=40)
    password = forms.CharField(label='Git password', max_length=60,
                               widget=forms.PasswordInput)
