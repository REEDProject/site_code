"""This module defines a grammar for parsing a records document marked
up using various @-codes and converting it to TEI.

The basic TEI structure generated is:

<text type="record">
  <body xml:lang="...">
    <head>...</head>
    <div type="transcription">
      <div>
        <head>...</head>
        ...
      </div>
      ...
    </div>
    <div type="collation_notes">
      <div type="collation_note">
        ...
      </div>
      ...
    </div>
    <div type="end_notes">
      <div type="end_note">
        ...
      </div>
      ...
    </div>
  </body>
</text>

The grammar does not enforce referential integrity (for collation
notes), and does not produce xml:ids.

"""

import html

import pyparsing as pp


def _define_grammar ():
    content = pp.Word(pp.alphanums + ' ' + '\n')
    content.setWhitespaceChars('')
    content.setDefaultWhitespaceChars('')
    white = pp.Word(' ' + '\n')
    punctuation = pp.oneOf('. , ; : \' " ( ) * / # $ % + - ? – ‑')
    integer = pp.Word(pp.nums)
    ignored = pp.oneOf('\ufeff').suppress() # zero width no-break space
    # This is an awful cludge for < to get around my inability to find
    # a way for pyparsing to handle tables correctly (despite
    # damaged_code working fine). With luck there won't be any < in
    # the text content.
    xml_escape = pp.oneOf('& >') | (pp.Literal('<') + pp.FollowedBy(
        white | ignored | integer))
    xml_escape.setParseAction(_pa_xml_escape)
    vowels = pp.oneOf('A a E e I i O o U u')
    acute_code = pp.Literal("@'") + vowels
    acute_code.setParseAction(_pa_acute)
    ae_code = pp.Literal('@ae').setParseAction(_pa_ae)
    AE_code = pp.Literal('@AE').setParseAction(_pa_AE)
    blank_code = pp.Literal('{(blank)}').setParseAction(_pa_blank)
    capitulum_code = pp.Literal('@C').setParseAction(_pa_capitulum)
    caret_code = pp.Literal('^').setParseAction(_pa_caret)
    cedilla_code = pp.Literal('@?') + pp.oneOf('c')
    cedilla_code.setParseAction(_pa_cedilla)
    circumflex_code = pp.Literal('@^') + vowels
    circumflex_code.setParseAction(_pa_circumflex)
    collation_ref_number_code = '@r' + pp.OneOrMore(integer) + '\\'
    collation_ref_number_code.setParseAction(_pa_collation_ref_number)
    damaged_code = pp.Literal('<') + (pp.Word('.', min=1) ^ pp.Literal('…')) + \
                   pp.Literal('>')
    damaged_code.setParseAction(_pa_damaged)
    dot_over_code = pp.Literal('@.') + pp.Regex(r'[A-Za-z]')
    dot_over_code.setParseAction(_pa_dot_over)
    dot_under_code = pp.Literal('@#') + pp.Regex(r'[A-Za-z]')
    dot_under_code.setParseAction(_pa_dot_under)
    ellipsis_code = pp.Literal('...') ^ pp.Literal('…')
    ellipsis_code.setParseAction(_pa_ellipsis)
    en_dash_code = pp.Literal('--').setParseAction(_pa_en_dash)
    eng_code = pp.Literal('@n').setParseAction(_pa_eng)
    ENG_code = pp.Literal('@N').setParseAction(_pa_ENG)
    eth_code = pp.Literal('@d').setParseAction(_pa_eth)
    exclamation_code = pp.Literal('@!').setParseAction(_pa_exclamation)
    grave_code = pp.Literal('@,') + vowels
    grave_code.setParseAction(_pa_grave)
    macron_code = pp.Literal('@-') + vowels
    macron_code.setParseAction(_pa_macron)
    oe_code = pp.Literal('@oe').setParseAction(_pa_oe)
    OE_code = pp.Literal('@OE').setParseAction(_pa_OE)
    page_break_code = pp.Literal('|').setParseAction(_pa_page_break)
    paragraph_code = pp.Literal('@P').setParseAction(_pa_paragraph)
    pound_code = pp.Literal('@$').setParseAction(_pa_pound)
    raised_code = pp.Literal('@*').setParseAction(_pa_raised)
    return_code = pp.Literal('!').setParseAction(_pa_return)
    section_code = pp.Literal('@%').setParseAction(_pa_section)
    semicolon_code = pp.Literal('@;').setParseAction(_pa_semicolon)
    special_v_code = pp.Literal('@v').setParseAction(_pa_special_v)
    tab_code = pp.Literal('@[').setParseAction(_pa_tab)
    thorn_code = pp.Literal('@th').setParseAction(_pa_thorn)
    THORN_code = pp.Literal('@TH').setParseAction(_pa_THORN)
    tilde_code = pp.Literal('@"') + (vowels | pp.Literal('n'))
    tilde_code.setParseAction(_pa_tilde)
    umlaut_code = pp.Literal('@:') + vowels
    umlaut_code.setParseAction(_pa_umlaut)
    wynn_code = pp.Literal('@y').setParseAction(_pa_wynn)
    yogh_code = pp.Literal('@z').setParseAction(_pa_yogh)
    YOGH_code = pp.Literal('@Z').setParseAction(_pa_YOGH)
    single_codes = acute_code ^ ae_code ^ AE_code ^ blank_code ^ capitulum_code ^ caret_code ^ cedilla_code ^ circumflex_code ^ collation_ref_number_code ^ damaged_code ^ dot_over_code ^ dot_under_code ^ ellipsis_code ^ en_dash_code ^ eng_code ^ ENG_code ^ eth_code ^ exclamation_code ^ grave_code ^ macron_code ^ oe_code ^ OE_code ^ page_break_code ^ paragraph_code ^ pound_code ^ raised_code ^ section_code ^ semicolon_code ^ special_v_code ^ tab_code ^ thorn_code ^ THORN_code ^ tilde_code ^ umlaut_code ^ wynn_code ^ yogh_code ^ YOGH_code
    enclosed = pp.Forward()
    bold_code = pp.nestedExpr('@e\\', '@e/', content=enclosed)
    bold_code.setParseAction(_pa_bold)
    bold_italic_code = pp.nestedExpr('@j\\', '@j/', content=enclosed)
    bold_italic_code.setParseAction(_pa_bold_italic)
    centred_code = pp.nestedExpr('@m\\', '@m/', content=enclosed)
    centred_code.setParseAction(_pa_centred)
    closer_code = pp.nestedExpr('@cl\\', '@cl/', content=enclosed)
    closer_code.setParseAction(_pa_closer)
    collation_ref = pp.nestedExpr('@cr\\', '@cr/',
                                  content=collation_ref_number_code - enclosed)
    collation_ref.setParseAction(_pa_collation_ref)
    comment_code = pp.nestedExpr('@xc\\', '@xc/', content=enclosed)
    comment_code.setParseAction(_pa_comment)
    deleted_code = pp.nestedExpr('[', ']', content=enclosed)
    deleted_code.setParseAction(_pa_deleted)
    lang_ancient_greek_code = pp.nestedExpr('@grc\\', '@grc/',
                                           content=enclosed)
    lang_ancient_greek_code.setParseAction(_pa_lang_ancient_greek)
    lang_anglo_norman_code = pp.nestedExpr('@xno\\', '@xno/',
                                           content=enclosed)
    lang_anglo_norman_code.setParseAction(_pa_lang_anglo_norman)
    lang_cornish_code = pp.nestedExpr('@cor\\', '@cor/', content=enclosed)
    lang_cornish_code.setParseAction(_pa_lang_cornish)
    lang_english_code = pp.nestedExpr('@eng\\', '@eng/', content=enclosed)
    lang_english_code.setParseAction(_pa_lang_english)
    lang_french_code = pp.nestedExpr('@fra\\', '@fra/', content=enclosed)
    lang_french_code.setParseAction(_pa_lang_french)
    lang_german_code = pp.nestedExpr('@deu\\', '@deu/', content=enclosed)
    lang_german_code.setParseAction(_pa_lang_german)
    lang_italian_code = pp.nestedExpr('@ita\\', '@ita/', content=enclosed)
    lang_italian_code.setParseAction(_pa_lang_italian)
    lang_latin_code = pp.nestedExpr('@lat\\', '@lat/', content=enclosed)
    lang_latin_code.setParseAction(_pa_lang_latin)
    lang_middle_cornish_code = pp.nestedExpr('@cnx\\', '@cnx/',
                                             content=enclosed)
    lang_middle_cornish_code.setParseAction(_pa_lang_middle_cornish)
    lang_middle_high_german_code = pp.nestedExpr('@gmh\\', '@gmh/',
                                                 content=enclosed)
    lang_middle_high_german_code.setParseAction(_pa_lang_middle_high_german)
    lang_middle_low_german_code = pp.nestedExpr('@gml\\', '@gml/',
                                                content=enclosed)
    lang_middle_low_german_code.setParseAction(_pa_lang_middle_low_german)
    lang_middle_welsh_code = pp.nestedExpr('@wlm\\', '@wlm/',
                                           content=enclosed)
    lang_middle_welsh_code.setParseAction(_pa_lang_middle_welsh)
    lang_portuguese_code = pp.nestedExpr('@por\\', '@por/', content=enclosed)
    lang_portuguese_code.setParseAction(_pa_lang_portuguese)
    lang_scottish_gaelic_code = pp.nestedExpr('@gla\\', '@gla/',
                                              content=enclosed)
    lang_scottish_gaelic_code.setParseAction(_pa_lang_scottish_gaelic)
    lang_spanish_code = pp.nestedExpr('@spa\\', '@spa/', content=enclosed)
    lang_spanish_code.setParseAction(_pa_lang_spanish)
    lang_welsh_code = pp.nestedExpr('@cym\\', '@cym/', content=enclosed)
    lang_welsh_code.setParseAction(_pa_lang_welsh)
    language_codes = (lang_ancient_greek_code ^
                      lang_anglo_norman_code ^ lang_cornish_code ^
                      lang_english_code ^ lang_french_code ^ lang_german_code ^
                      lang_italian_code ^ lang_latin_code ^
                      lang_middle_cornish_code ^ lang_middle_high_german_code ^
                      lang_middle_low_german_code ^ lang_middle_welsh_code ^
                      lang_portuguese_code ^ lang_scottish_gaelic_code ^
                      lang_spanish_code ^ lang_welsh_code)
    exdented_code = pp.nestedExpr('@g\\', '@g/', content=enclosed)
    exdented_code.setParseAction(_pa_exdented)
    expansion_code = pp.nestedExpr('{', '}', content=enclosed)
    expansion_code.setParseAction(_pa_expansion)
    footnote_code = pp.nestedExpr('@f\\', '@f/', content=enclosed)
    footnote_code.setParseAction(_pa_footnote)
    indented_code = pp.nestedExpr('@p\\', '@p/', content=enclosed)
    indented_code.setParseAction(_pa_indented)
    interlineation_above_code = pp.nestedExpr('@a\\', '@a/', content=enclosed)
    interlineation_above_code.setParseAction(_pa_interlineation_above)
    interlineation_below_code = pp.nestedExpr('@b\\', '@b/', content=enclosed)
    interlineation_below_code.setParseAction(_pa_interlineation_below)
    interpolation_code = pp.nestedExpr('@i\\', '@i/', content=enclosed)
    interpolation_code.setParseAction(_pa_interpolation)
    italic_small_caps_code = pp.nestedExpr('@q\\', '@q/', content=enclosed)
    italic_small_caps_code.setParseAction(_pa_italic_small_caps)
    left_marginale_code = pp.nestedExpr('@l\\', '@l/', content=enclosed)
    left_marginale_code.setParseAction(_pa_left_marginale)
    list_item_code = pp.nestedExpr('@li\\', '@li/', content=enclosed)
    list_item_code.setParseAction(_pa_list_item_code)
    list_code = pp.nestedExpr('@ul\\', '@ul/', content=pp.OneOrMore(
        pp.Suppress(pp.ZeroOrMore(white | ignored)) + list_item_code +
        pp.Suppress(pp.ZeroOrMore(white | ignored))))
    list_code.setParseAction(_pa_list_code)
    personnel_code = pp.nestedExpr('@x\\', '@x/', content=enclosed)
    personnel_code.setParseAction(_pa_personnel)
    right_marginale_code = pp.nestedExpr('@r\\', '@r/', content=enclosed)
    right_marginale_code.setParseAction(_pa_right_marginale)
    signed_code = pp.nestedExpr('@sn\\', '@sn/', content=enclosed)
    signed_code.setParseAction(_pa_signed)
    signed_centre_code = pp.nestedExpr('@snc\\', '@snc/', content=enclosed)
    signed_centre_code.setParseAction(_pa_signed_centre)
    signed_right_code = pp.nestedExpr('@snr\\', '@snr/', content=enclosed)
    signed_right_code.setParseAction(_pa_signed_right)
    small_caps_code = pp.nestedExpr('@k\\', '@k/', content=enclosed)
    small_caps_code.setParseAction(_pa_small_caps)
    superscript_code = pp.nestedExpr('@s\\', '@s/', content=enclosed)
    superscript_code.setParseAction(_pa_superscript)
    tab_start_code = pp.nestedExpr(pp.LineStart() + pp.Literal('@['), '!',
                                   content=enclosed)
    tab_start_code.setParseAction(_pa_tab_start)
    paired_codes = bold_code ^ bold_italic_code ^ centred_code ^ closer_code ^ collation_ref ^ comment_code ^ deleted_code ^ exdented_code ^ expansion_code ^ footnote_code ^ indented_code ^ interpolation_code ^ interlineation_above_code ^ interlineation_below_code ^ italic_small_caps_code ^ language_codes ^ left_marginale_code ^ list_code ^ personnel_code ^ right_marginale_code ^ signed_code ^ signed_centre_code ^ signed_right_code ^ small_caps_code ^ superscript_code ^ tab_start_code
    enclosed << pp.OneOrMore(single_codes ^ return_code ^ paired_codes ^
                             content ^ punctuation ^ xml_escape ^ ignored)
    cell = pp.nestedExpr('<c>', '</c>', content=enclosed)
    cell.setParseAction(_pa_cell)
    cell_right = pp.nestedExpr('<cr>', '</cr>', content=enclosed)
    cell_right.setParseAction(_pa_cell_right)
    row = pp.nestedExpr('<r>', '</r>', content=pp.OneOrMore(
        cell | cell_right | comment_code | white))
    row.setParseAction(_pa_row)
    table = pp.nestedExpr('<t>', '</t>', content=pp.OneOrMore(
        row | comment_code | white))
    table.setParseAction(_pa_table)
    record_heading_place = pp.Word(pp.alphanums)
    record_heading_place.setParseAction(_pa_record_heading_place)
    record_heading_record = pp.Word(pp.alphanums)
    record_heading_record.setParseAction(_pa_record_heading_record)
    year = pp.Word(pp.nums, min=4, max=4)
    record_heading_date_century = pp.Word(pp.nums, min=2, max=2).setResultsName('century') + pp.Literal('th Century').setResultsName('label')
    record_heading_date_century.setParseAction(_pa_record_heading_date_century)
    circa = pp.Literal('c ')
    slash_year = pp.Literal('/') + pp.Word(pp.nums, min=1, max=2)
    start_year = pp.Optional(circa).setResultsName('circa') + \
                 year.setResultsName('year') + \
                 pp.Optional(slash_year).setResultsName('slash_year')
    end_year = pp.Word(pp.nums, min=1, max=4).setResultsName('end_year') + \
               pp.Optional(slash_year).setResultsName('slash_end_year')
    record_heading_date_year = start_year + pp.Optional(pp.oneOf('- –') + \
                                                        end_year)
    record_heading_date_year.setParseAction(_pa_record_heading_date_year)
    record_heading_date = record_heading_date_century ^ record_heading_date_year
    language_code = pp.oneOf('cnx cor cym deu eng fra gla gmh gml grc ita lat '
                             'por spa wlm xno')
    record_heading_content = record_heading_place - \
                             pp.Literal('!').suppress() - \
                             record_heading_date - \
                             pp.Literal('!').suppress() - \
                             record_heading_record - \
                             pp.Literal('!').suppress() - \
                             language_code
    record_heading = pp.nestedExpr('@h\\', '\\!',
                                   content=record_heading_content)
    record_heading.setParseAction(_pa_record_heading)
    # A special content model is required for transcription headings,
    # since [] does not mean deleted material there.
    supplied_code = pp.nestedExpr('{', '}', content=enclosed)
    supplied_code.setParseAction(_pa_supplied)
    transcription_heading_content = pp.OneOrMore(
        single_codes ^ pp.Word(pp.alphanums + ' []-–') ^ punctuation ^
        xml_escape ^ ignored ^ supplied_code)
    transcription_heading = pp.nestedExpr('@w\\', '\\!',
                                          content=transcription_heading_content)
    transcription_heading.setParseAction(_pa_transcription_heading)
    transcription_section = transcription_heading - pp.OneOrMore(
        table ^ enclosed)
    transcription_section.setParseAction(_pa_transcription_section)
    transcription = pp.OneOrMore(transcription_section)
    transcription.setParseAction(_pa_transcription)
    collation_note_anchor = pp.Literal('@a') - pp.OneOrMore(integer) - \
                            pp.Literal('\\')
    collation_note_anchor.setParseAction(_pa_collation_note_anchor)
    collation_note_content = collation_note_anchor - enclosed
    collation_note = pp.nestedExpr('@c\\', '@c/',
                                   content=collation_note_content)
    collation_note.setParseAction(_pa_collation_note)
    collation_note_wrapper = pp.Suppress(pp.ZeroOrMore(white | ignored)) + \
                             collation_note + pp.Suppress(
                                 pp.ZeroOrMore(white | ignored))
    collation_notes = pp.nestedExpr('@cn\\', '@cn/', content=pp.OneOrMore(
        collation_note_wrapper))
    collation_notes.setParseAction(_pa_collation_notes)
    end_note = pp.nestedExpr('@E\\', '@E/', content=enclosed)
    end_note.setParseAction(_pa_endnote)
    end_note_wrapper = pp.Suppress(pp.ZeroOrMore(white | ignored)) + \
                       end_note + pp.Suppress(pp.ZeroOrMore(white | ignored))
    end_notes = pp.nestedExpr('@EN\\', '@EN/', content=pp.OneOrMore(
        end_note_wrapper))
    end_notes.setParseAction(_pa_endnotes)
    record = pp.ZeroOrMore(white | ignored) + record_heading + \
                   pp.ZeroOrMore(white) + transcription + \
                   pp.Optional(collation_notes) + pp.Optional(end_notes)
    record.setParseAction(_pa_record)
    return pp.StringStart() + pp.OneOrMore(record) + pp.StringEnd()

def _get_page_type (data):
    """Return the expanded page type indicated by the abbreviation `data`,
    or an empty string if not match is found."""
    ptype = ''
    if data in ('f', 'ff'):
        ptype = 'folio'
    elif data == 'mb':
        ptype = 'membrane'
    elif data == 'p':
        ptype = 'page'
    elif data == 'sheet':
        ptype = 'sheet'
    elif data == 'sig':
        ptype = 'signature'
    return ptype

def _make_foreign (lang_code, toks):
    return ['<foreign xml:lang="{}">{}</foreign>'.format(
        lang_code, ''.join(toks[0]))]

def _make_signed (s, loc, toks, rend_value=None):
    rend = ''
    if rend_value:
        rend = ' rend="{}"'.format(rend_value)
    return ['<seg type="signed"{}>'.format(rend), ''.join(toks[0]), '</seg>']

def _merge_years (year, replacement):
    """Return `year` merged with `replacement`, where `replacement`
    replaces the last digit(s) of `year`."""
    changed = 4 - len(replacement)
    base = year[:changed]
    return base + replacement

def _pa_acute (s, loc, toks):
    return ['{}\N{COMBINING ACUTE ACCENT}'.format(toks[1])]

def _pa_ae (s, loc, toks):
    return ['\N{LATIN SMALL LETTER AE}']

def _pa_AE (s, loc, toks):
    return ['\N{LATIN CAPITAL LETTER AE}']

def _pa_blank (s, loc, toks):
    return ['<space />']

def _pa_bold (s, loc, toks):
    return ['<hi rend="bold">', ''.join(toks[0]), '</hi>']

def _pa_bold_italic (s, loc, toks):
    return ['<hi rend="bold_italic">', ''.join(toks[0]), '</hi>']

def _pa_capitulum (s, loc, toks):
    # Black Leftwards Bullet is not the correct character, but
    # according to the Fortune white paper it is "as close as we can
    # get for now".
    return ['\N{BLACK LEFTWARDS BULLET}']

def _pa_caret (s, loc, toks):
    return ['\N{CARET}']

def _pa_cedilla (s, loc, toks):
    return ['{}\N{COMBINING CEDILLA}'.format(toks[1])]

def _pa_cell (s, loc, toks):
    return ['<cell>', ''.join(toks[0]), '</cell>']

def _pa_cell_right (s, loc, toks):
    return ['<cell rend="right">', ''.join(toks[0]), '</cell>']

def _pa_centred (s, loc, toks):
    return ['<hi rend="center">', ''.join(toks[0]), '</hi>']

def _pa_circumflex (s, loc, toks):
    return ['{}\N{COMBINING CIRCUMFLEX ACCENT}'.format(toks[1])]

def _pa_closer (s, loc, toks):
    return ['<closer>', ''.join(toks[0]), '</closer>']

def _pa_collation_note (s, loc, toks):
    return ['<div type="collation_note">\n', ''.join(toks[0]), '\n</div>\n']

def _pa_collation_note_anchor (s, loc, toks):
    return ['<anchor n="cn{}" />'.format(toks[1])]

def _pa_collation_notes (s, loc, toks):
    return ['<div type="collation_notes">\n', ''.join(toks[0]), '</div>\n']

def _pa_collation_ref (s, loc, toks):
    return ['<ref target="#cn{}" type="collation-note">{}</ref>'.format(
        toks[0][0], toks[0][1])]

def _pa_collation_ref_number (s, loc, toks):
    return [toks[1]]

def _pa_comment (s, loc, toks):
    return ['<!-- ', ''.join(toks[0]), ' -->']

def _pa_damaged (s, loc, toks):
    return ['<damage><gap unit="chars" extent="{}" /></damage>'.format(
        len(toks[1]))]

def _pa_deleted (s, loc, toks):
    return ['<del>', ''.join(toks[0]), '</del>']

def _pa_dot_over (s, loc, toks):
    return ['{}\N{COMBINING DOT ABOVE}'.format(toks[1])]

def _pa_dot_under (s, loc, toks):
    return ['{}\N{COMBINING DOT BELOW}'.format(toks[1])]

def _pa_ellipsis (s, loc, toks):
    return ['<gap reason="omitted" />']

def _pa_en_dash (s, loc, toks):
    return ['\N{EN DASH}']

def _pa_endnote (s, loc, toks):
    return ['<div type="end_note">\n', ''.join(toks[0]), '\n</div>\n']

def _pa_endnotes (s, loc, toks):
    return ['<div type="end_notes">\n', ''.join(toks[0]), '</div>\n']

def _pa_eng (s, loc, toks):
    return ['\N{LATIN SMALL LETTER ENG}']

def _pa_ENG (s, loc, toks):
    return ['\N{LATIN CAPITAL LETTER ENG}']

def _pa_eth (s, loc, toks):
    return ['\N{LATIN SMALL LETTER ETH}']

def _pa_exclamation (s, loc, toks):
    return ['!']

def _pa_exdented (s, loc, toks):
    return ['<ab type="exdent">', ''.join(toks[0]), '</ab>']

def _pa_expansion (s, loc, toks):
    return ['<ex>', ''.join(toks[0]), '</ex>']

def _pa_footnote (s, loc, toks):
    return ['<note type="foot">', ''.join(toks[0]), '</note>']

def _pa_grave (s, loc, toks):
    return ['{}\N{COMBINING GRAVE ACCENT}'.format(toks[1])]

def _pa_indented (s, loc, toks):
    return ['<ab type="indent">', ''.join(toks[0]), '</ab>']

def _pa_interlineation_above (s, loc, toks):
    return ['<add place="above">', ''.join(toks[0]), '</add>']

def _pa_interlineation_below (s, loc, toks):
    return ['<add place="below">', ''.join(toks[0]), '</add>']

def _pa_interpolation (s, loc, toks):
    return ['<add><handShift />', ''.join(toks[0]), '</add>']

def _pa_italic_small_caps (s, loc, toks):
    return ['<hi rend="smallcaps_italic">', ''.join(toks[0]), '</hi>']

def _pa_lang_ancient_greek (s, loc, toks):
    return _make_foreign('grc', toks)

def _pa_lang_anglo_norman (s, loc, toks):
    return _make_foreign('xno', toks)

def _pa_lang_cornish (s, loc, toks):
    return _make_foreign('cor', toks)

def _pa_lang_english (s, loc, toks):
    return _make_foreign('eng', toks)

def _pa_lang_french (s, loc, toks):
    return _make_foreign('fra', toks)

def _pa_lang_german (s, loc, toks):
    return _make_foreign('deu', toks)

def _pa_lang_italian (s, loc, toks):
    return _make_foreign('ita', toks)

def _pa_lang_latin (s, loc, toks):
    return _make_foreign('lat', toks)

def _pa_lang_middle_cornish (s, loc, toks):
    return _make_foreign('cnx', toks)

def _pa_lang_middle_high_german (s, loc, toks):
    return _make_foreign('gmh', toks)

def _pa_lang_middle_low_german (s, loc, toks):
    return _make_foreign('gml', toks)

def _pa_lang_middle_welsh (s, loc, toks):
    return _make_foreign('wlm', toks)

def _pa_lang_portuguese (s, loc, toks):
    return _make_foreign('por', toks)

def _pa_lang_scottish_gaelic (s, loc, toks):
    return _make_foreign('gla', toks)

def _pa_lang_spanish (s, loc, toks):
    return _make_foreign('spa', toks)

def _pa_lang_welsh (s, loc, toks):
    return _make_foreign('cym', toks)

def _pa_left_marginale (s, loc, toks):
    return ['<note type="marginal" place="margin_left">', ''.join(toks[0]),
            '</note>']

def _pa_list_item_code (s, loc, toks):
    return ['<item>', ''.join(toks[0]), '</item>']

def _pa_list_code (s, loc, toks):
    return ['<list>', ''.join(toks[0]), '</list>']

def _pa_macron (s, loc, toks):
    return ['{}\N{COMBINING MACRON}'.format(toks[1])]

def _pa_oe (s, loc, toks):
    return ['\N{LATIN SMALL LIGATURE OE}']

def _pa_OE (s, loc, toks):
    return ['\N{LATIN CAPITAL LIGATURE OE}']

def _pa_page_break (s, loc, toks):
    return ['<pb />']

def _pa_paragraph (s, loc, toks):
    return ['\N{PILCROW SIGN}']

def _pa_personnel (s, loc, toks):
    return ['<note type="eccles_court">', ''.join(toks[0]), '</note>']

def _pa_pound (s, loc, toks):
    return ['\N{POUND SIGN}']

def _pa_raised (s, loc, toks):
    return ['\N{MIDDLE DOT}']

def _pa_record (s, loc, toks):
    return ['<text type="record">\n<body xml:lang="{}">\n{}</body>\n</text>'.format(toks[0], ''.join(toks[1:]))]

def _pa_record_heading (s, loc, toks):
    place, date, record, language_code = toks[0]
    return [language_code, '<head>{} {} {}</head>'.format(place, date, record)]

def _pa_record_heading_date_century (s, loc, toks):
    century = int(toks['century'])
    label = toks['label']
    return ['<date from-iso="{}01" to-iso="{}00">{}{}</date>'.format(
        century-1, century, century, label)]

def _pa_record_heading_date_year (s, loc, toks):
    circa = toks.get('circa')
    year = toks['year']
    slash_year = toks.get('slash_year')
    end_year = toks.get('end_year')
    slash_end_year = toks.get('slash_end_year')
    attrs = []
    if circa:
        attrs.append('precision="low"')
    if slash_year:
        year = _merge_years(year, slash_year[1])
    if end_year:
        end_year = _merge_years(year, end_year)
        if slash_end_year:
            end_year = _merge_years(end_year, slash_end_year[1])
        attrs.append('from-iso="{}"'.format(year))
        attrs.append('to-iso="{}"'.format(end_year))
    else:
        attrs.append('when-iso="{}"'.format(year))
    attrs.sort()
    return ['<date {}>{}</date>'.format(' '.join(attrs), ''.join(toks))]

def _pa_record_heading_place (s, loc, toks):
    return ['<name ana="ereed:{}" type="place_region">{}</name>'.format(
        toks[0], toks[0])]

def _pa_record_heading_record (s, loc, toks):
    return ['<seg ana="ereed:{}">{}</seg>'.format(toks[0], toks[0])]

def _pa_return (s, loc, toks):
    # TODO: Perhaps add newlines here to deal with the case of long
    # lines in the source?
    return ['<lb />']

def _pa_right_marginale (s, loc, toks):
    return ['<note type="marginal" place="margin_right">', ''.join(toks[0]),
            '</note>']

def _pa_row (s, loc, toks):
    return ['<row>', ''.join(toks[0]), '</row>']

def _pa_section (s, loc, toks):
    return ['\N{SECTION SIGN}']

def _pa_semicolon (s, loc, toks):
    # Private Use Area; see
    # http://folk.uib.no/hnooh/mufi/specs/MUFI-Alphabetic-3-0.pdf
    return ['\uF161']

def _pa_signed (s, loc, toks):
    return _make_signed(s, loc, toks)

def _pa_signed_centre (s, loc, toks):
    return _make_signed(s, loc, toks, 'centre')

def _pa_signed_right (s, loc, toks):
    return _make_signed(s, loc, toks, 'right')

def _pa_small_caps (s, loc, toks):
    return ['<hi rend="smallcaps">', ''.join(toks[0]), '</hi>']

def _pa_special_v (s, loc, toks):
    return ['\N{LATIN SMALL LETTER MIDDLE-WELSH V}']

def _pa_superscript (s, loc, toks):
    return ['<hi rend="superscript">', ''.join(toks[0]), '</hi>']

def _pa_supplied (s, loc, toks):
    return ['<supplied>', ''.join(toks[0]), '</supplied>']

def _pa_tab (s, loc, toks):
    return ['<milestone type="table-cell" />']

def _pa_tab_start (s, loc, toks):
    return ['<hi rend="right">', ''.join(toks[0]), '</hi>']

def _pa_table (s, loc, toks):
    return ['<table>', ''.join(toks[0]), '</table>']

def _pa_thorn (s, loc, toks):
    return ['\N{LATIN SMALL LETTER THORN}']

def _pa_THORN (s, loc, toks):
    return ['\N{LATIN CAPITAL LETTER THORN}']

def _pa_tilde (s, loc, toks):
    return ['{}\N{COMBINING TILDE}'.format(toks[1])]

def _pa_transcription (s, loc, toks):
    return ['<div type="transcription">\n', ''.join(toks), '</div>\n']

def _pa_transcription_heading (s, loc, toks):
    try:
        page_details = toks[0][0].strip().split()
    except IndexError:
        # toks[0] (the entire contents of the @w) may be empty (though
        # this is a degenerate case that likely shouldn't occur).
        page_details = []
    if page_details:
        n = ''
        ptype = ''
        if len(page_details) < 2:
            pass
        elif page_details[0] == 'single':
            n = '1'
            ptype = _get_page_type(page_details[1])
        else:
            ptype = _get_page_type(page_details[0])
            n = page_details[1]
        if '–' in n or '-' in n:
            n = ''
        if ptype:
            ptype = ' type="{}"'.format(ptype)
        if n:
            n = ' n="{}"'.format(n)
        pb = '<pb{}{} />'.format(n, ptype)
    else:
        pb = ''
    return ['<head>{}</head>\n{}'.format(''.join(toks[0]), pb)]

def _pa_transcription_section (s, loc, toks):
    return ['<div>\n', ''.join(toks), '\n</div>\n']

def _pa_umlaut (s, loc, toks):
    return ['{}\N{COMBINING DIAERESIS}'.format(toks[1])]

def _pa_wynn (s, loc, toks):
    return ['\N{LATIN LETTER WYNN}']

def _pa_xml_escape (s, loc, toks):
    return [html.escape(toks[0])]

def _pa_yogh (s, loc, toks):
    return ['\N{LATIN SMALL LETTER YOGH}']

def _pa_YOGH (s, loc, toks):
    return ['\N{LATIN CAPITAL LETTER YOGH}']

document_grammar = _define_grammar()
