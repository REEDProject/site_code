from django import forms

from eats.forms.edit import create_choice_list


class EntitySearchForm (forms.Form):

    name = forms.CharField(label='Name')
    entity_types = forms.MultipleChoiceField(required=False)
    entity_relationship_types = forms.MultipleChoiceField(required=False)
    creation_start_date = forms.DateField(label_suffix=' (YYYY-MM-DD):',
                                          required=False)
    creation_end_date = forms.DateField(label_suffix=' (YYYY-MM-DD):',
                                        required=False)

    def __init__ (self, topic_map, *args, **kwargs):
        entity_types = kwargs.pop('entity_types', [])
        entity_relationship_types = kwargs.pop('entity_relationship_types',
                                               [])
        super(EntitySearchForm, self).__init__(*args, **kwargs)
        self.fields['entity_types'].choices = create_choice_list(
            topic_map, entity_types, multiple=True)
        self.fields['entity_relationship_types'].choices = create_choice_list(
            topic_map, entity_relationship_types, multiple=True)
