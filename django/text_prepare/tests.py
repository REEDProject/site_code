from django.test import TestCase

from .document_parser import document_grammar


class TestDocumentConverter (TestCase):

    vowels = ['A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u']

    def _check_conversion (self, text, expected, main_heading=True,
                           subheading=True):
        if subheading:
            text = '@w\\f 124 {(19 November)}\\!\n\n' + text
            expected = '<div type="subsection"><head type="sub">f 124 <hi rend="italic">(19 November)</hi></head>\n\n' + expected + '</div>'
        if main_heading:
            text = '@h\\BPA!1532!DOU2!eng\\!\n\n' + text
            expected = '<div xml:lang="eng"><head type="main"><name type="place_region">BPA</name> <date>1532</date></head>\n\n' + expected + '</div>'
        actual = ''.join(document_grammar.parseString(text))
        self.assertEqual(actual, expected)

    def test_acute (self):
        for vowel in self.vowels:
            text = "b@'{}t".format(vowel)
            expected = 'b{}\N{COMBINING ACUTE ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_AE (self):
        text = 'Vita @AEterna'
        expected = 'Vita \N{LATIN CAPITAL LETTER AE}terna'
        self._check_conversion(text, expected)

    def test_ae (self):
        text = 'vita @aeterna'
        expected = 'vita \N{LATIN SMALL LETTER AE}terna'
        self._check_conversion(text, expected)

    def test_blank (self):
        text = 'some {(blank)} text'
        expected = 'some <space /> text'
        self._check_conversion(text, expected)

    def test_bold (self):
        text = 'some @e\\bold@e \\ text'
        expected = 'some <hi rend="bold">bold</hi> text'
        self._check_conversion(text, expected)

    def test_bold_italic (self):
        text = 'some @j\\bold italic@j \\ text'
        expected = 'some <hi rend="bold_italic">bold italic</hi> text'
        self._check_conversion(text, expected)

    def test_capitulum (self):
        text = '@Ca'
        expected = '\N{BLACK LEFTWARDS BULLET}a'
        self._check_conversion(text, expected)

    def test_caret (self):
        text = 'a^e'
        expected = 'a\N{LATIN SMALL LETTER TURNED V}e'
        self._check_conversion(text, expected)

    def test_cedilla (self):
        text = 'gar@?con'
        expected = 'garc\N{COMBINING CEDILLA}on'
        self._check_conversion(text, expected)

    def test_cell_right (self):
        text = '<t><r><c>Some</c><cr>text</cr></r></t>'
        expected = '<table><row><cell>Some</cell><cell rend="right">text</cell></row></table>'
        self._check_conversion(text, expected)

    def test_centred (self):
        text = 'some @m\\centred@m \\ text'
        expected = 'some <hi rend="center">centred</hi> text'
        self._check_conversion(text, expected)

    def test_circumflex (self):
        for vowel in self.vowels:
            text = 'b@^{}t'.format(vowel)
            expected = 'b{}\N{COMBINING CIRCUMFLEX ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_collation (self):
        text = 'FOO'
        expected = 'QAZ'
        self._check_conversion(text, expected)

    def test_comment (self):
        text = 'some @xc\\commented out@xc \\ text'
        expected = 'some <!-- commented out --> text'
        self._check_conversion(text, expected)

    def test_damaged (self):
        for i in range(1, 5):
            text = 'dam<{}> text'.format('.' * i)
            expected = 'dam<damage><gap unit="chars" extent="{}" /></damage>' \
                       ' text'.format(i)
            self._check_conversion(text, expected)

    def test_deleted (self):
        text = 'some [deleted] text'
        expected = 'some <del>deleted</del> text'
        self._check_conversion(text, expected)

    def test_dot_over (self):
        text = 'ove@.rdot'
        expected = 'over\N{COMBINING DOT ABOVE}dot'
        self._check_conversion(text, expected)

    def test_dot_under (self):
        text = 'unde@#rdot'
        expected = 'under\N{COMBINING DOT BELOW}dot'
        self._check_conversion(text, expected)

    def test_ellipsis (self):
        text = 'some ... text'
        expected = 'some <gap reason="omitted" /> text'
        self._check_conversion(text, expected)

    def test_en_dash (self):
        text = '1651--1653'
        expected = '1651\N{EN DASH}1653'
        self._check_conversion(text, expected)

    def test_endnote (self):
        text = 'FOO'
        expected = 'QAZ'
        self._check_conversion(text, expected)

    def test_ENG (self):
        text = '@Nati'
        expected = '\N{LATIN CAPITAL LETTER ENG}ati'
        self._check_conversion(text, expected)

    def test_eng (self):
        text = 'Fi@nal'
        expected = 'Fi\N{LATIN SMALL LETTER ENG}al'
        self._check_conversion(text, expected)

    def test_eth (self):
        text = 'Gala@don'
        expected = 'Gala\N{LATIN SMALL LETTER ETH}on'
        self._check_conversion(text, expected)

    def test_exclamation (self):
        text = 'Zounds@!'
        expected = 'Zounds!'
        self._check_conversion(text, expected)

    def test_exdented (self):
        text = '@g\\Exdented block of text.@g \\'
        expected = '<ab type="body_p_exdented">Exdented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_footnote (self):
        text = '@f\\our Churche: {St Nicholas}@f \\'
        expected = '<note type="foot">our Churche: <hi rend="italic">St Nicholas</hi></note>'
        self._check_conversion(text, expected)

    def test_grave (self):
        for vowel in self.vowels:
            text = "b@,{}t".format(vowel)
            expected = 'b{}\N{COMBINING GRAVE ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_indented (self):
        text = '@p\\Indented block of text.@p \\'
        expected = '<ab type="body_p_indented">Indented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_interlineation_above (self):
        text = 'Some @a\\interlinearly above@a \\ text'
        expected = 'Some <add place="above">interlinearly above</add> text'
        self._check_conversion(text, expected)

    def test_interlineation_below (self):
        text = 'Some @b\\interlinearly below@b \\ text'
        expected = 'Some <add place="below">interlinearly below</add> text'
        self._check_conversion(text, expected)

    def test_interpolation (self):
        text = 'Some @i\\interpolated@i \\ text'
        expected = 'Some <add><handShift />interpolated</add> text'
        self._check_conversion(text, expected)
        nested_text = 'Some @i\\@i\\really@i \\ interpolated@i \\ text'
        nested_expected = 'Some <add><handShift /><add><handShift />really</add> interpolated</add> text'
        self._check_conversion(nested_text, nested_expected)

    def test_italic (self):
        text = 'some {italic} text'
        expected = 'some <hi rend="italic">italic</hi> text'
        self._check_conversion(text, expected)

    def test_italic_small_caps (self):
        text = 'Some @q\\italic small caps@q \\ text'
        expected = 'Some <hi rend="smallcaps_italic">italic small caps</hi> text'
        self._check_conversion(text, expected)

    def test_lang_anglo_french (self):
        text = 'The king said, "@xaf\\Bon soir.@xaf \\"'
        expected = 'The king said, "<foreign xml:lang="xaf">Bon soir.</foreign>"'
        self._check_conversion(text, expected)

    def test_lang_english (self):
        text = 'rex "@eng\\Hi.@eng \\" dixit'
        expected = 'rex "<foreign xml:lang="eng">Hi.</foreign>" dixit'
        self._check_conversion(text, expected)

    def test_lang_latin (self):
        text = 'The king said, "@lat\\Salve.@lat \\"'
        expected = 'The king said, "<foreign xml:lang="lat">Salve.</foreign>"'
        self._check_conversion(text, expected)

    def test_left_marginale (self):
        text = 'Hark, a @l\\left marginale note@l \\ appears'
        expected = 'Hark, a <note type="marginal" place="margin_left" n="CHANGE_ME_TO_XMLID">left marginale note</note> appears'
        self._check_conversion(text, expected)

    def test_macron (self):
        for vowel in self.vowels:
            text = 'b@-{}t'.format(vowel)
            expected = 'b{}\N{COMBINING MACRON}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_main_heading (self):
        text = '@h\\BPA!1532!DOU2!lat\\!\n\n@w\\Test\\!\n\nText'
        expected = '<div xml:lang="lat"><head type="main"><name type="place_region">BPA</name> <date>1532</date></head>\n\n<div type="subsection"><head type="sub">Test</head>\n\nText</div></div>'
        self._check_conversion(text, expected, False, False)

    def test_OE (self):
        text = 'd@OEr'
        expected = 'd\N{LATIN CAPITAL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_oe (self):
        text = 'd@oer'
        expected = 'd\N{LATIN SMALL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_paragraph (self):
        text = '@P Lo, a paragraph.'
        expected = '\N{PILCROW SIGN} Lo, a paragraph.'
        self._check_conversion(text, expected)

    def test_personnel (self):
        text = 'No one expects @x\\personnel@x \\'
        expected = 'No one expects <note type="eccles_court">personnel</note>'
        self._check_conversion(text, expected)

    def test_pound (self):
        text = '@$20 thousand I never knew I had'
        expected = '\N{POUND SIGN}20 thousand I never knew I had'
        self._check_conversion(text, expected)

    def test_raised (self):
        text = 'mid@*dot'
        expected = 'mid\N{MIDDLE DOT}dot'
        self._check_conversion(text, expected)

    def test_return (self):
        text = 'Bam! new line'
        expected = 'Bam<lb /> new line'
        self._check_conversion(text, expected)

    def test_right_marginale (self):
        text = 'Hark, a @r\\right marginale note@r \\ appears'
        expected = 'Hark, a <note type="marginal" place="margin_right" n="CHANGE_ME_TO_XMLID">right marginale note</note> appears'
        self._check_conversion(text, expected)

    def test_section (self):
        text = 'A new section? @% Yes.'
        expected = 'A new section? \N{SECTION SIGN} Yes.'
        self._check_conversion(text, expected)

    def test_semicolon (self):
        text = 'PUA @; punctus elevatus'
        expected = 'PUA \uF161 punctus elevatus'
        self._check_conversion(text, expected)

    def test_signed (self):
        text = '@sn\\Thomas dyckes@sn \\'
        expected = '<seg type="signed">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_centre (self):
        text = '@snc\\Thomas dyckes@snc \\'
        expected = '<seg type="signed" rend="centre">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_right (self):
        text = '@snr\\Thomas dyckes@snr \\'
        expected = '<seg type="signed" rend="right">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_small_caps (self):
        text = 'Some @k\\small caps@k \\ text'
        expected = 'Some <hi rend="smallcaps">small caps</hi> text'
        self._check_conversion(text, expected)

    def test_special_v (self):
        text = 'Special @v, not k'
        expected = 'Special \N{LATIN SMALL LETTER MIDDLE-WELSH V}, not k'
        self._check_conversion(text, expected)

    def test_subsection (self):
        # QAZ: Check what this should actually be - likely this needs
        # to be processed further.
        text = '@w\ f.40* {(12 January) (Fortune: Warrant)}\!\n\nText'
        expected = '<div type="subsection"><head type="sub"> f.40* <hi rend="italic">(12 January) (Fortune: Warrant)</hi></head>\n\nText</div>'
        self._check_conversion(text, expected, True, False)

    def test_superscript (self):
        text = 'Some @s\\superscripted@s \\ text'
        expected = 'Some <hi rend="superscript">superscripted</hi> text'
        self._check_conversion(text, expected)

    def test_table (self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n<c>text</c>\n</r>\n</t>'
        expected = '<table>\n<row>\n<cell></cell>\n<cell>Some</cell>\n<cell>text</cell>\n</row>\n</table>'
        self._check_conversion(text, expected)

    def test_table_with_comment (self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n@xc\\A comment@xc \\\n<c>text</c>\n</r>\n</t>'
        expected = '<table>\n<row>\n<cell></cell>\n<cell>Some</cell>\n<!-- A comment -->\n<cell>text</cell>\n</row>\n</table>'
        self._check_conversion(text, expected)

    def test_THORN (self):
        text = '@THat is silly and wrong'
        expected = '\N{LATIN CAPITAL LETTER THORN}at is silly and wrong'
        self._check_conversion(text, expected)

    def test_thorn (self):
        text = 'A @thin man'
        expected = 'A \N{LATIN SMALL LETTER THORN}in man'
        self._check_conversion(text, expected)

    def test_tilde (self):
        for char in self.vowels + ['n']:
            text = 'pa@"{}a'.format(char)
            expected = 'pa{}\N{COMBINING TILDE}a'.format(char)
            self._check_conversion(text, expected)

    def test_umlaut (self):
        for vowel in self.vowels:
            text = 'b@:{}t'.format(vowel)
            expected = 'b{}\N{COMBINING DIAERESIS}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_wynn (self):
        text = 'All I do is @y'
        expected = 'All I do is \N{LATIN LETTER WYNN}'
        self._check_conversion(text, expected)

    def test_xml_escape (self):
        data = {'&': '&amp;', '<': '&lt;', '>': '&gt;'}
        for char, expected in data.items():
            text = 'a {} b'.format(char)
            expected = 'a {} b'.format(expected)
            self._check_conversion(text, expected)

    def test_YOGH (self):
        text = 'Not @Z Sothoth'
        expected = 'Not \N{LATIN CAPITAL LETTER YOGH} Sothoth'
        self._check_conversion(text, expected)

    def test_yogh (self):
        text = 'cummings invokes @z sothoth'
        expected = 'cummings invokes \N{LATIN SMALL LETTER YOGH} sothoth'
        self._check_conversion(text, expected)

    def test_nesting (self):
        # This is impossible to comprehensively test. Start with a few
        # examples and add more as problems are discovered.
        text = '@l\\@k\\ac@k \\or @k\\a@k \\@l \\!'
        expected = '<note type="marginal" place="margin_left" n="CHANGE_ME_TO_XMLID"><hi rend="smallcaps">ac</hi>or <hi rend="smallcaps">a</hi></note><lb />'
        self._check_conversion(text, expected)
