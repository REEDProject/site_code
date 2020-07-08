SRID = 3857

IS_APPROXIMATE_FIELD_HELP = 'Whether the provided coordinates are approximate or not'

NAME_FIELD_HELP = 'For editors only; not displayed on REED Online site'

LABEL_FLAG_CHOICES = (
    (0, 'Places not expected to be labelled'),
    (1, 'Places to be labelled at all zoom levels (eg, major towns)'),
    (2, 'Places to be labelled at intermediate zoom levels (eg, minor towns)'),
    (3, 'Places to be labelled at highest zoom levels (eg, buildings)'),
)

PLACEHOLDER_COORDINATES_FIELD_HELP = """\
If specified, the point here will be used as the co-ordinates for all
unlocated places for which this place is the container; otherwise,
this place's co-ordinates (as specified in the field/map of that name)
will be used."""

SYMBOL_FLAG_CHOICES = (
    (0, 'Places not expected to be shown'),
    (1, 'Places to be shown at all zoom levels (eg, major towns)'),
    (2, 'Places to be shown at intermediate zoom levels (eg, minor towns)'),
    (3, 'Places to be shown at highest zoom levels (eg, buildings)'),
)
