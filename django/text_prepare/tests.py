from django.test import TestCase

from lxml import etree

from .document import (ADD_AB_XSLT_PATH, ADD_HEADER_XSLT_PATH,
                       ADD_ID_XSLT_PATH, Document, MASSAGE_FOOTNOTE_XSLT_PATH,
                       REMOVE_AB_XSLT_PATH)
from .document_parser import document_grammar


class TestDocumentConverter (TestCase):

    vowels = ['A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u']

    def _check_conversion (self, text, expected, record_heading=True,
                           subheading=True):
        if subheading:
            text = '@w\\f 124 {(19 November)}\\!\n' + text
            expected = '''<div type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
''' + expected + '''
</div>
</div>'''
        if record_heading:
            text = '@h\\BPA!1532!DOU2!eng\\!\n' + text
            expected = '''<text type="record">
<body xml:lang="eng">
<head><name ana="ereed:BPA" type="place_region">BPA</name> <date when-iso="1532">1532</date> <seg ana="ereed:DOU2">DOU2</seg></head>
''' + expected + '''
</body>
</text>'''
        actual = ''.join(document_grammar.parseString(text))
        self.assertEqual(actual, expected)

    def test_foo (self):
        text = 'Item@f\Item: {written in display script}@f/ it is ordered that it shalbe lawfull for the said foure officers called the stewards of the said courte called the min<...>@f\min<...>:  minst<…> {BL: Addit. Ch. 42681A}@f/ Courte and for every or any of them accordinge to the auncient Custome to distreine the Instrument{es} of musick or any <...>@f\<...>: other {BL: Addit. Ch. 42681A}@f/ goodes or Chattells'
        expected = 'Item<note type="foot">Item: <ex>written in display script</ex></note> it is ordered that it shalbe lawfull for the said foure officers called the stewards of the said courte called the min<damage><gap unit="chars" extent="3" /></damage><note type="foot">min<damage><gap unit="chars" extent="3" /></damage>:  minst<damage><gap unit="chars" extent="1" /></damage> <ex>BL: Addit. Ch. 42681A</ex></note> Courte and for every or any of them accordinge to the auncient Custome to distreine the Instrument<ex>es</ex> of musick or any <damage><gap unit="chars" extent="3" /></damage><note type="foot"><damage><gap unit="chars" extent="3" /></damage>: other <ex>BL: Addit. Ch. 42681A</ex></note> goodes or Chattells'
        self.maxDiff = None
        self._check_conversion(text, expected)

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
        text = 'some @e\\bold@e/ text'
        expected = 'some <hi rend="bold">bold</hi> text'
        self._check_conversion(text, expected)

    def test_bold_italic (self):
        text = 'some @j\\bold italic@j/ text'
        expected = 'some <hi rend="bold_italic">bold italic</hi> text'
        self._check_conversion(text, expected)

    def test_capitulum (self):
        text = '@Ca'
        expected = '\N{BLACK LEFTWARDS BULLET}a'
        self._check_conversion(text, expected)

    def test_caret (self):
        text = 'a^e'
        expected = 'a\N{CARET}e'
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
        text = 'some @m\\centred@m/ text'
        expected = 'some <hi rend="center">centred</hi> text'
        self._check_conversion(text, expected)

    def test_circumflex (self):
        for vowel in self.vowels:
            text = 'b@^{}t'.format(vowel)
            expected = 'b{}\N{COMBINING CIRCUMFLEX ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_closer (self):
        text = '@cl\\TTFN, Jamie@cl/'
        expected = '<closer>TTFN, Jamie</closer>'
        self._check_conversion(text, expected)

    def test_collation_note_ref (self):
        text = 'Some @cr\\@r1\\interesting text@cr/ content'
        expected = 'Some <ref target="#cn1" type="collation-note">interesting text</ref> content'
        self._check_conversion(text, expected)

    def test_collation_notes (self):
        text = '''@h\\BPA!1532!DOU2!eng\\!
@w\\f 124 {(19 November)}\\!
Test.
@cn\\
@c\\@a1\\A note.@c/
@c\\@a2\\Another note.@c/
@cn/'''
        expected = '''<text type="record">
<body xml:lang="eng">
<head><name ana="ereed:BPA" type="place_region">BPA</name> <date when-iso="1532">1532</date> <seg ana="ereed:DOU2">DOU2</seg></head>
<div type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.

</div>
</div>
<div type="collation_notes">
<div type="collation_note">
<anchor n="cn1" />A note.
</div>
<div type="collation_note">
<anchor n="cn2" />Another note.
</div>
</div>
</body>
</text>'''
        self.maxDiff = None
        self._check_conversion(text, expected, False, False)

    def test_comment (self):
        text = 'some @xc\\commented out@xc/ text'
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

    def test_end_notes (self):
        text = '''@h\\BPA!1532!DOU2!eng\\!
@w\\f 124 {(19 November)}\\!
Test.
@EN\\
@E\\A note.@E/
@E\\Another note.@E/
@EN/'''
        expected = '''<text type="record">
<body xml:lang="eng">
<head><name ana="ereed:BPA" type="place_region">BPA</name> <date when-iso="1532">1532</date> <seg ana="ereed:DOU2">DOU2</seg></head>
<div type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.

</div>
</div>
<div type="end_notes">
<div type="end_note">
A note.
</div>
<div type="end_note">
Another note.
</div>
</div>
</body>
</text>'''
        self._check_conversion(text, expected, False, False)

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
        text = '@g\\Exdented block of text.@g/'
        expected = '<ab type="exdent">Exdented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_expansion (self):
        text = 'some {expanded} text'
        expected = 'some <ex>expanded</ex> text'
        self._check_conversion(text, expected)

    def test_footnote (self):
        text = '@f\\our Churche: {St Nicholas}@f/'
        expected = '<note type="foot">our Churche: <ex>St Nicholas</ex></note>'
        self._check_conversion(text, expected)

    def test_grave (self):
        for vowel in self.vowels:
            text = "b@,{}t".format(vowel)
            expected = 'b{}\N{COMBINING GRAVE ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_indented (self):
        text = '@p\\Indented block of text.@p/'
        expected = '<ab type="indent">Indented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_interlineation_above (self):
        text = 'Some @a\\interlinearly above@a/ text'
        expected = 'Some <add place="above">interlinearly above</add> text'
        self._check_conversion(text, expected)

    def test_interlineation_below (self):
        text = 'Some @b\\interlinearly below@b/ text'
        expected = 'Some <add place="below">interlinearly below</add> text'
        self._check_conversion(text, expected)

    def test_interpolation (self):
        text = 'Some @i\\interpolated@i/ text'
        expected = 'Some <add><handShift />interpolated</add> text'
        self._check_conversion(text, expected)
        nested_text = 'Some @i\\@i\\really@i/ interpolated@i/ text'
        nested_expected = 'Some <add><handShift /><add><handShift />really</add> interpolated</add> text'
        self._check_conversion(nested_text, nested_expected)

    def test_italic_small_caps (self):
        text = 'Some @q\\italic small caps@q/ text'
        expected = 'Some <hi rend="smallcaps_italic">italic small caps</hi> text'
        self._check_conversion(text, expected)

    def test_lang_anglo_norman (self):
        text = 'The king said, "@xno\\Bon soir.@xno/"'
        expected = 'The king said, "<foreign xml:lang="xno">Bon soir.</foreign>"'
        self._check_conversion(text, expected)

    def test_lang_english (self):
        text = 'rex "@eng\\Hi.@eng/" dixit'
        expected = 'rex "<foreign xml:lang="eng">Hi.</foreign>" dixit'
        self._check_conversion(text, expected)

    def test_lang_latin (self):
        text = 'The king said, "@lat\\Salve.@lat/"'
        expected = 'The king said, "<foreign xml:lang="lat">Salve.</foreign>"'
        self._check_conversion(text, expected)

    def test_left_marginale (self):
        text = 'Hark, a @l\\left marginale note@l/ appears'
        expected = 'Hark, a <note type="marginal" place="margin_left">left marginale note</note> appears'
        self._check_conversion(text, expected)

    def test_list (self):
        text = '@ul\\ @li\\List item@li/ @li\\Another@li/ @ul/'
        expected = '<list><item>List item</item><item>Another</item></list>'
        self._check_conversion(text, expected)

    def test_macron (self):
        for vowel in self.vowels:
            text = 'b@-{}t'.format(vowel)
            expected = 'b{}\N{COMBINING MACRON}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_OE (self):
        text = 'd@OEr'
        expected = 'd\N{LATIN CAPITAL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_oe (self):
        text = 'd@oer'
        expected = 'd\N{LATIN SMALL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_page_break (self):
        text = '@w\\f 1\\!\nText that |crosses a page.'
        expected = '''<div type="transcription">
<div>
<head>f 1</head>
<pb n="1" type="folio" />
Text that <pb />crosses a page.
</div>
</div>'''
        self._check_conversion(text, expected, True, False)

    def test_paragraph (self):
        text = '@P Lo, a paragraph.'
        expected = '\N{PILCROW SIGN} Lo, a paragraph.'
        self._check_conversion(text, expected)

    def test_pound (self):
        text = '@$20 thousand I never knew I had'
        expected = '\N{POUND SIGN}20 thousand I never knew I had'
        self._check_conversion(text, expected)

    def test_raised (self):
        text = 'mid@*dot'
        expected = 'mid\N{MIDDLE DOT}dot'
        self._check_conversion(text, expected)

    def test_record_heading (self):
        base_input = '@h\\{place}!{year}!{record}!{lang}\\!\n@w\\Test\\!\nText'
        base_expected = '''<text type="record">
<body xml:lang="{lang}">
<head><name ana="ereed:{place}" type="place_region">{place}</name> {date} <seg ana="ereed:{record}">{record}</seg></head>
<div type="transcription">
<div>
<head>Test</head>
<pb />
Text
</div>
</div>
</body>
</text>'''
        data = {'lang': 'lat', 'place': 'BPA', 'record': 'DOU2',
                'date': '<date when-iso="1532">1532</date>', 'year': '1532'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'lat', 'place': 'LEE', 'record': 'V151',
                'date': '<date when-iso="1631">1630/1</date>', 'year': '1630/1'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date from-iso="1630" to-iso="1631">1630-1</date>',
                'year': '1630-1'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date from-iso="1629" to-iso="1631">1629-31</date>',
                'year': '1629-31'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date from-iso="1630" to-iso="1632">1629/30-31/2</date>',
                'year': '1629/30-31/2'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date precision="low" when-iso="1631">c 1631</date>',
                'year': 'c 1631'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date from-iso="1630" precision="low" to-iso="1632">c 1629/30-31/2</date>',
                'year': 'c 1629/30-31/2'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)
        data = {'lang': 'eng', 'place': 'LEE', 'record': 'V151',
                'date': '<date from-iso="1601" to-iso="1700">17th Century</date>',
                'year': '17th Century'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), False, False)

    def test_return (self):
        text = 'Bam! new line'
        expected = 'Bam<lb /> new line'
        self._check_conversion(text, expected)

    def test_right_marginale (self):
        text = 'Hark, a @r\\right marginale note@r/ appears'
        expected = 'Hark, a <note type="marginal" place="margin_right">right marginale note</note> appears'
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
        text = '@sn\\Thomas dyckes@sn/'
        expected = '<seg type="signed">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_centre (self):
        text = '@snc\\Thomas dyckes@snc/'
        expected = '<seg type="signed" rend="centre">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_right (self):
        text = '@snr\\Thomas dyckes@snr/'
        expected = '<seg type="signed" rend="right">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_small_caps (self):
        text = 'Some @k\\small caps@k/ text'
        expected = 'Some <hi rend="smallcaps">small caps</hi> text'
        self._check_conversion(text, expected)

    def test_special_v (self):
        text = 'Special @v, not k'
        expected = 'Special \N{LATIN SMALL LETTER MIDDLE-WELSH V}, not k'
        self._check_conversion(text, expected)

    def test_superscript (self):
        text = 'Some @s\\superscripted@s/ text'
        expected = 'Some <hi rend="superscript">superscripted</hi> text'
        self._check_conversion(text, expected)

    def test_table (self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n<c>text</c>\n</r>\n</t>'
        expected = '<table>\n<row>\n<cell></cell>\n<cell>Some</cell>\n<cell>text</cell>\n</row>\n</table>'
        self._check_conversion(text, expected)

    def test_table_with_comment (self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n@xc\\A comment@xc/\n<c>text</c>\n</r>\n</t>'
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

    def test_transcription (self):
        text = '@w\\ f.40* {(12 January) (Fortune: Warrant)}\!\nText'
        expected = '''<div type="transcription">
<div>
<head> f.40* <supplied>(12 January) (Fortune: Warrant)</supplied></head>
<pb />
Text
</div>
</div>'''
        self._check_conversion(text, expected, True, False)
        base_text = '@w\\{head}\!\nText'
        base_expected = '''<div type="transcription">
<div>
<head>{head}</head>
{pb}
Text
</div>
</div>'''
        all_data = [
            {'head': 'single mb', 'pb': '<pb n="1" type="membrane" />'},
            {'head': 'sig B3', 'pb': '<pb n="B3" type="signature" />'},
            {'head': 'p 234', 'pb': '<pb n="234" type="page" />'},
            {'head': 'ff [1v–2]', 'pb': '<pb type="folio" />'},
            {'head': 'f 46v', 'pb': '<pb n="46v" type="folio" />'},
            {'head': '', 'pb': ''}
        ]
        for data in all_data:
            self._check_conversion(base_text.format(**data),
                                   base_expected.format(**data), True, False)
        text = '@w\\ {(12 January)}\!\nText'
        expected = '''<div type="transcription">
<div>
<head> <supplied>(12 January)</supplied></head>

Text
</div>
</div>'''
        self._check_conversion(text, expected, True, False)

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
        text = '@l\\@k\\ac@k/or @k\\a@k/@l/!'
        expected = '<note type="marginal" place="margin_left"><hi rend="smallcaps">ac</hi>or <hi rend="smallcaps">a</hi></note><lb />'
        self._check_conversion(text, expected)


class TestXSLT (TestCase):

    def setUp (self):
        self._doc = Document(None, 0, 'staff')
        self.maxDiff = None

    def _transform (self, text, *xslt_paths):
        tree = etree.ElementTree(etree.fromstring(text))
        result_tree = self._doc._transform(tree, *xslt_paths)
        return etree.tostring(result_tree, encoding='unicode',
                              pretty_print=True)

    def test_add_ab (self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<pb />
<lb/>Some text.<lb/>
<lb/>More text.<lb/>
<lb/>
<list><item>Item.</item></list><lb/>
<closer>Bye</closer><lb/>
</div>
</div>
<div type="end_notes">
<div type="end_note">
End note text.<lb/>
</div>
</div>
</body>
</text>
<text type="record">
<body>
<head>@h head 2</head>
<div type="transcription">
<div>
<head>@w head 2.1</head>
Transcription text.<lb/>
<table><r><c>Cell text 1</c><c>Cell text 2</c></r></table>
After table text.
</div>
<div>
<head>@w head 2.2</head>
<lb/><lb/>More transcription text.
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div><head>@w head 1.1</head>
<pb/>

<ab>Some text.</ab>

<ab>More text.</ab>

<list><item>Item.</item></list>

<closer>Bye</closer>
</div>
</div>
<div type="end_notes">
<div type="end_note">
<ab>
End note text.</ab>
</div>
</div>
</body>
</text>
<text type="record">
<body>
<head>@h head 2</head>
<div type="transcription">
<div><head>@w head 2.1</head>
<ab>
Transcription text.</ab>

<table><r><c>Cell text 1</c><c>Cell text 2</c></r></table>

<ab>
After table text.
</ab>
</div>
<div><head>@w head 2.2</head>
<ab>More transcription text.
</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, ADD_AB_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_add_header (self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="staff">
<text>
<group>
<text type="record" xml:id="staff-ridm4">
<body>
<head>@h head 1</head>
<div type="transcription" xml:id="staff-ridm4-transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="staff"><teiHeader><fileDesc><titleStmt/><sourceDesc/></fileDesc><encodingDesc><listPrefixDef><prefixDef ident="ereed" matchPattern="([A-Za-z0-9]+)" replacementPattern="../code_list.xml#$1"><p>Private URIs using the <code>ereed</code> prefix are pointers to entities in the code_list.xml file. For example, <code>ereed:BPA</code> dereferences to <code>code_list.xml#BPA</code>.</p></prefixDef></listPrefixDef></encodingDesc></teiHeader>
<text>
<group>
<text type="record" xml:id="staff-ridm4">
<body>
<head>@h head 1</head>
<div type="transcription" xml:id="staff-ridm4-transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, ADD_HEADER_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_add_id (self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <ref target="#cn1" type="collation-note">collated material</ref>.</ab>
<ab>More <ref target="#cn2" type="collation-note">material needing a collation note</ref>.</ab>
</div>
</div>
<div type="collation_notes">
<div type="collation_note">
<ab><anchor n="cn1" />A note.</ab>
</div>
<div type="collation_note">
<ab><anchor n="cn2" />Another note.</ab>
</div>
</div>
</body>
</text>
<text type="record">
<body>
<head>@h head 2</head>
<div type="transcription">
<div>
<head>@w head 2.1</head>
<ab>Nothing here but a <note type="marginal" place="margin_left">marginal note</note> and a <note type="foot">footnote</note>.</ab>
</div>
</div>
<div type="end_notes">
<div type="end_note">
<ab>An end note.</ab>
</div>
<div type="end_note">
<ab>Another end note.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="staff">
<text>
<group>
<text type="record" xml:id="staff-ridm4">
<body>
<head>@h head 1</head>
<div type="transcription" xml:id="staff-ridm4-transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <ref target="#staff-ridm4-cnidm15" type="collation-note">collated material</ref>.</ab>
<ab>More <ref target="#staff-ridm4-cnidm18" type="collation-note">material needing a collation note</ref>.</ab>
</div>
</div>
<div type="collation_notes" xml:id="staff-ridm4-collation-notes">
<div type="collation_note" xml:id="staff-ridm4-cnidm15">
<ab>A note.</ab>
</div>
<div type="collation_note" xml:id="staff-ridm4-cnidm18">
<ab>Another note.</ab>
</div>
</div>
</body>
</text>
<text type="record" xml:id="staff-ridm21">
<body>
<head>@h head 2</head>
<div type="transcription" xml:id="staff-ridm21-transcription">
<div>
<head>@w head 2.1</head>
<ab>Nothing here but a <note type="marginal" place="margin_left" xml:id="staff-ridm21-mnidm28">marginal note</note> and a <note type="foot" xml:id="staff-ridm21-fnidm29">footnote</note>.</ab>
</div>
</div>
<div type="end_notes" xml:id="staff-ridm21-end-notes">
<div type="end_note" xml:id="staff-ridm21-enidm31">
<ab>An end note.</ab>
</div>
<div type="end_note" xml:id="staff-ridm21-enidm33">
<ab>Another end note.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, ADD_ID_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_massage_footnote (self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <note type="foot">with: <ex>see f <del>1v</del>.</ex></note>.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <note type="foot">with: <hi rend="italic">see f [1v].</hi></note>.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, MASSAGE_FOOTNOTE_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_remove_ab (self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab><gap /></ab>
<ab><gap />Some text.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<gap/>
<ab><gap/>Some text.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, REMOVE_AB_XSLT_PATH)
        self.assertEqual(actual, expected)
