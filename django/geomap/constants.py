SRID = 3857

IS_APPROXIMATE_FIELD_HELP = 'Whether the provided coordinates are approximate or not'

NAME_FIELD_HELP = 'For editors only; not displayed on REED Online site'

# Values taken from "REED 2015-16 GIS DATA layer SPECS 2151215.pdf".
PATRONS_LABEL_FLAG_CHOICES = (
    (0, 'Local sites not expected to be labelled'),
    (1, 'Major town or place to be labelled at all zoom levels'),
    (2, 'Minor town or place to be labelled at intermediate zoom levels'),
    (3, 'Named performance venues to be labelled when zoomed in to largest scales'),
)
PATRONS_PLACE_CODE_CHOICES = (
    (1, 'Town, known event'),
    (2, 'Residence, known event'),
    (3, 'Monastery, known event'),
    (4, 'Town, reference or major town'),
    (5, 'Residence, reference'),
    (6, 'Monastery, reference'),
    (7, 'Town, known local event'),
    (8, 'Residence, known local event'),
    (9, 'Monastery, known local event'),
    (10, 'Town, local reference to place'),
    (11, 'Residence, local reference to place'),
    (12, 'Monastery, local reference to place'),
)

PATRONS_LABEL_FLAG_FIELD_NAME = 'P&P label flag'
PATRONS_PLACE_CODE_FIELD_NAME = 'P&P PCODE'

PLACEHOLDER_COORDINATES_FIELD_HELP = """\
If specified, the point here will be used as the co-ordinates for all
unlocated places for which this place is the container; otherwise,
this place's co-ordinates (as specified in the field/map of that name)
will be used."""
