import urllib.parse

from django.conf import settings
from django.contrib.auth.decorators import login_required
from django.shortcuts import render

from git.repo.base import Repo

from .forms import GitLoginForm


@login_required
def pull(request):
    context = {}
    if request.method == 'POST':
        form = GitLoginForm(request.POST)
        if form.is_valid():
            try:
                context['fetched'] = update_repository(
                    form.cleaned_data['username'],
                    form.cleaned_data['password'])
            except Exception as e:
                context['error'] = str(e)
    else:
        form = GitLoginForm()
    context['form'] = form
    return render(request, 'git_update/update.html', context)


def add_credentials_to_url(url, username, password):
    """Returns `url` with `username` and `password` added to it."""
    parts = list(urllib.parse.urlparse(url))
    if '@' in parts[1]:
        index = parts[1].index('@')
        parts[1] = parts[1][index+1:]
    parts[1] = '{}:{}@{}'.format(username, password, parts[1])
    return urllib.parse.urlunparse(parts)


def update_repository(username, password):
    repo = Repo(settings.GIT_REPOSITORY_PATH)
    remote = repo.remote()
    old_url = remote.config_reader.get('url')
    fetched = []
    try:
        new_url = add_credentials_to_url(old_url, username, password)
        remote.set_url(new_url)
        fetched = remote.pull()
    finally:
        remote.set_url(old_url)
    return fetched
