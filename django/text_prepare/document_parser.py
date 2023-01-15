"""This module defines a grammar for parsing a records document marked
up using various @-codes and converting it to TEI.

The basic TEI structure generated is:

<text type="record">
  <body>
    <head>...</head>
    <div xml:lang="..." type="transcription">
      <div>
        <head>...</head>
        ...
      </div>
      ...
    </div>
    <div type="translation">
      <div>
        <head>...</head>
        ...
      </div>
      ...
    </div>
    <div type="endnote">
      ...
    </div>
  </body>
</text>
...

The grammar does not enforce referential integrity, and does not
produce xml:ids except for msDesc and bibl elements.

It also produces document descriptions in the form of tei:bibl and
tei:msDesc elements.

"""

import html

import pyparsing as pp


class DocumentParser:

    def __init__(self):
        self._place_codes = {}
        self._source_codes = []
        self._source_code = None
        self._grammar = self._define_grammar()

    def _define_grammar(self):
        content = pp.Word(pp.alphanums + ' ' + '\n')
        content.setWhitespaceChars('')
        content.setDefaultWhitespaceChars('')
        white = pp.Word(' ' + '\n')
        punctuation_chars = '. , ; : \' " ( ) * / # $ % + - ? – _ ='
        punctuation = pp.oneOf(punctuation_chars)
        rich_content = pp.Word(pp.alphanums + ' \\\n&[]' + punctuation_chars)
        rich_content.setWhitespaceChars('')
        rich_content.setParseAction(self._pa_rich_content)
        content.setDefaultWhitespaceChars('')
        integer = pp.Word(pp.nums)
        ignored = pp.oneOf('\ufeff').suppress()  # zero width no-break space
        # This is an awful cludge for < to get around my inability to find
        # a way for pyparsing to handle tables correctly (despite
        # damaged_code working fine). With luck there won't be any < in
        # the text content.
        xml_escape = pp.oneOf('& >') | (pp.Literal('<') + pp.FollowedBy(
            white | ignored | integer))
        xml_escape.setParseAction(self._pa_xml_escape)
        blank = pp.Suppress(pp.ZeroOrMore(white | ignored))
        vowels = pp.oneOf('A a E e I i O o U u')
        acute_code = pp.Literal("@'") + vowels
        acute_code.setParseAction(self._pa_acute)
        ae_code = pp.Literal('@ae').setParseAction(self._pa_ae)
        AE_code = pp.Literal('@AE').setParseAction(self._pa_AE)
        blank_code = pp.Literal('{{(blank)}}').setParseAction(self._pa_blank)
        capitulum_code = pp.Literal('@C').setParseAction(self._pa_capitulum)
        caret_code = pp.Literal('^').setParseAction(self._pa_caret)
        cedilla_code = pp.Literal('@?') + (vowels ^ 'c')
        cedilla_code.setParseAction(self._pa_cedilla)
        circumflex_code = pp.Literal('@^') + vowels
        circumflex_code.setParseAction(self._pa_circumflex)
        damaged_code = pp.Literal('<') + (pp.Word('.', min=1) ^
                                          pp.Literal('…')) + pp.Literal('>')
        damaged_code.setParseAction(self._pa_damaged)
        dot_over_code = pp.Literal('@.') + pp.Regex(r'[A-Za-z]')
        dot_over_code.setParseAction(self._pa_dot_over)
        dot_under_code = pp.Literal('@#') + pp.Regex(r'[A-Za-z]')
        dot_under_code.setParseAction(self._pa_dot_under)
        ellipsis_code = pp.Literal('...') ^ pp.Literal('…')
        ellipsis_code.setParseAction(self._pa_ellipsis)
        en_dash_code = pp.Literal('--').setParseAction(self._pa_en_dash)
        eng_code = pp.Literal('@n').setParseAction(self._pa_eng)
        ENG_code = pp.Literal('@N').setParseAction(self._pa_ENG)
        eth_code = pp.Literal('@d').setParseAction(self._pa_eth)
        exclamation_code = pp.Literal('@!').setParseAction(
            self._pa_exclamation)
        grave_code = pp.Literal('@,') + vowels
        grave_code.setParseAction(self._pa_grave)
        illegible_code = pp.Literal('@') + integer + pp.Literal('gi')
        illegible_code.setParseAction(self._pa_illegible)
        macron_code = pp.Literal('@-') + vowels
        macron_code.setParseAction(self._pa_macron)
        oe_code = pp.Literal('@oe').setParseAction(self._pa_oe)
        OE_code = pp.Literal('@OE').setParseAction(self._pa_OE)
        page_break_code = pp.Literal('|').setParseAction(self._pa_page_break)
        paragraph_code = pp.Literal('@P').setParseAction(self._pa_paragraph)
        pound_code = pp.Literal('@$').setParseAction(self._pa_pound)
        raised_code = pp.Literal('@*').setParseAction(self._pa_raised)
        return_code = pp.Literal('!').setParseAction(self._pa_return)
        section_code = pp.Literal('@%').setParseAction(self._pa_section)
        semicolon_code = pp.Literal('@;').setParseAction(self._pa_semicolon)
        special_v_code = pp.Literal('@v').setParseAction(self._pa_special_v)
        square_bracket_close_code = pp.Literal('@DOUBLE_SQUARE_CLOSE').setParseAction(
            self._pa_square_bracket_close)
        square_bracket_open_code = pp.Literal('@DOUBLE_SQUARE_OPEN').setParseAction(
            self._pa_square_bracket_open)
        thorn_code = pp.Literal('@th').setParseAction(self._pa_thorn)
        THORN_code = pp.Literal('@TH').setParseAction(self._pa_THORN)
        tilde_code = pp.Literal('@"') + (vowels | pp.Literal('n'))
        tilde_code.setParseAction(self._pa_tilde)
        umlaut_code = pp.Literal('@:') + vowels
        umlaut_code.setParseAction(self._pa_umlaut)
        wynn_code = pp.Literal('@y').setParseAction(self._pa_wynn)
        yogh_code = pp.Literal('@z').setParseAction(self._pa_yogh)
        YOGH_code = pp.Literal('@Z').setParseAction(self._pa_YOGH)
        single_codes = (
            acute_code ^ ae_code ^ AE_code ^ blank_code ^ capitulum_code ^
            caret_code ^ cedilla_code ^ circumflex_code ^
            damaged_code ^ dot_over_code ^ dot_under_code ^ ellipsis_code ^
            en_dash_code ^ eng_code ^ ENG_code ^ eth_code ^ exclamation_code ^
            grave_code ^ illegible_code ^ macron_code ^ oe_code ^ OE_code ^
            page_break_code ^ paragraph_code ^ pound_code ^ raised_code ^
            section_code ^ semicolon_code ^ special_v_code ^
            square_bracket_close_code ^ square_bracket_open_code ^ thorn_code ^
            THORN_code ^ tilde_code ^ umlaut_code ^ wynn_code ^ yogh_code ^
            YOGH_code)
        enclosed = pp.Forward()
        centred_code = pp.nestedExpr('@m\\', '@m/', content=enclosed)
        centred_code.setParseAction(self._pa_centred)
        closer_code = pp.nestedExpr('@cl\\', '@cl/', content=enclosed)
        closer_code.setParseAction(self._pa_closer)
        collation_note = pp.nestedExpr('@c\\', '@c/', content=enclosed)
        collation_note.setParseAction(self._pa_collation_note)
        comment_code = pp.nestedExpr('@xc\\', '@xc/', content=enclosed)
        comment_code.setParseAction(self._pa_comment)
        deleted_code = pp.nestedExpr('[', ']', content=enclosed)
        deleted_code.setParseAction(self._pa_deleted)
        italic_code = pp.nestedExpr('@it\\', '@it/', content=enclosed)
        italic_code.setParseAction(self._pa_italic)
        lang_ancient_greek_code = pp.nestedExpr('@grc\\', '@grc/',
                                                content=enclosed)
        lang_ancient_greek_code.setParseAction(self._pa_lang_ancient_greek)
        lang_anglo_norman_code = pp.nestedExpr('@xno\\', '@xno/',
                                               content=enclosed)
        lang_anglo_norman_code.setParseAction(self._pa_lang_anglo_norman)
        lang_cornish_code = pp.nestedExpr('@cor\\', '@cor/', content=enclosed)
        lang_cornish_code.setParseAction(self._pa_lang_cornish)
        lang_english_code = pp.nestedExpr('@eng\\', '@eng/', content=enclosed)
        lang_english_code.setParseAction(self._pa_lang_english)
        lang_french_code = pp.nestedExpr('@fra\\', '@fra/', content=enclosed)
        lang_french_code.setParseAction(self._pa_lang_french)
        # Due to the @d code for eth and my inability to deal usefully
        # with pyparsing, use @ger for German rather than @deu.
        lang_german_code = pp.nestedExpr('@ger\\', '@ger/', content=enclosed)
        lang_german_code.setParseAction(self._pa_lang_german)
        lang_italian_code = pp.nestedExpr('@ita\\', '@ita/', content=enclosed)
        lang_italian_code.setParseAction(self._pa_lang_italian)
        lang_latin_code = pp.nestedExpr('@lat\\', '@lat/', content=enclosed)
        lang_latin_code.setParseAction(self._pa_lang_latin)
        lang_middle_cornish_code = pp.nestedExpr('@cnx\\', '@cnx/',
                                                 content=enclosed)
        lang_middle_cornish_code.setParseAction(self._pa_lang_middle_cornish)
        lang_middle_high_german_code = pp.nestedExpr('@gmh\\', '@gmh/',
                                                     content=enclosed)
        lang_middle_high_german_code.setParseAction(
            self._pa_lang_middle_high_german)
        lang_middle_low_german_code = pp.nestedExpr('@gml\\', '@gml/',
                                                    content=enclosed)
        lang_middle_low_german_code.setParseAction(
            self._pa_lang_middle_low_german)
        lang_middle_welsh_code = pp.nestedExpr('@wlm\\', '@wlm/',
                                               content=enclosed)
        lang_middle_welsh_code.setParseAction(self._pa_lang_middle_welsh)
        lang_old_english_code = pp.nestedExpr('@ang\\', '@ang/',
                                              content=enclosed)
        lang_old_english_code.setParseAction(self._pa_lang_old_english)
        lang_portuguese_code = pp.nestedExpr('@por\\', '@por/',
                                             content=enclosed)
        lang_portuguese_code.setParseAction(self._pa_lang_portuguese)
        lang_scottish_gaelic_code = pp.nestedExpr('@gla\\', '@gla/',
                                                  content=enclosed)
        lang_scottish_gaelic_code.setParseAction(self._pa_lang_scottish_gaelic)
        lang_spanish_code = pp.nestedExpr('@spa\\', '@spa/', content=enclosed)
        lang_spanish_code.setParseAction(self._pa_lang_spanish)
        lang_welsh_code = pp.nestedExpr('@cym\\', '@cym/', content=enclosed)
        lang_welsh_code.setParseAction(self._pa_lang_welsh)
        language_codes = (
            lang_ancient_greek_code ^ lang_anglo_norman_code ^
            lang_cornish_code ^ lang_english_code ^ lang_french_code ^
            lang_german_code ^ lang_italian_code ^ lang_latin_code ^
            lang_middle_cornish_code ^ lang_middle_high_german_code ^
            lang_middle_low_german_code ^ lang_middle_welsh_code ^
            lang_old_english_code ^ lang_portuguese_code ^
            lang_scottish_gaelic_code ^ lang_spanish_code ^ lang_welsh_code)
        exdented_code = pp.nestedExpr('@g\\', '@g/', content=enclosed)
        exdented_code.setParseAction(self._pa_exdented)
        expansion_code = pp.nestedExpr('{{', '}}', content=enclosed)
        expansion_code.setParseAction(self._pa_expansion)
        footnote_code = pp.nestedExpr('@f\\', '@f/', content=enclosed)
        footnote_code.setParseAction(self._pa_footnote)
        indented_code = pp.nestedExpr('@p\\', '@p/', content=enclosed)
        indented_code.setParseAction(self._pa_indented)
        interlineation_above_code = pp.nestedExpr('@a\\', '@a/',
                                                  content=enclosed)
        interlineation_above_code.setParseAction(self._pa_interlineation_above)
        interlineation_below_code = pp.nestedExpr('@b\\', '@b/',
                                                  content=enclosed)
        interlineation_below_code.setParseAction(self._pa_interlineation_below)
        interpolation_code = pp.nestedExpr('@i\\', '@i/', content=enclosed)
        interpolation_code.setParseAction(self._pa_interpolation)
        left_marginale_code = pp.nestedExpr('@l\\', '@l/', content=enclosed)
        left_marginale_code.setParseAction(self._pa_left_marginale)
        line_group_contents = pp.Forward()
        line_code = pp.nestedExpr('@ln\\', '@ln/', content=enclosed)
        line_code.setParseAction(self._pa_line)
        line_indented_code = pp.nestedExpr('@lni\\', '@lni/', content=enclosed)
        line_indented_code.setParseAction(self._pa_line_indented)
        line_group_code = pp.nestedExpr('@lg\\', '@lg/',
                                        content=line_group_contents)
        line_group_code.setParseAction(self._pa_line_group)
        line_group_contents << (
            pp.OneOrMore(blank + line_group_code + blank) ^
            pp.OneOrMore((blank + line_code + blank) |
                         (blank + line_indented_code + blank))
        )
        list_item_code = pp.nestedExpr('@li\\', '@li/', content=enclosed)
        list_item_code.setParseAction(self._pa_list_item_code)
        list_code = pp.nestedExpr('@ul\\', '@ul/', content=pp.OneOrMore(
            blank + list_item_code + blank))
        list_code.setParseAction(self._pa_list_code)
        right_marginale_code = pp.nestedExpr('@r\\', '@r/', content=enclosed)
        right_marginale_code.setParseAction(self._pa_right_marginale)
        signed_code = pp.nestedExpr('@sn\\', '@sn/', content=enclosed)
        signed_code.setParseAction(self._pa_signed)
        signed_centre_code = pp.nestedExpr('@snc\\', '@snc/', content=enclosed)
        signed_centre_code.setParseAction(self._pa_signed_centre)
        signed_right_code = pp.nestedExpr('@snr\\', '@snr/', content=enclosed)
        signed_right_code.setParseAction(self._pa_signed_right)
        signed_mark_code = pp.nestedExpr('@sm\\', '@sm/', content=enclosed)
        signed_mark_code.setParseAction(self._pa_signed_mark)
        signed_mark_centre_code = pp.nestedExpr('@smc\\', '@smc/',
                                                content=enclosed)
        signed_mark_centre_code.setParseAction(self._pa_signed_mark_centre)
        signed_mark_right_code = pp.nestedExpr('@smr\\', '@smr/',
                                               content=enclosed)
        signed_mark_right_code.setParseAction(self._pa_signed_mark_right)
        superscript_code = pp.nestedExpr('@s\\', '@s/', content=enclosed)
        superscript_code.setParseAction(self._pa_superscript)
        tab_start_code = pp.nestedExpr(pp.LineStart() + '@[', '@]',
                                       content=enclosed)
        tab_start_code.setParseAction(self._pa_tab_start)
        title_code = pp.nestedExpr('<title>', '</title>', content=enclosed)
        title_code.setParseAction(self._pa_title)
        paired_codes = (
            centred_code ^ closer_code ^ collation_note ^ comment_code ^
            deleted_code ^ exdented_code ^ expansion_code ^ footnote_code ^
            indented_code ^ interpolation_code ^ interlineation_above_code ^
            interlineation_below_code ^ italic_code ^ language_codes ^
            left_marginale_code ^ line_group_code ^ list_code ^
            right_marginale_code ^ signed_code ^ signed_centre_code ^
            signed_right_code ^ signed_mark_code ^ signed_mark_centre_code ^
            signed_mark_right_code ^ superscript_code ^ tab_start_code ^
            title_code)
        enclosed << pp.OneOrMore(single_codes ^ return_code ^ paired_codes ^
                                 content ^ punctuation ^ xml_escape ^ ignored)
        cell = pp.nestedExpr('<c>', '</c>', content=enclosed)
        cell.setParseAction(self._pa_cell)
        cell_centre = pp.nestedExpr('<cc>', '</cc>', content=enclosed)
        cell_centre.setParseAction(self._pa_cell_centre)
        cell_right = pp.nestedExpr('<cr>', '</cr>', content=enclosed)
        cell_right.setParseAction(self._pa_cell_right)
        row = pp.nestedExpr('<r>', '</r>', content=pp.OneOrMore(
            cell | cell_centre | cell_right | comment_code | white))
        row.setParseAction(self._pa_row)
        table = pp.nestedExpr('<t>', '</t>', content=pp.OneOrMore(
            row | comment_code | white))
        table.setParseAction(self._pa_table)
        record_heading_place = pp.Word(pp.alphanums)
        record_heading_place.setParseAction(self._pa_record_heading_place)
        year = pp.Word(pp.nums, min=3, max=4)
        record_heading_date_century = pp.Word(
            pp.nums, min=2, max=2).setResultsName('century') + \
            pp.Literal('th Century').setResultsName('label')
        record_heading_date_century.setParseAction(
            self._pa_record_heading_date_century)
        circa = pp.Literal('@it\\c@it/ ').setParseAction(self._pa_circa)
        slash_year = pp.Literal('/') + pp.Word(pp.nums, min=1, max=4)
        start_year = pp.Optional(circa).setResultsName('circa') + \
            year.setResultsName('year') + \
            pp.Optional(slash_year).setResultsName('slash_year')
        end_year = pp.Word(pp.nums, min=1, max=4).setResultsName('end_year') \
            + pp.Optional(slash_year).setResultsName('slash_end_year')
        record_heading_date_year = start_year + pp.Optional(pp.oneOf('- –') +
                                                            end_year)
        record_heading_date_year.setParseAction(
            self._pa_record_heading_date_year)
        record_heading_date = record_heading_date_century ^ \
            record_heading_date_year ^ pp.Literal('Undated')
        language_code = pp.oneOf(
            'ang cnx cor cym deu eng fra gla gmh gml grc ita lat por spa wlm '
            'xno')
        record_heading_content = record_heading_place - \
            pp.Literal('!').suppress() - record_heading_date - \
            pp.Literal('!').suppress() - language_code
        record_heading = pp.nestedExpr('@h\\', '\\!',
                                       content=record_heading_content)
        record_heading.setParseAction(self._pa_record_heading)
        # A special content model is required for transcription headings,
        # since [] does not mean deleted material there.
        supplied_code = pp.nestedExpr('{{', '}}', content=enclosed)
        supplied_code.setParseAction(self._pa_supplied)
        transcription_heading_content = pp.OneOrMore(
            single_codes ^ pp.Word(pp.alphanums + ' []-–') ^ punctuation ^
            xml_escape ^ ignored ^ supplied_code)
        transcription_heading = pp.nestedExpr(
            '@w\\', '\\!', content=transcription_heading_content)
        transcription_heading.setParseAction(self._pa_transcription_heading)
        transcription_section = blank + transcription_heading - pp.OneOrMore(
            table ^ enclosed)
        transcription_section.setParseAction(self._pa_transcription_section)
        transcription = pp.OneOrMore(transcription_section)
        transcription.setParseAction(self._pa_transcription)
        translation = pp.nestedExpr(
            '@tr\\', '@tr/', content=pp.OneOrMore(transcription_section))
        translation.setParseAction(self._pa_translation)
        end_note = pp.nestedExpr('@en\\', '@en/', content=enclosed)
        end_note.setParseAction(self._pa_endnote)
        end_note_wrapper = blank + end_note + blank
        source_code = blank + pp.nestedExpr(
            '@sc\\', '@sc/', content=pp.Word(pp.srange('[A-Z0-9]'), exact=6))
        source_code.setParseAction(self._pa_source_code)
        source_head = blank + pp.nestedExpr('@sh\\', '@sh/',
                                            content=rich_content)
        source_head.setParseAction(self._pa_source_data)
        source_location = blank + pp.nestedExpr('@sl\\', '@sl/',
                                                content=rich_content)
        source_location.setParseAction(self._pa_source_data)
        source_repository = blank + pp.nestedExpr('@sr\\', '@sr/',
                                                  content=rich_content)
        source_repository.setParseAction(self._pa_source_data)
        source_shelfmark = blank + pp.nestedExpr('@ss\\', '@ss/',
                                                 content=enclosed)
        source_shelfmark.setParseAction(self._pa_source_data)
        source_date = blank + pp.nestedExpr('@st\\', '@st/',
                                            content=rich_content)
        source_date.setParseAction(self._pa_source_date)
        ms_source_data = source_code - source_head - source_location - \
            source_repository - source_shelfmark
        ms_source_data.setParseAction(self._pa_ms_source_data)
        ms_ed_desc = enclosed.copy().setParseAction(self._pa_ms_ed_desc)
        ms_tech_desc = source_date + enclosed.copy()
        ms_tech_desc.setParseAction(self._pa_ms_tech_desc)
        ms_doc_desc_contents = pp.Optional(ms_ed_desc) + ms_source_data - \
            ms_tech_desc
        ms_doc_desc = pp.nestedExpr('@md\\', '@md/',
                                    content=ms_doc_desc_contents)
        ms_doc_desc = ms_doc_desc.setResultsName('doc_desc',
                                                 listAllMatches=True)
        ms_doc_desc.setParseAction(self._pa_ms_doc_desc)
        print_source_data = source_code - source_head
        print_source_data.setParseAction(self._pa_print_source_data)
        print_ed_desc = enclosed.copy().setParseAction(self._pa_print_ed_desc)
        print_tech_desc = enclosed.copy().setParseAction(
            self._pa_print_tech_desc)
        print_doc_desc_contents = pp.Optional(print_ed_desc) + \
            print_source_data - print_tech_desc
        print_doc_desc = pp.nestedExpr('@pd\\', '@pd/',
                                       content=print_doc_desc_contents)
        print_doc_desc = print_doc_desc.setResultsName('doc_desc',
                                                       listAllMatches=True)
        print_doc_desc.setParseAction(self._pa_print_doc_desc)
        abbreviation = pp.nestedExpr('@ab\\', '@ab/', content=pp.Word(
            pp.alphanums))
        expansion = pp.nestedExpr('@ex\\', '@ex/', content=rich_content)
        county = pp.nestedExpr('@ct\\', '@ct/', content=content)
        place_code = blank + abbreviation + blank + expansion + blank + \
            county + blank
        place_code.setParseAction(self._pa_place_code)
        place_codes = pp.nestedExpr('@pc\\', '@pc/',
                                    content=pp.OneOrMore(place_code))
        preamble = (ms_doc_desc ^ print_doc_desc) - blank - pp.Optional(
            comment_code + blank) - place_codes
        record = (blank + record_heading + transcription +
                  pp.Optional(translation) +
                  pp.Optional(end_note_wrapper)).setResultsName(
                      'record', listAllMatches=True)
        record.setParseAction(self._pa_record)
        return pp.StringStart() + blank + preamble + pp.OneOrMore(record) \
            + pp.StringEnd()

    def parse(self, text):
        return self._grammar.parseString(text)

    def _get_page_type(self, data):
        """Return the expanded page type indicated by the abbreviation `data`,
        or an empty string if not match is found."""
        ptype = ''
        if data in ('f', 'ff', 'folio', 'folios'):
            ptype = 'folio'
        elif data in ('mb', 'mbs', 'membrane', 'membranes'):
            ptype = 'membrane'
        elif data in ('p', 'pp', 'page', 'pages'):
            ptype = 'page'
        elif data in ('sheet', 'sheets'):
            ptype = 'sheet'
        elif data in ('sig', 'sigs', 'signature', 'signatures'):
            ptype = 'signature'
        return ptype

    def _make_foreign(self, lang_code, toks):
        return ['<foreign xml:lang="{}">{}</foreign>'.format(
            lang_code, ''.join(toks[0]))]

    def _make_signed(self, s, loc, toks, rend_value=None):
        rend = ''
        if rend_value:
            rend = ' rend="{}"'.format(rend_value)
        return ['<seg type="signed"{}>'.format(rend), ''.join(toks[0]),
                '</seg>']

    def _make_signed_mark(self, s, loc, toks, rend_value=None):
        rend = ''
        if rend_value:
            rend = ' rend="{}"'.format(rend_value)
        return ['<seg type="signed_mark"{}>'.format(rend), ''.join(toks[0]),
                '</seg>']

    def _merge_years(self, year, replacement):
        """Return `year` merged with `replacement`, where `replacement`
        replaces the last digit(s) of `year`."""
        changed = 4 - len(replacement)
        base = year[:changed]
        return base + replacement

    def _pa_acute(self, s, loc, toks):
        return ['{}\N{COMBINING ACUTE ACCENT}'.format(toks[1])]

    def _pa_ae(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER AE}']

    def _pa_AE(self, s, loc, toks):
        return ['\N{LATIN CAPITAL LETTER AE}']

    def _pa_blank(self, s, loc, toks):
        return ['<space />']

    def _pa_capitulum(self, s, loc, toks):
        # The name CAPITULUM is not recognised in Python 3.4, causing
        # a syntax error of all things.
        return ['\u2e3f']

    def _pa_caret(self, s, loc, toks):
        return ['\N{CARET}']

    def _pa_cedilla(self, s, loc, toks):
        return ['{}\N{COMBINING CEDILLA}'.format(toks[1])]

    def _pa_cell(self, s, loc, toks):
        return ['<cell>', ''.join(toks[0]), '</cell>']

    def _pa_cell_centre(self, s, loc, toks):
        return ['<cell rend="center">', ''.join(toks[0]), '</cell>']

    def _pa_cell_right(self, s, loc, toks):
        return ['<cell rend="right">', ''.join(toks[0]), '</cell>']

    def _pa_centred(self, s, loc, toks):
        return ['<ab rend="center">', ''.join(toks[0]), '</ab>']

    def _pa_circa(self, s, loc, toks):
        return ['<hi rend="italic">c</hi> ']

    def _pa_circumflex(self, s, loc, toks):
        return ['{}\N{COMBINING CIRCUMFLEX ACCENT}'.format(toks[1])]

    def _pa_closer(self, s, loc, toks):
        return ['<closer>', ''.join(toks[0]), '</closer>']

    def _pa_collation_note(self, s, loc, toks):
        return ['<note type="collation">', ''.join(toks[0]), '</note>']

    def _pa_comment(self, s, loc, toks):
        return ['<!-- ', ''.join(toks[0]), ' -->']

    def _pa_damaged(self, s, loc, toks):
        return ['<damage><gap unit="chars" extent="{}" /></damage>'.format(
            len(toks[1]))]

    def _pa_deleted(self, s, loc, toks):
        return ['<del>', ''.join(toks[0]), '</del>']

    def _pa_dot_over(self, s, loc, toks):
        return ['{}\N{COMBINING DOT ABOVE}'.format(toks[1])]

    def _pa_dot_under(self, s, loc, toks):
        return ['{}\N{COMBINING DOT BELOW}'.format(toks[1])]

    def _pa_ellipsis(self, s, loc, toks):
        return ['<gap reason="omitted" />']

    def _pa_en_dash(self, s, loc, toks):
        return ['\N{EN DASH}']

    def _pa_endnote(self, s, loc, toks):
        return ['<div type="endnote">\n', ''.join(toks[0]), '\n</div>\n']

    def _pa_eng(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER ENG}']

    def _pa_ENG(self, s, loc, toks):
        return ['\N{LATIN CAPITAL LETTER ENG}']

    def _pa_eth(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER ETH}']

    def _pa_exclamation(self, s, loc, toks):
        return ['!']

    def _pa_exdented(self, s, loc, toks):
        return ['<ab type="exdent">', ''.join(toks[0]), '</ab>']

    def _pa_expansion(self, s, loc, toks):
        return ['<ex>', ''.join(toks[0]), '</ex>']

    def _pa_footnote(self, s, loc, toks):
        return ['<note type="foot">', ''.join(toks[0]), '</note>']

    def _pa_grave(self, s, loc, toks):
        return ['{}\N{COMBINING GRAVE ACCENT}'.format(toks[1])]

    def _pa_illegible(self, s, loc, toks):
        return ['<gap extent="{}" reason="illegible" unit="chars" />'.format(
            toks[1])]

    def _pa_indented(self, s, loc, toks):
        return ['<ab type="indent">', ''.join(toks[0]), '</ab>']

    def _pa_interlineation_above(self, s, loc, toks):
        return ['<add place="above">', ''.join(toks[0]), '</add>']

    def _pa_interlineation_below(self, s, loc, toks):
        return ['<add place="below">', ''.join(toks[0]), '</add>']

    def _pa_interpolation(self, s, loc, toks):
        return ['<handShift />', ''.join(toks[0]), '<handShift />']

    def _pa_italic(self, s, loc, toks):
        return ['<hi rend="italic">', ''.join(toks[0]), '</hi>']

    def _pa_lang_ancient_greek(self, s, loc, toks):
        return self._make_foreign('grc', toks)

    def _pa_lang_anglo_norman(self, s, loc, toks):
        return self._make_foreign('xno', toks)

    def _pa_lang_cornish(self, s, loc, toks):
        return self._make_foreign('cor', toks)

    def _pa_lang_english(self, s, loc, toks):
        return self._make_foreign('eng', toks)

    def _pa_lang_french(self, s, loc, toks):
        return self._make_foreign('fra', toks)

    def _pa_lang_german(self, s, loc, toks):
        return self._make_foreign('deu', toks)

    def _pa_lang_italian(self, s, loc, toks):
        return self._make_foreign('ita', toks)

    def _pa_lang_latin(self, s, loc, toks):
        return self._make_foreign('lat', toks)

    def _pa_lang_middle_cornish(self, s, loc, toks):
        return self._make_foreign('cnx', toks)

    def _pa_lang_middle_high_german(self, s, loc, toks):
        return self._make_foreign('gmh', toks)

    def _pa_lang_middle_low_german(self, s, loc, toks):
        return self._make_foreign('gml', toks)

    def _pa_lang_middle_welsh(self, s, loc, toks):
        return self._make_foreign('wlm', toks)

    def _pa_lang_old_english(self, s, loc, toks):
        return self._make_foreign('ang', toks)

    def _pa_lang_portuguese(self, s, loc, toks):
        return self._make_foreign('por', toks)

    def _pa_lang_scottish_gaelic(self, s, loc, toks):
        return self._make_foreign('gla', toks)

    def _pa_lang_spanish(self, s, loc, toks):
        return self._make_foreign('spa', toks)

    def _pa_lang_welsh(self, s, loc, toks):
        return self._make_foreign('cym', toks)

    def _pa_left_marginale(self, s, loc, toks):
        return ['<note type="marginal" place="margin_left">', ''.join(toks[0]),
                '</note>']

    def _pa_line(self, s, loc, toks):
        return ['<l>', ''.join(toks[0]), '</l>']

    def _pa_line_group(self, s, loc, toks):
        return ['<lg>', ''.join(toks[0]), '</lg>']

    def _pa_line_indented(self, s, loc, toks):
        return ['<l rend="indent">', ''.join(toks[0]), '</l>']

    def _pa_list_item_code(self, s, loc, toks):
        return ['<item>', ''.join(toks[0]), '</item>']

    def _pa_list_code(self, s, loc, toks):
        return ['<list>', ''.join(toks[0]), '</list>']

    def _pa_macron(self, s, loc, toks):
        return ['{}\N{COMBINING MACRON}'.format(toks[1])]

    def _pa_ms_doc_desc(self, s, loc, toks):
        if len(toks[0]) < 4:
            toks[0].insert(0, '')
        elif len(toks[0]) == 5:
            # This is a bizarre problem I do not understand when an
            # apostrophe occurs at the start of the @md and it
            # contains at least one other apostrophe, in which case
            # the ed desc skips to after the second apostrophe, and we
            # end up with the skipped text as an extra token
            # here. WTF?
            #
            # So instead of dealing with the problem properly in the
            # grammar, since I don't have a clue what is going on,
            # just alert that the initial apostrophe needs to be
            # removed and then added back later. I can't just cludge
            # the skipped text in because it throws out some
            # whitespace too ("'text' foo" -> ["'text'", "foo"]).
            raise pp.ParseFatalException('@md begins with an apostrophe. For reasons unknown, this causes a problem. Please remove that initial apostrophe, validate/convert, and then add it back (to the Word document and TEI)')
        ed_desc, source_code, ms_identifier, tech_desc = toks[0]
        return '''<msDesc xml:id="{}">
{}
{}{}
</msDesc>'''.format(source_code, ms_identifier, ed_desc, tech_desc)

    def _pa_ms_ed_desc(self, s, loc, toks):
        text = ''.join(toks).strip()
        output = ['']
        if text:
            output = ['<ab type="edDesc">{}</ab>\n'.format(text)]
        return output

    def _pa_ms_source_data(self, s, loc, toks):
        source_code, ms_name, settlement, repository, shelfmark = toks
        return [source_code, '''<msIdentifier>
<settlement>{}</settlement>
<repository>{}</repository>
<idno type="shelfmark">{}</idno>
<msName>{}</msName>
</msIdentifier>'''.format(settlement, repository, shelfmark, ms_name)]

    def _pa_ms_tech_desc(self, s, loc, toks):
        return '<ab type="techDesc">{}</ab>'.format(''.join(toks).strip())

    def _pa_oe(self, s, loc, toks):
        return ['\N{LATIN SMALL LIGATURE OE}']

    def _pa_OE(self, s, loc, toks):
        return ['\N{LATIN CAPITAL LIGATURE OE}']

    def _pa_page_break(self, s, loc, toks):
        return ['<pb />']

    def _pa_paragraph(self, s, loc, toks):
        return ['\N{PILCROW SIGN}']

    def _pa_place_code(self, s, loc, toks):
        abbr = toks[0][0]
        name = toks[1][0]
        county = toks[2][0]
        self._place_codes[abbr] = (county, name)
        return []

    def _pa_print_doc_desc(self, s, loc, toks):
        if len(toks[0]) < 4:
            toks[0].insert(0, '')
        ed_desc, source_code, ed_title, tech_desc = toks[0]
        return '''<bibl xml:id="{}">
{}
{}{}
</bibl>'''.format(source_code, ed_title, ed_desc, tech_desc)

    def _pa_print_ed_desc(self, s, loc, toks):
        text = ''.join(toks).strip()
        output = ['']
        if text:
            output = ['<note type="edDesc"><p>{}</p></note>\n'.format(text)]
        return output

    def _pa_print_source_data(self, s, loc, toks):
        return [toks[0], '<title type="edName">{}</title>'.format(toks[1])]

    def _pa_print_tech_desc(self, s, loc, toks):
        return '<note type="techDesc"><p>{}</p></note>'.format(
            ''.join(toks).strip())

    def _pa_pound(self, s, loc, toks):
        return ['\N{POUND SIGN}']

    def _pa_raised(self, s, loc, toks):
        return ['\N{MIDDLE DOT}']

    def _pa_record(self, s, loc, toks):
        language_code = toks[0]
        return '<text type="record">\n<body>\n{}</body>\n</text>'.format(
            ''.join(toks[1:])).format(language_code)

    def _pa_record_heading(self, s, loc, toks):
        place, date, language_code = toks[0]
        record = '<seg ana="taxon:{code}">{code}</seg>'.format(
            code=self._source_code)
        return [language_code, '<head>{} {} {}</head>\n'.format(
            place, date, record)]

    def _pa_record_heading_date_century(self, s, loc, toks):
        century = int(toks['century'])
        label = toks['label']
        return ['<date from-iso="{}01" to-iso="{}00">{}{}</date>'.format(
            century-1, century, century, label)]

    def _pa_record_heading_date_year(self, s, loc, toks):
        circa = toks.get('circa')
        year = '{:04}'.format(int(toks['year']))
        slash_year = toks.get('slash_year')
        end_year = toks.get('end_year')
        slash_end_year = toks.get('slash_end_year')
        attrs = []
        if circa:
            attrs.append('precision="low"')
        if slash_year:
            year = self._merge_years(year, slash_year[1])
        if end_year:
            end_year = self._merge_years(year, end_year)
            if slash_end_year:
                end_year = self._merge_years(end_year, slash_end_year[1])
            attrs.append('from-iso="{}"'.format(year))
            attrs.append('to-iso="{}"'.format(end_year))
        else:
            attrs.append('when-iso="{}"'.format(year))
        attrs.sort()
        return ['<date {}>{}</date>'.format(' '.join(attrs), ''.join(toks))]

    def _pa_record_heading_place(self, s, loc, toks):
        if toks[0] not in self._place_codes:
            raise pp.ParseFatalException(
                'Place code {} used but not defined'.format(toks[0]))
        name, county = self._place_codes[toks[0]]
        return ['<rs>{}</rs>, <rs>{}</rs>'.format(name, county)]

    def _pa_return(self, s, loc, toks):
        # TODO: Perhaps add newlines here to deal with the case of long
        # lines in the source?
        return ['<lb />']

    def _pa_rich_content(self, s, loc, toks):
        return [toks[0].replace('&', '&amp;')]

    def _pa_right_marginale(self, s, loc, toks):
        return ['<note type="marginal" place="margin_right">',
                ''.join(toks[0]), '</note>']

    def _pa_row(self, s, loc, toks):
        return ['<row>', ''.join(toks[0]), '</row>']

    def _pa_section(self, s, loc, toks):
        return ['\N{SECTION SIGN}']

    def _pa_semicolon(self, s, loc, toks):
        # Private Use Area; see
        # http://folk.uib.no/hnooh/mufi/specs/MUFI-Alphabetic-3-0.pdf
        return ['\uF161']

    def _pa_signed(self, s, loc, toks):
        return self._make_signed(s, loc, toks)

    def _pa_signed_centre(self, s, loc, toks):
        return self._make_signed(s, loc, toks, 'center')

    def _pa_signed_right(self, s, loc, toks):
        return self._make_signed(s, loc, toks, 'right')

    def _pa_signed_mark(self, s, loc, toks):
        return self._make_signed_mark(s, loc, toks)

    def _pa_signed_mark_centre(self, s, loc, toks):
        return self._make_signed_mark(s, loc, toks, 'center')

    def _pa_signed_mark_right(self, s, loc, toks):
        return self._make_signed_mark(s, loc, toks, 'right')

    def _pa_source_code(self, s, loc, toks):
        code = ''.join(toks[0])
        if code in self._source_codes:
            raise pp.ParseFatalException(
                'Source code {} already used'.format(code))
        self._source_code = code
        self._source_codes.append(code)
        return code

    def _pa_source_data(self, s, loc, toks):
        return ''.join(toks[0]).strip()

    def _pa_source_date(self, s, loc, toks):
        return '<date>{}</date>'.format(''.join(toks[0]).strip())

    def _pa_special_v(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER MIDDLE-WELSH V}']

    def _pa_square_bracket_close(self, s, loc, toks):
        return [']']

    def _pa_square_bracket_open(self, s, loc, toks):
        return ['[']

    def _pa_superscript(self, s, loc, toks):
        return ['<hi rend="superscript">', ''.join(toks[0]), '</hi>']

    def _pa_supplied(self, s, loc, toks):
        return ['<supplied>', ''.join(toks[0]), '</supplied>']

    def _pa_tab_start(self, s, loc, toks):
        return ['<hi rend="right">', ''.join(toks[0]), '</hi>']

    def _pa_table(self, s, loc, toks):
        return ['<table>', ''.join(toks[0]), '</table>']

    def _pa_thorn(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER THORN}']

    def _pa_THORN(self, s, loc, toks):
        return ['\N{LATIN CAPITAL LETTER THORN}']

    def _pa_tilde(self, s, loc, toks):
        return ['{}\N{COMBINING TILDE}'.format(toks[1])]

    def _pa_title(self, s, loc, toks):
        return ['<title>', ''.join(toks[0]), '</title>']

    def _pa_transcription(self, s, loc, toks):
        # Leave the xml:lang code with formatting characters, to be
        # filled in later.
        return ['<div xml:lang="{}" type="transcription">' +
                '\n{}</div>\n'.format(''.join(toks))]

    def _pa_transcription_heading(self, s, loc, toks):
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
                ptype = self._get_page_type(page_details[1])
            else:
                ptype = self._get_page_type(page_details[0])
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

    def _pa_transcription_section(self, s, loc, toks):
        return ['<div>\n', ''.join(toks), '\n</div>\n']

    def _pa_translation(self, s, loc, toks):
        return ['<div xml:lang="eng" type="translation">\n',
                ''.join(toks[0]), '</div>\n']

    def _pa_umlaut(self, s, loc, toks):
        return ['{}\N{COMBINING DIAERESIS}'.format(toks[1])]

    def _pa_wynn(self, s, loc, toks):
        return ['\N{LATIN LETTER WYNN}']

    def _pa_xml_escape(self, s, loc, toks):
        return [html.escape(toks[0])]

    def _pa_yogh(self, s, loc, toks):
        return ['\N{LATIN SMALL LETTER YOGH}']

    def _pa_YOGH(self, s, loc, toks):
        return ['\N{LATIN CAPITAL LETTER YOGH}']
