from django.conf import settings
from django.core.urlresolvers import reverse

from eats.models import Script
from .admin_view_test_case import AdminViewTestCase


class ScriptViewsTestCase (AdminViewTestCase):

    def test_authentication (self):
        script = self.create_script('Latin', 'Latn', ' ')
        url_data = [
            ('eats-script-list', {}),
            ('eats-script-add', {}),
            ('eats-script-change', {'topic_id': script.get_id()})]
        for url_name, kwargs in url_data:
            url = reverse(url_name, kwargs=kwargs)
            login_url = settings.LOGIN_URL + '?next=' + url
            response = self.app.get(url)
            self.assertRedirects(response, login_url,
                                 msg_prefix='Anonymous user to {}'.format(
                                     url_name))
        for url_name, kwargs in url_data:
            response = self.app.get(url, user='user')
            self.assertRedirects(response, login_url,
                                 msg_prefix='User to {}'.format(url_name))
        for url_name, kwargs in url_data:
            response = self.app.get(url, user='eats_user')
            self.assertRedirects(response, login_url,
                                 msg_prefix='EATS user to {}'.format(url_name))
            response = self.app.get(url, user='staff')
            self.assertEqual(response.status_code, 200)

    def test_script_list (self):
        url = reverse('eats-script-list')
        response = self.app.get(url, user='staff')
        self.assertEqual(response.context['opts'], Script._meta)
        self.assertEqual(len(response.context['topics']), 0)
        script = self.create_script('Latin', 'Latn', ' ')
        response = self.app.get(url, user='staff')
        self.assertEqual(len(response.context['topics']), 1)
        self.assertTrue(script in response.context['topics'])

    def test_script_add_get (self):
        url = reverse('eats-script-add')
        response = self.app.get(url, user='staff')
        self.assertEqual(response.context['opts'], Script._meta)

    def test_script_add_post_redirects (self):
        self.assertEqual(Script.objects.count(), 0)
        url = reverse('eats-script-add')
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Latin'
        form['code'] = 'Latn'
        form['separator'] = ' '
        response = form.submit('_save')
        self.assertRedirects(response, reverse('eats-script-list'))
        self.assertEqual(Script.objects.count(), 1)
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Arabic'
        form['code'] = 'Arab'
        form['separator'] = ' '
        response = form.submit('_addanother')
        self.assertRedirects(response, url)
        self.assertEqual(Script.objects.count(), 2)
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Gujarati'
        form['code'] = 'Gujr'
        form['separator'] = ' '
        response = form.submit('_continue')
        script = Script.objects.get_by_admin_name('Gujarati')
        redirect_url = reverse('eats-script-change',
                               kwargs={'topic_id': script.get_id()})
        self.assertRedirects(response, redirect_url)
        self.assertEqual(Script.objects.count(), 3)

    def test_script_add_post_content (self):
        self.assertRaises(Script.DoesNotExist, Script.objects.get_by_admin_name,
                          'Latin')
        url = reverse('eats-script-add')
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Latin'
        form['code'] = 'Latn'
        form['separator'] = ''
        form.submit('_save').follow()
        script = Script.objects.get_by_admin_name('Latin')
        self.assertEqual(script.get_code(), 'Latn')
        self.assertEqual(script.separator, '')

    def test_script_add_illegal_post (self):
        self.assertEqual(Script.objects.count(), 0)
        url = reverse('eats-script-add')
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        # Missing script name.
        form['code'] = 'Latn'
        response = form.submit('_save')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Script.objects.count(), 0)
        # Missing script code.
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Latin'
        response = form.submit('_save')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Script.objects.count(), 0)
        # Duplicate script name.
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        script = self.create_script('Latin', 'Latn', ' ')
        self.assertEqual(Script.objects.count(), 1)
        form['name'] = 'Latin'
        form['code'] = 'Arab'
        response = form.submit('_save')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Script.objects.count(), 1)
        self.assertTrue(script in Script.objects.all())
        self.assertEqual(script.get_code(), 'Latn')
        # Duplicate script code.
        form = self.app.get(url, user='staff').forms['infrastructure-add-form']
        form['name'] = 'Arabic'
        form['code'] = 'Latn'
        response = form.submit('_save')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Script.objects.count(), 1)
        self.assertTrue(script in Script.objects.all())
        self.assertEqual(script.get_admin_name(), 'Latin')

    def test_script_change_illegal_get (self):
        url = reverse('eats-script-change', kwargs={'topic_id': 0})
        self.app.get(url, status=404, user='staff')

    def test_script_change_get (self):
        script = self.create_script('Latin', 'Latn', ' ')
        url = reverse('eats-script-change', kwargs={'topic_id': script.get_id()})
        response = self.app.get(url, user='staff')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.context['form'].instance, script)

    def test_script_change_post (self):
        self.assertEqual(Script.objects.count(), 0)
        script = self.create_script('Latin', 'Latn', ' ')
        self.assertEqual(script.get_admin_name(), 'Latin')
        self.assertEqual(script.get_code(), 'Latn')
        self.assertEqual(script.separator, ' ')
        url = reverse('eats-script-change',
                      kwargs={'topic_id': script.get_id()})
        form = self.app.get(url, user='staff').forms[
            'infrastructure-change-form']
        form['name'] = 'Arabic'
        form['code'] = 'Arab'
        form['separator'] = '-'
        response = form.submit('_save')
        self.assertRedirects(response, reverse('eats-script-list'))
        self.assertEqual(Script.objects.count(), 1)
        self.assertEqual(script.get_admin_name(), 'Arabic')
        self.assertEqual(script.get_code(), 'Arab')
        self.assertEqual(script.separator, '-')
