from django import template


register = template.Library()


@register.filter(name='list_flags')
def list_flags(info):
    """Returns the flags on `info` as a nice list of names."""
    flags = ['ERROR', 'FAST_FORWARD', 'FORCED_UPDATE', 'HEAD_UPTODATE',
             'NEW_HEAD', 'NEW_TAG', 'REJECTED', 'TAG_UPDATE']
    return ', '.join([flag for flag in flags
                      if info.flags & getattr(info, flag)])
