import html

import pyparsing as pp


def _define_grammar ():
    content = pp.Word(pp.alphanums + ' ' + '\n')
    content.setWhitespaceChars('')
    content.setDefaultWhitespaceChars('')
    white = pp.Word(' ' + '\n')
    punctuation = pp.oneOf('. , ; : \' " ( ) * / # $ % + - ? | –')
    ignored = pp.oneOf('\ufeff').suppress() # zero width no-break space
    # This is an awful cludge for < to get around my inability to find
    # a way for pyparsing to handle tables correctly (despite
    # damaged_code working fine). With luck there won't be any < in
    # the text content.
    xml_escape = pp.oneOf('& >') | (pp.Literal('<') + pp.FollowedBy(
        white | ignored | pp.nums))
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
    collation_ref_code = '@c\\' + pp.OneOrMore(pp.nums) + '\\'
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
    endnote_code = '@E\\' + pp.OneOrMore(pp.nums) + '\\'
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
    single_codes = acute_code ^ ae_code ^ AE_code ^ blank_code ^ capitulum_code ^ caret_code ^ cedilla_code ^ circumflex_code ^ collation_ref_code ^ damaged_code ^ dot_over_code ^ dot_under_code ^ ellipsis_code ^ en_dash_code ^ endnote_code ^ eng_code ^ ENG_code ^ eth_code ^ exclamation_code ^ grave_code ^ macron_code ^ oe_code ^ OE_code ^ paragraph_code ^ pound_code ^ raised_code ^ section_code ^ semicolon_code ^ special_v_code ^ tab_code ^ thorn_code ^ THORN_code ^ tilde_code ^ umlaut_code ^ wynn_code ^ yogh_code ^ YOGH_code
    enclosed = pp.Forward()
    bold_code = pp.nestedExpr('@e\\', '@e \\', content=enclosed)
    bold_code.setParseAction(_pa_bold)
    bold_italic_code = pp.nestedExpr('@j\\', '@j \\', content=enclosed)
    bold_italic_code.setParseAction(_pa_bold_italic)
    centred_code = pp.nestedExpr('@m\\', '@m \\', content=enclosed)
    centred_code.setParseAction(_pa_centred)
    comment_code = pp.nestedExpr('@xc\\', '@xc \\', content=enclosed)
    comment_code.setParseAction(_pa_comment)
    deleted_code = pp.nestedExpr('[', ']', content=enclosed)
    deleted_code.setParseAction(_pa_deleted)
    lang_ancient_greek_code = pp.nestedExpr('@grc\\', '@grc \\',
                                           content=enclosed)
    lang_ancient_greek_code.setParseAction(_pa_lang_ancient_greek)
    lang_anglo_french_code = pp.nestedExpr('@xaf\\', '@xaf \\',
                                           content=enclosed)
    lang_anglo_french_code.setParseAction(_pa_lang_anglo_french)
    lang_anglo_norman_code = pp.nestedExpr('@xno\\', '@xno \\',
                                           content=enclosed)
    lang_anglo_norman_code.setParseAction(_pa_lang_anglo_norman)
    lang_cornish_code = pp.nestedExpr('@cor\\', '@cor \\', content=enclosed)
    lang_cornish_code.setParseAction(_pa_lang_cornish)
    lang_english_code = pp.nestedExpr('@eng\\', '@eng \\', content=enclosed)
    lang_english_code.setParseAction(_pa_lang_english)
    lang_french_code = pp.nestedExpr('@fra\\', '@fra \\', content=enclosed)
    lang_french_code.setParseAction(_pa_lang_french)
    lang_german_code = pp.nestedExpr('@deu\\', '@deu \\', content=enclosed)
    lang_german_code.setParseAction(_pa_lang_german)
    lang_italian_code = pp.nestedExpr('@ita\\', '@ita \\', content=enclosed)
    lang_italian_code.setParseAction(_pa_lang_italian)
    lang_latin_code = pp.nestedExpr('@lat\\', '@lat \\', content=enclosed)
    lang_latin_code.setParseAction(_pa_lang_latin)
    lang_middle_cornish_code = pp.nestedExpr('@cnx\\', '@cnx \\',
                                             content=enclosed)
    lang_middle_cornish_code.setParseAction(_pa_lang_middle_cornish)
    lang_middle_high_german_code = pp.nestedExpr('@gmh\\', '@gmh \\',
                                                 content=enclosed)
    lang_middle_high_german_code.setParseAction(_pa_lang_middle_high_german)
    lang_middle_low_german_code = pp.nestedExpr('@gml\\', '@gml \\',
                                                content=enclosed)
    lang_middle_low_german_code.setParseAction(_pa_lang_middle_low_german)
    lang_middle_welsh_code = pp.nestedExpr('@wlm\\', '@wlm \\',
                                           content=enclosed)
    lang_middle_welsh_code.setParseAction(_pa_lang_middle_welsh)
    lang_portuguese_code = pp.nestedExpr('@por\\', '@por \\', content=enclosed)
    lang_portuguese_code.setParseAction(_pa_lang_portuguese)
    lang_scottish_gaelic_code = pp.nestedExpr('@gla\\', '@gla \\',
                                              content=enclosed)
    lang_scottish_gaelic_code.setParseAction(_pa_lang_scottish_gaelic)
    lang_spanish_code = pp.nestedExpr('@spa\\', '@spa \\', content=enclosed)
    lang_spanish_code.setParseAction(_pa_lang_spanish)
    lang_welsh_code = pp.nestedExpr('@cym\\', '@cym \\', content=enclosed)
    lang_welsh_code.setParseAction(_pa_lang_welsh)
    language_codes = (lang_ancient_greek_code ^ lang_anglo_french_code ^
                      lang_anglo_norman_code ^ lang_cornish_code ^
                      lang_english_code ^ lang_french_code ^ lang_german_code ^
                      lang_italian_code ^ lang_latin_code ^
                      lang_middle_cornish_code ^ lang_middle_high_german_code ^
                      lang_middle_low_german_code ^ lang_middle_welsh_code ^
                      lang_portuguese_code ^ lang_scottish_gaelic_code ^
                      lang_spanish_code ^ lang_welsh_code)
    exdented_code = pp.nestedExpr('@g\\', '@g \\', content=enclosed)
    exdented_code.setParseAction(_pa_exdented)
    footnote_code = pp.nestedExpr('@f\\', '@f \\', content=enclosed)
    footnote_code.setParseAction(_pa_footnote)
    indented_code = pp.nestedExpr('@p\\', '@p \\', content=enclosed)
    indented_code.setParseAction(_pa_indented)
    interlineation_above_code = pp.nestedExpr('@a\\', '@a \\', content=enclosed)
    interlineation_above_code.setParseAction(_pa_interlineation_above)
    interlineation_below_code = pp.nestedExpr('@b\\', '@b \\', content=enclosed)
    interlineation_below_code.setParseAction(_pa_interlineation_below)
    interpolation_code = pp.nestedExpr('@i\\', '@i \\', content=enclosed)
    interpolation_code.setParseAction(_pa_interpolation)
    italic_code = pp.nestedExpr('{', '}', content=enclosed)
    italic_code.setParseAction(_pa_italic)
    italic_small_caps_code = pp.nestedExpr('@q\\', '@q \\', content=enclosed)
    italic_small_caps_code.setParseAction(_pa_italic_small_caps)
    left_marginale_code = pp.nestedExpr('@l\\', '@l \\', content=enclosed)
    left_marginale_code.setParseAction(_pa_left_marginale)
    personnel_code = pp.nestedExpr('@x\\', '@x \\', content=enclosed)
    personnel_code.setParseAction(_pa_personnel)
    right_marginale_code = pp.nestedExpr('@r\\', '@r \\', content=enclosed)
    right_marginale_code.setParseAction(_pa_right_marginale)
    signed_code = pp.nestedExpr('@sn\\', '@sn \\', content=enclosed)
    signed_code.setParseAction(_pa_signed)
    signed_centre_code = pp.nestedExpr('@snc\\', '@snc \\', content=enclosed)
    signed_centre_code.setParseAction(_pa_signed_centre)
    signed_right_code = pp.nestedExpr('@snr\\', '@snr \\', content=enclosed)
    signed_right_code.setParseAction(_pa_signed_right)
    small_caps_code = pp.nestedExpr('@k\\', '@k \\', content=enclosed)
    small_caps_code.setParseAction(_pa_small_caps)
    superscript_code = pp.nestedExpr('@s\\', '@s \\', content=enclosed)
    superscript_code.setParseAction(_pa_superscript)
    tab_start_code = pp.nestedExpr(pp.LineStart() + pp.Literal('@['), '!',
                                   content=enclosed)
    tab_start_code.setParseAction(_pa_tab_start)
    paired_codes = bold_code ^ bold_italic_code ^ centred_code ^ comment_code ^ deleted_code ^ exdented_code ^ footnote_code ^ indented_code ^ interpolation_code ^ interlineation_above_code ^ interlineation_below_code ^ italic_code ^ italic_small_caps_code ^ language_codes ^ left_marginale_code ^ personnel_code ^ right_marginale_code ^ signed_code ^ signed_centre_code ^ signed_right_code ^ small_caps_code ^ superscript_code ^ tab_start_code
    enclosed << pp.OneOrMore(single_codes ^ return_code ^ paired_codes ^
                             content ^ punctuation ^ xml_escape ^ ignored)
    main_heading_sub_content = pp.OneOrMore(content | punctuation | xml_escape |
                                            ignored)
    main_heading_sub_content.setParseAction(_pa_main_heading_sub_content)
    language_code = pp.oneOf('lat eng xaf')
    main_heading_content = main_heading_sub_content + \
                           pp.Literal('!').suppress() + \
                           main_heading_sub_content + \
                           pp.Literal('!').suppress() + \
                           main_heading_sub_content + \
                           pp.Literal('!').suppress() + \
                           language_code
    main_heading_code = pp.nestedExpr('@h\\', '\\!',
                                      content=main_heading_content)
    main_heading_code.setParseAction(_pa_main_heading)
    subheading_code = pp.nestedExpr('@w\\', '\\!', content=enclosed)
    subheading_code.setParseAction(_pa_subheading)
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
    subsection = subheading_code + pp.OneOrMore(table ^ enclosed)
    subsection.setParseAction(_pa_subsection)
    main_section = pp.ZeroOrMore(white | ignored) + main_heading_code + \
                   pp.ZeroOrMore(white) + pp.OneOrMore(subsection)
    main_section.setParseAction(_pa_main_section)
    return pp.StringStart() + pp.OneOrMore(main_section) + pp.StringEnd()

def _make_foreign (lang_code, toks):
    return ['<foreign xml:lang="{}">{}</foreign>'.format(
        lang_code, ''.join(toks[0]))]

def _make_signed (s, loc, toks, rend_value=None):
    rend = ''
    if rend_value:
        rend = ' rend="{}"'.format(rend_value)
    return ['<seg type="signed"{}>'.format(rend), ''.join(toks[0]), '</seg>']

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
    return ['\N{LATIN SMALL LETTER TURNED V}']

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

def _pa_eng (s, loc, toks):
    return ['\N{LATIN SMALL LETTER ENG}']

def _pa_ENG (s, loc, toks):
    return ['\N{LATIN CAPITAL LETTER ENG}']

def _pa_eth (s, loc, toks):
    return ['\N{LATIN SMALL LETTER ETH}']

def _pa_exclamation (s, loc, toks):
    return ['!']

def _pa_exdented (s, loc, toks):
    return ['<ab type="body_p_exdented">', ''.join(toks[0]), '</ab>']

def _pa_footnote (s, loc, toks):
    return ['<note type="foot">', ''.join(toks[0]), '</note>']

def _pa_grave (s, loc, toks):
    return ['{}\N{COMBINING GRAVE ACCENT}'.format(toks[1])]

def _pa_indented (s, loc, toks):
    return ['<ab type="body_p_indented">', ''.join(toks[0]), '</ab>']

def _pa_interlineation_above (s, loc, toks):
    return ['<add place="above">', ''.join(toks[0]), '</add>']

def _pa_interlineation_below (s, loc, toks):
    return ['<add place="below">', ''.join(toks[0]), '</add>']

def _pa_interpolation (s, loc, toks):
    return ['<add><handShift />', ''.join(toks[0]), '</add>']

def _pa_italic (s, loc, toks):
    return ['<hi rend="italic">', ''.join(toks[0]), '</hi>']

def _pa_italic_small_caps (s, loc, toks):
    return ['<hi rend="smallcaps_italic">', ''.join(toks[0]), '</hi>']

def _pa_lang_ancient_greek (s, loc, toks):
    return _make_foreign('grc', toks)

def _pa_lang_anglo_french (s, loc, toks):
    return _make_foreign('xaf', toks)

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
    return ['<note type="marginal" place="margin_left" n="CHANGE_ME_TO_XMLID">',
            ''.join(toks[0]), '</note>']

def _pa_macron (s, loc, toks):
    return ['{}\N{COMBINING MACRON}'.format(toks[1])]

def _pa_main_heading (s, loc, toks):
    place, date, code, language_code = toks[0]
    return [language_code, '<head type="main"><name type="place_region">{}</name> <date>{}</date></head>'.format(place, date)]

def _pa_main_heading_sub_content (s, loc, toks):
    return [''.join(toks)]

def _pa_main_section (s, loc, toks):
    return ['<div xml:lang="{}">{}</div>'.format(toks[0], ''.join(toks[1:]))]

def _pa_oe (s, loc, toks):
    return ['\N{LATIN SMALL LIGATURE OE}']

def _pa_OE (s, loc, toks):
    return ['\N{LATIN CAPITAL LIGATURE OE}']

def _pa_paragraph (s, loc, toks):
    return ['\N{PILCROW SIGN}']

def _pa_personnel (s, loc, toks):
    return ['<note type="eccles_court">', ''.join(toks[0]), '</note>']

def _pa_pound (s, loc, toks):
    return ['\N{POUND SIGN}']

def _pa_raised (s, loc, toks):
    return ['\N{MIDDLE DOT}']

def _pa_return (s, loc, toks):
    # TODO: Perhaps add newlines here to deal with the case of long
    # lines in the source?
    return ['<lb />']

def _pa_right_marginale (s, loc, toks):
    return ['<note type="marginal" place="margin_right" n="CHANGE_ME_TO_XMLID">',
            ''.join(toks[0]), '</note>']

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

def _pa_subheading (s, loc, toks):
    return ['<head type="sub">', ''.join(toks[0]), '</head>']

def _pa_subsection (s, loc, toks):
    return ['<div type="subsection">', ''.join(toks), '</div>']

def _pa_superscript (s, loc, toks):
    return ['<hi rend="superscript">', ''.join(toks[0]), '</hi>']

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
