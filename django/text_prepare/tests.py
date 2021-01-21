from django.test import TestCase

from lxml import etree
import pyparsing as pp

from .document import (
    AB_TO_P_XSLT_PATH, ADD_AB_XSLT_PATH, ADD_HEADER_XSLT_PATH,
    ADD_ID_XSLT_PATH, Document, MASSAGE_FOOTNOTE_XSLT_PATH,
    REMOVE_AB_XSLT_PATH, SORT_RECORDS_XSLT_PATH, TIDY_BIBLS_XSLT_PATH)
from .document_parser import DocumentParser


class TestDocumentConverter (TestCase):

    vowels = ['A', 'a', 'E', 'e', 'I', 'i', 'O', 'o', 'U', 'u']

    def setUp(self):
        self.parser = DocumentParser()

    def _check_conversion(self, text, expected, doc_desc=True, heading=True,
                          subheading=True, reset_parser=True):
        if subheading:
            text = '@w\\f 124 {{(19 November)}}\\!\n' + text
            expected = '''<div xml:lang="lat" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
''' + expected + '''
</div>
</div>'''
        if heading:
            text = '@h\\BPA!1532!lat\\!\n' + text
            expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Boring Place Anyway</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDEF">ABCDEF</seg></head>
''' + expected + '''
</body>
</text>'''
        if doc_desc:
            text = '''@md\\Prose document description.!

It spans multiple paragraphs.!

@sc\\ABCDEF@sc/ @sh\\Source heading.@sh/
@sl\\Reading@sl/ @sr\\Berkshire Record Office@sr/
@ss\\D/A2/c.54@ss/
@st\\Epiphany, 1609@st/; this is the technical paragraph. Latin and English; paper; 0+389+0 leaves.@md/\n
@pc\\@ab\\BPA@ab/ @ex\\Boring Place Anyway@ex/ @ct\\Staffordshire@ct/@pc/''' + text
        actual = ''.join(self.parser.parse(text).record)
        self.assertEqual(actual, expected)
        # Reset the parser to not fall foul of source code reuse.
        if reset_parser:
            self.parser = DocumentParser()

    def test_acute(self):
        for vowel in self.vowels:
            text = "b@'{}t".format(vowel)
            expected = 'b{}\N{COMBINING ACUTE ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_AE(self):
        text = 'Vita @AEterna'
        expected = 'Vita \N{LATIN CAPITAL LETTER AE}terna'
        self._check_conversion(text, expected)

    def test_ae(self):
        text = 'vita @aeterna'
        expected = 'vita \N{LATIN SMALL LETTER AE}terna'
        self._check_conversion(text, expected)

    def test_blank(self):
        text = 'some {{(blank)}} text'
        expected = 'some <space /> text'
        self._check_conversion(text, expected)

    def test_capitulum(self):
        text = '@Ca'
        expected = '\N{CAPITULUM}a'
        self._check_conversion(text, expected)

    def test_caret(self):
        text = 'a^e'
        expected = 'a\N{CARET}e'
        self._check_conversion(text, expected)

    def test_cedilla(self):
        text = 'gar@?con'
        expected = 'garc\N{COMBINING CEDILLA}on'
        self._check_conversion(text, expected)

    def test_cell_centre(self):
        text = '<t><r><c>Some</c><cc>text</cc></r></t>'
        expected = '<table><row><cell>Some</cell><cell rend="center">text</cell></row></table>'
        self._check_conversion(text, expected)

    def test_cell_right(self):
        text = '<t><r><c>Some</c><cr>text</cr></r></t>'
        expected = '<table><row><cell>Some</cell><cell rend="right">text</cell></row></table>'
        self._check_conversion(text, expected)

    def test_centred(self):
        text = 'some @m\\centred@m/ text'
        expected = 'some <ab rend="center">centred</ab> text'
        self._check_conversion(text, expected)

    def test_circumflex(self):
        for vowel in self.vowels:
            text = 'b@^{}t'.format(vowel)
            expected = 'b{}\N{COMBINING CIRCUMFLEX ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_closer(self):
        text = '@cl\\TTFN, Jamie@cl/'
        expected = '<closer>TTFN, Jamie</closer>'
        self._check_conversion(text, expected)

    def test_collation_note(self):
        text = 'Some text@c\\text: foo@c/ content'
        expected = 'Some text<note type="collation">text: foo</note> content'
        self._check_conversion(text, expected)

    def test_comment(self):
        text = 'some @xc\\commented out@xc/ text'
        expected = 'some <!-- commented out --> text'
        self._check_conversion(text, expected)

    def test_damaged(self):
        for i in range(1, 5):
            text = 'dam<{}> text'.format('.' * i)
            expected = 'dam<damage><gap unit="chars" extent="{}" /></damage>' \
                       ' text'.format(i)
            self._check_conversion(text, expected)

    def test_deleted(self):
        text = 'some [deleted] text'
        expected = 'some <del>deleted</del> text'
        self._check_conversion(text, expected)

    def test_dot_over(self):
        text = 'ove@.rdot'
        expected = 'over\N{COMBINING DOT ABOVE}dot'
        self._check_conversion(text, expected)

    def test_dot_under(self):
        text = 'unde@#rdot'
        expected = 'under\N{COMBINING DOT BELOW}dot'
        self._check_conversion(text, expected)

    def test_duplicate_source_codes_error(self):
        # Duplicate source codes should raise an error.
        text = 'Test'
        expected = 'Test'
        self._check_conversion(text, expected, reset_parser=False)
        text = 'Test'
        expected = 'Test'
        self.assertRaises(pp.ParseFatalException, self._check_conversion, text,
                          expected)

    def test_ellipsis(self):
        text = 'some ... text'
        expected = 'some <gap reason="omitted" /> text'
        self._check_conversion(text, expected)

    def test_en_dash(self):
        text = '1651--1653'
        expected = '1651\N{EN DASH}1653'
        self._check_conversion(text, expected)

    def test_end_notes(self):
        text = '''@h\\BPA!1532!eng\\!
@w\\f 124 {{(19 November)}}\\!
Test.
@en\\A note.@en/
'''
        expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Boring Place Anyway</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDEF">ABCDEF</seg></head>
<div xml:lang="eng" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.

</div>
</div>
<div type="endnote">
A note.
</div>
</body>
</text>'''
        self._check_conversion(text, expected, heading=False, subheading=False)

    def test_ENG(self):
        text = '@Nati'
        expected = '\N{LATIN CAPITAL LETTER ENG}ati'
        self._check_conversion(text, expected)

    def test_eng(self):
        text = 'Fi@nal'
        expected = 'Fi\N{LATIN SMALL LETTER ENG}al'
        self._check_conversion(text, expected)

    def test_eth(self):
        text = 'Gala@don'
        expected = 'Gala\N{LATIN SMALL LETTER ETH}on'
        self._check_conversion(text, expected)

    def test_exclamation(self):
        text = 'Zounds@!'
        expected = 'Zounds!'
        self._check_conversion(text, expected)

    def test_exdented(self):
        text = '@g\\Exdented block of text.@g/'
        expected = '<ab type="exdent">Exdented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_expansion(self):
        text = 'some {{expanded}} text'
        expected = 'some <ex>expanded</ex> text'
        self._check_conversion(text, expected)

    def test_footnote(self):
        text = '@f\\our Churche: {{St Nicholas}}@f/'
        expected = '<note type="foot">our Churche: <ex>St Nicholas</ex></note>'
        self._check_conversion(text, expected)

    def test_grave(self):
        for vowel in self.vowels:
            text = "b@,{}t".format(vowel)
            expected = 'b{}\N{COMBINING GRAVE ACCENT}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_illegible(self):
        text = 'an@1gi1 there?'
        expected = 'an<gap extent="1" reason="illegible" unit="chars" />1 there?'
        self._check_conversion(text, expected)
        text = 'i@18gin'
        expected = 'i<gap extent="18" reason="illegible" unit="chars" />n'
        self._check_conversion(text, expected)

    def test_indented(self):
        text = '@p\\Indented block of text.@p/'
        expected = '<ab type="indent">Indented block of text.</ab>'
        self._check_conversion(text, expected)

    def test_interlineation_above(self):
        text = 'Some @a\\interlinearly above@a/ text'
        expected = 'Some <add place="above">interlinearly above</add> text'
        self._check_conversion(text, expected)

    def test_interlineation_below(self):
        text = 'Some @b\\interlinearly below@b/ text'
        expected = 'Some <add place="below">interlinearly below</add> text'
        self._check_conversion(text, expected)

    def test_interpolation(self):
        text = 'Some @i\\interpolated@i/ text'
        expected = 'Some <handShift />interpolated<handShift /> text'
        self._check_conversion(text, expected)
        nested_text = 'Some @i\\@i\\really@i/ interpolated@i/ text'
        nested_expected = 'Some <handShift /><handShift />really<handShift /> interpolated<handShift /> text'
        self._check_conversion(nested_text, nested_expected)

    def test_italics(self):
        text = 'Some @it\\italic@it/ text'
        expected = 'Some <hi rend="italic">italic</hi> text'
        self._check_conversion(text, expected)

    def test_lang_german(self):
        text = 'The king said, "@ger\\Guten Tag.@ger/"'
        expected = 'The king said, "<foreign xml:lang="deu">Guten Tag.</foreign>"'
        self._check_conversion(text, expected)

    def test_lang_generic(self):
        langs = ('ang', 'cnx', 'cor', 'cym', 'eng', 'fra', 'gla', 'gmh',
                 'gml', 'grc', 'ita', 'lat', 'por', 'spa', 'wlm', 'xno')
        text = 'Native tones @{}\\Foreign gabble@{}/ judge'
        expected = 'Native tones <foreign xml:lang="{}">Foreign gabble</foreign> judge'
        for lang in langs:
            self._check_conversion(text.format(lang, lang),
                                   expected.format(lang))

    def test_left_marginale(self):
        text = 'Hark, a @l\\left marginale note@l/ appears'
        expected = 'Hark, a <note type="marginal" place="margin_left">left marginale note</note> appears'
        self._check_conversion(text, expected)

    def test_line_group(self):
        text = '@lg\\@lni\\Foo@lni/@ln\\Bar@ln/@lg/'
        expected = '<lg><l rend="indent">Foo</l><l>Bar</l></lg>'
        self._check_conversion(text, expected)
        text = '''
@lg\\
  @lg\\
    @lni\\Stanza 1, line 1, indented@lni/
    @ln\\Stanza 1, line 2@ln/
  @lg/
  @lg\\
    @lni\\Stanza 2, line 1, indented@lni/
  @lg/
@lg/'''
        expected = '\n<lg><lg><l rend="indent">Stanza 1, line 1, indented</l><l>Stanza 1, line 2</l></lg><lg><l rend="indent">Stanza 2, line 1, indented</l></lg></lg>'
        self._check_conversion(text, expected)

    def test_list(self):
        text = '@ul\\ @li\\List item@li/ @li\\Another@li/ @ul/'
        expected = '<list><item>List item</item><item>Another</item></list>'
        self._check_conversion(text, expected)

    def test_macron(self):
        for vowel in self.vowels:
            text = 'b@-{}t'.format(vowel)
            expected = 'b{}\N{COMBINING MACRON}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_ms_doc_desc(self):
        # No prose paragraph.
        text = '''@md\\@sc\\ABCDEF@sc/
        @sh\\Heading@sh/
        @sl\\Bognor Regis@sl/
        @sr\\Boris's Borough Books & Records@sr/
        @ss\\127.43#61-4/AN@ss/
        @st\\1609@st/ Technical paragraph.
        @md/
        @pc\\ @ab\\ABC@ab/ @ex\\A Bland County@ex/ @ct\\Staffordshire@ct/@pc/
@h\\ABC!1532!eng\\!
@w\\f 124 {{(19 November)}}\\!
Test.'''
        expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>A Bland County</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDEF">ABCDEF</seg></head>
<div xml:lang="eng" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.
</div>
</div>
</body>
</text>'''
        self._check_conversion(text, expected, doc_desc=False, heading=False,
                               subheading=False)
        actual_desc = ''.join(self.parser.parse(text).doc_desc)
        expected_desc = '''<msDesc xml:id="ABCDEF">
<msIdentifier>
<settlement>Bognor Regis</settlement>
<repository>Boris's Borough Books &amp; Records</repository>
<idno type="shelfmark">127.43#61-4/AN</idno>
<msName>Heading</msName>
</msIdentifier>
<ab type="techDesc"><date>1609</date> Technical paragraph.</ab>
</msDesc>'''
        self.assertEqual(actual_desc, expected_desc)
        # Prose paragraph.
        text = '''@md\\
        Prose paragraph.
        @sc\\ABCDE1@sc/
        @sh\\Heading@sh/
        @sl\\Bognor Regis@sl/
        @sr\\Boris's Borough Books & Records@sr/
        @ss\\127.43#61-4/AN@ss/
        @st\\1609@st/ Technical paragraph.
        @md/
        @pc\\ @ab\\ABC@ab/ @ex\\A Bland County@ex/ @ct\\Staffordshire@ct/@pc/
@h\\ABC!1532!eng\\!
@w\\f 124 {{(19 November)}}\\!
Test.'''
        expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>A Bland County</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDE1">ABCDE1</seg></head>
<div xml:lang="eng" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.
</div>
</div>
</body>
</text>'''
        self._check_conversion(text, expected, doc_desc=False, heading=False,
                               subheading=False)
        actual_desc = ''.join(self.parser.parse(text).doc_desc)
        expected_desc = '''<msDesc xml:id="ABCDE1">
<msIdentifier>
<settlement>Bognor Regis</settlement>
<repository>Boris's Borough Books &amp; Records</repository>
<idno type="shelfmark">127.43#61-4/AN</idno>
<msName>Heading</msName>
</msIdentifier>
<ab type="edDesc">Prose paragraph.</ab>
<ab type="techDesc"><date>1609</date> Technical paragraph.</ab>
</msDesc>'''
        self.assertEqual(actual_desc, expected_desc)

    def test_OE(self):
        text = 'd@OEr'
        expected = 'd\N{LATIN CAPITAL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_oe(self):
        text = 'd@oer'
        expected = 'd\N{LATIN SMALL LIGATURE OE}r'
        self._check_conversion(text, expected)

    def test_page_break(self):
        text = '@w\\f 1\\!\nText that |crosses a page.'
        expected = '''<div xml:lang="lat" type="transcription">
<div>
<head>f 1</head>
<pb n="1" type="folio" />
Text that <pb />crosses a page.
</div>
</div>'''
        self._check_conversion(text, expected, subheading=False)

    def test_paragraph(self):
        text = '@P Lo, a paragraph.'
        expected = '\N{PILCROW SIGN} Lo, a paragraph.'
        self._check_conversion(text, expected)

    def test_pound(self):
        text = '@$20 thousand I never knew I had'
        expected = '\N{POUND SIGN}20 thousand I never knew I had'
        self._check_conversion(text, expected)

    def test_print_doc_desc(self):
        # No prose paragraph.
        text = '''@pd\\@sc\\ABCDE1@sc/
        @sh\\Heading@sh/
        Technical paragraph.
        @pd/
        @pc\\ @ab\\ABC@ab/ @ex\\A Bland County@ex/ @ct\\Staffordshire@ct/ @pc/
@h\\ABC!1532!eng\\!
@w\\f 124 {{(19 November)}}\\!
Test.'''
        expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>A Bland County</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDE1">ABCDE1</seg></head>
<div xml:lang="eng" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.
</div>
</div>
</body>
</text>'''
        self._check_conversion(text, expected, doc_desc=False, heading=False,
                               subheading=False)
        actual_desc = ''.join(self.parser.parse(text).doc_desc)
        expected_desc = '''<bibl xml:id="ABCDE1">
<title type="edName">Heading</title>
<note type="techDesc"><p>Technical paragraph.</p></note>
</bibl>'''
        self.assertEqual(actual_desc, expected_desc)
        # Prose paragraph.
        text = '''@pd\\Prose paragraph.
        @sc\\ABCDEF@sc/
        @sh\\Heading@sh/
        Technical paragraph.
        @pd/
        @pc\\ @ab\\ABC@ab/ @ex\\A Bland County@ex/ @ct\\Staffordshire@ct/ @pc/
@h\\ABC!1532!eng\\!
@w\\f 124 {{(19 November)}}\\!
Test.'''
        expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>A Bland County</rs> <date when-iso="1532">1532</date> <seg ana="taxon:ABCDEF">ABCDEF</seg></head>
<div xml:lang="eng" type="transcription">
<div>
<head>f 124 <supplied>(19 November)</supplied></head>
<pb n="124" type="folio" />
Test.
</div>
</div>
</body>
</text>'''
        self._check_conversion(text, expected, doc_desc=False, heading=False,
                               subheading=False)
        actual_desc = ''.join(self.parser.parse(text).doc_desc)
        expected_desc = '''<bibl xml:id="ABCDEF">
<title type="edName">Heading</title>
<note type="edDesc"><p>Prose paragraph.</p></note>
<note type="techDesc"><p>Technical paragraph.</p></note>
</bibl>'''
        self.assertEqual(actual_desc, expected_desc)

    def test_punctuation(self):
        punctuation = ['.', ',', ';', ':', "'", '"', '(', ')', '*', '/', '#',
                       '$', '%', '+', '-', '?', '–', '_', '=']
        for item in punctuation:
            text = item
            expected = item
            self._check_conversion(text, expected)

    def test_raised(self):
        text = 'mid@*dot'
        expected = 'mid\N{MIDDLE DOT}dot'
        self._check_conversion(text, expected)

    def test_record_heading(self):
        base_input = '@h\\{place}!{year}!{lang}\\!\n@w\\Test\\!\nText'
        base_expected = '''<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>{full_place}</rs> {date} <seg ana="taxon:ABCDEF">ABCDEF</seg></head>
<div xml:lang="{lang}" type="transcription">
<div>
<head>Test</head>
<pb />
Text
</div>
</div>
</body>
</text>'''
        data = {'lang': 'lat', 'place': 'BPA',
                'date': '<date when-iso="1532">1532</date>', 'year': '1532',
                'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'lat', 'place': 'BPA',
                'date': '<date when-iso="1631">1630/1</date>',
                'year': '1630/1', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date from-iso="1630" to-iso="1631">1630-1</date>',
                'year': '1630-1', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date from-iso="1629" to-iso="1631">1629-31</date>',
                'year': '1629-31', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date from-iso="1630" to-iso="1632">1629/30-31/2</date>',
                'year': '1629/30-31/2', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date precision="low" when-iso="1631"><hi rend="italic">c</hi> 1631</date>',
                'year': '@it\\c@it/ 1631', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date from-iso="1630" precision="low" to-iso="1632"><hi rend="italic">c</hi> 1629/30-31/2</date>',
                'year': '@it\\c@it/ 1629/30-31/2', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date from-iso="1601" to-iso="1700">17th Century</date>',
                'year': '17th Century', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date when-iso="1600">1599/1600</date>',
                'year': '1599/1600', 'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': '<date when-iso="0900">900</date>', 'year': '900',
                'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)
        data = {'lang': 'eng', 'place': 'BPA',
                'date': 'Undated', 'year': 'Undated',
                'full_place': 'Boring Place Anyway'}
        self._check_conversion(base_input.format(**data),
                               base_expected.format(**data), heading=False,
                               subheading=False)

    def test_return(self):
        text = 'Bam! new line'
        expected = 'Bam<lb /> new line'
        self._check_conversion(text, expected)

    def test_right_marginale(self):
        text = 'Hark, a @r\\right marginale note@r/ appears'
        expected = 'Hark, a <note type="marginal" place="margin_right">right marginale note</note> appears'
        self._check_conversion(text, expected)

    def test_section(self):
        text = 'A new section? @% Yes.'
        expected = 'A new section? \N{SECTION SIGN} Yes.'
        self._check_conversion(text, expected)

    def test_semicolon(self):
        text = 'PUA @; punctus elevatus'
        expected = 'PUA \uF161 punctus elevatus'
        self._check_conversion(text, expected)

    def test_signed(self):
        text = '@sn\\Thomas dyckes@sn/'
        expected = '<seg type="signed">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_centre(self):
        text = '@snc\\Thomas dyckes@snc/'
        expected = '<seg type="signed" rend="center">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_right(self):
        text = '@snr\\Thomas dyckes@snr/'
        expected = '<seg type="signed" rend="right">Thomas dyckes</seg>'
        self._check_conversion(text, expected)

    def test_signed_mark(self):
        text = '@sm\\Who even knows@sm/'
        expected = '<seg type="signed_mark">Who even knows</seg>'
        self._check_conversion(text, expected)

    def test_signed_mark_centre(self):
        text = '@smc\\Who even knows@smc/'
        expected = '<seg type="signed_mark" rend="center">Who even knows</seg>'
        self._check_conversion(text, expected)

    def test_signed_mark_right(self):
        text = '@smr\\Who even knows@smr/'
        expected = '<seg type="signed_mark" rend="right">Who even knows</seg>'
        self._check_conversion(text, expected)

    def test_special_v(self):
        text = 'Special @v, not k'
        expected = 'Special \N{LATIN SMALL LETTER MIDDLE-WELSH V}, not k'
        self._check_conversion(text, expected)

    def test_square_brackets(self):
        text = 'Literal [[.'
        expected = 'Literal [.'
        self._check_conversion(text, expected)
        text = 'Literal ]].'
        expected = 'Literal ].'
        self._check_conversion(text, expected)
        text = '[[ no del here ]]'
        expected = '[ no del here ]'
        self._check_conversion(text, expected)

    def test_superscript(self):
        text = 'Some @s\\superscripted@s/ text'
        expected = 'Some <hi rend="superscript">superscripted</hi> text'
        self._check_conversion(text, expected)

    def test_tab_start(self):
        text = '@[This should be right aligned.@]'
        expected = '<hi rend="right">This should be right aligned.</hi>'
        self._check_conversion(text, expected)

    def test_table(self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n<c>text</c>\n</r>\n</t>'
        expected = '<table>\n<row>\n<cell></cell>\n<cell>Some</cell>\n<cell>text</cell>\n</row>\n</table>'
        self._check_conversion(text, expected)

    def test_table_with_comment(self):
        text = '<t>\n<r>\n<c></c>\n<c>Some</c>\n@xc\\A comment@xc/\n<c>text</c>\n</r>\n</t>'
        expected = '<table>\n<row>\n<cell></cell>\n<cell>Some</cell>\n<!-- A comment -->\n<cell>text</cell>\n</row>\n</table>'
        self._check_conversion(text, expected)

    def test_THORN(self):
        text = '@THat is silly and wrong'
        expected = '\N{LATIN CAPITAL LETTER THORN}at is silly and wrong'
        self._check_conversion(text, expected)

    def test_thorn(self):
        text = 'A @thin man'
        expected = 'A \N{LATIN SMALL LETTER THORN}in man'
        self._check_conversion(text, expected)

    def test_tilde(self):
        for char in self.vowels + ['n']:
            text = 'pa@"{}a'.format(char)
            expected = 'pa{}\N{COMBINING TILDE}a'.format(char)
            self._check_conversion(text, expected)

    def test_title(self):
        text = 'A <title>citation title</title> somewhere'
        expected = text
        self._check_conversion(text, expected)

    def test_transcription(self):
        text = '@w\\ f.40* {{(12 January) (Fortune: Warrant)}}\\!\nText'
        expected = '''<div xml:lang="lat" type="transcription">
<div>
<head> f.40* <supplied>(12 January) (Fortune: Warrant)</supplied></head>
<pb />
Text
</div>
</div>'''
        self._check_conversion(text, expected, subheading=False)
        base_text = '@w\\{head}\\!\nText'
        base_expected = '''<div xml:lang="lat" type="transcription">
<div>
<head>{head}</head>
{pb}
Text
</div>
</div>'''
        all_data = [
            {'head': 'single mb', 'pb': '<pb n="1" type="membrane" />'},
            {'head': 'mbs 2-4', 'pb': '<pb type="membrane" />'},
            {'head': 'sig B3', 'pb': '<pb n="B3" type="signature" />'},
            {'head': 'sigs B3-C5', 'pb': '<pb type="signature" />'},
            {'head': 'p 234', 'pb': '<pb n="234" type="page" />'},
            {'head': 'pp 2-4', 'pb': '<pb type="page" />'},
            {'head': 'ff [1v–2]', 'pb': '<pb type="folio" />'},
            {'head': 'f 46v', 'pb': '<pb n="46v" type="folio" />'},
            {'head': 'sheet 5', 'pb': '<pb n="5" type="sheet" />'},
            {'head': 'sheets 6-7', 'pb': '<pb type="sheet" />'},
            {'head': '', 'pb': ''}
        ]
        for data in all_data:
            self._check_conversion(
                base_text.format(**data), base_expected.format(**data),
                subheading=False)
        text = '@w\\ {{(12 January)}}\\!\nText'
        expected = '''<div xml:lang="lat" type="transcription">
<div>
<head> <supplied>(12 January)</supplied></head>

Text
</div>
</div>'''
        self._check_conversion(text, expected, subheading=False)

    def test_translation(self):
        text = '''@w\\f.40*\\!\nTextus
@tr\\@w\\f.40*\\!
Text@tr/'''
        expected = '''<div xml:lang="lat" type="transcription">
<div>
<head>f.40*</head>
<pb />
Textus

</div>
</div>
<div xml:lang="eng" type="translation">
<div>
<head>f.40*</head>
<pb />
Text
</div>
</div>'''
        self._check_conversion(text, expected, subheading=False)
        text = '''@w\\f.40*\\!\nTextus
@tr\\@w\\f.40*\\!
Text
@w\\f.41\\!
Totally new.@tr/'''
        expected = '''<div xml:lang="lat" type="transcription">
<div>
<head>f.40*</head>
<pb />
Textus

</div>
</div>
<div xml:lang="eng" type="translation">
<div>
<head>f.40*</head>
<pb />
Text

</div>
<div>
<head>f.41</head>
<pb />
Totally new.
</div>
</div>'''
        self._check_conversion(text, expected, subheading=False)

    def test_umlaut(self):
        for vowel in self.vowels:
            text = 'b@:{}t'.format(vowel)
            expected = 'b{}\N{COMBINING DIAERESIS}t'.format(vowel)
            self._check_conversion(text, expected)

    def test_wynn(self):
        text = 'All I do is @y'
        expected = 'All I do is \N{LATIN LETTER WYNN}'
        self._check_conversion(text, expected)

    def test_xml_escape(self):
        data = {'&': '&amp;', '<': '&lt;', '>': '&gt;'}
        for char, expected in data.items():
            text = 'a {} b'.format(char)
            expected = 'a {} b'.format(expected)
            self._check_conversion(text, expected)

    def test_YOGH(self):
        text = 'Not @Z Sothoth'
        expected = 'Not \N{LATIN CAPITAL LETTER YOGH} Sothoth'
        self._check_conversion(text, expected)

    def test_yogh(self):
        text = 'cummings invokes @z sothoth'
        expected = 'cummings invokes \N{LATIN SMALL LETTER YOGH} sothoth'
        self._check_conversion(text, expected)

    def test_nesting(self):
        # This is impossible to comprehensively test. Start with a few
        # examples and add more as problems are discovered.
        text = '@l\\@m\\ac@m/or @m\\a@m/@l/!'
        expected = '<note type="marginal" place="margin_left"><ab rend="center">ac</ab>or <ab rend="center">a</ab></note><lb />'
        self._check_conversion(text, expected)


class TestXSLT (TestCase):

    def setUp(self):
        self._doc = Document('staff')
        self.maxDiff = None

    def _transform(self, text, *xslt_paths):
        tree = etree.ElementTree(etree.fromstring(text))
        result_tree = self._doc._transform(tree, *xslt_paths)
        return etree.tostring(result_tree, encoding='unicode',
                              pretty_print=True)

    def test_ab_to_p(self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
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
<div type="endnote">
<ab>
End note text.</ab>
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
<div type="translation">
<div><head>@w head 2.1</head>
<pb/>

<ab>Translation text.</ab>
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
<div type="endnote">
<p>
End note text.</p>
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
<div type="translation">
<div><head>@w head 2.1</head>
<pb/>

<ab>Translation text.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, AB_TO_P_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_add_ab(self):
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
<div type="endnote">
End note text.<lb/>
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
<div type="translation">
<div>
<head>@w head 2.1</head>
<pb />
<lb/>Translation text.<lb/>
<lb/>
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
<div type="endnote">
<ab>
End note text.</ab>
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
<div type="translation">
<div><head>@w head 2.1</head>
<pb/>

<ab>Translation text.</ab>
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

    def test_add_header(self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="staff" xml:lang="eng">
<text>
<group>
<text type="record" xml:id="staff-ridm4">
<body xml:lang="lat">
<head>@h head 1</head>
<div type="transcription" xml:id="staff-ridm4-transcription">
<div>
<head>@w head 1.1</head>
<ab>Histrio non sum.</ab>
</div>
</div>
<div xml:lang="eng" type="translation">
<div>
<head>@w head 1.1</head>
<ab>I am not an actor.</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="staff" xml:lang="eng"><teiHeader><fileDesc><titleStmt/><sourceDesc/></fileDesc><encodingDesc><listPrefixDef><prefixDef ident="eats" matchPattern="([0-9]+)" replacementPattern="http://ereed.library.utoronto.ca/eats/entity/$1/"><p>URIs using the <code>eats</code> prefix are references to EATS entities.</p></prefixDef><prefixDef ident="gloss" matchPattern="([\S]+)" replacementPattern="../glossary.xml#$1"><p>Private URIs using the <code>gloss</code> prefix are pointers to entities in the glossary.xml file. For example, <code>gloss:histrio-1</code> dereferences to <code>glossary.xml#histrio-1</code>.</p></prefixDef><prefixDef ident="taxon" matchPattern="([A-Za-z0-9_-]+)" replacementPattern="../taxonomy.xml#$1"><p>Private URIs using the <code>taxon</code> prefix are pointers to entities in the taxonomy.xml file. For example, <code>taxon:church</code> dereferences to <code>taxonomy.xml#church</code>.</p></prefixDef></listPrefixDef></encodingDesc><profileDesc><langUsage><language ident="eng">English</language><language ident="lat">Latin</language></langUsage></profileDesc></teiHeader>
<text>
<group>
<text type="record" xml:id="staff-ridm4">
<body xml:lang="lat">
<head>@h head 1</head>
<div type="transcription" xml:id="staff-ridm4-transcription">
<div>
<head>@w head 1.1</head>
<ab>Histrio non sum.</ab>
</div>
</div>
<div xml:lang="eng" type="translation">
<div>
<head>@w head 1.1</head>
<ab>I am not an actor.</ab>
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

    def test_add_id(self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <note type="collation">collated material</note>.</ab>
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
<div type="endnote">
<ab>An end note.</ab>
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
<ab>Some text with <note type="collation">collated material</note>.</ab>
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
<ab>Nothing here but a <note type="marginal" place="margin_left">marginal note</note> and a <note type="foot">footnote</note>.</ab>
</div>
</div>
<div type="endnote">
<ab>An end note.</ab>
</div>
</body>
</text>
</group>
</text>
</TEI>
'''
        actual = self._transform(text, ADD_ID_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_massage_footnote(self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head>@h head 1</head>
<div type="transcription">
<div>
<head>@w head 1.1</head>
<ab>Some text with <note type="foot">with: <gap reason="omitted" /> <hi rend="italic">see f [1v].</hi></note>.</ab>
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
<ab>Some text with <note type="foot">with: … <hi rend="italic">see f [1v].</hi></note>.</ab>
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

    def test_remove_ab(self):
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

    def test_sort_records(self):
        text = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group>
<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Stafford</rs> <date when-iso="1540">1540</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text>
<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Stafford</rs> <date from-iso="1501" to-iso="160">16th Century</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text>
<text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Burton on Trent</rs> <date when-iso="1535">1535</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text>
</group>
</text>
</TEI>'''
        expected = '''<TEI xmlns="http://www.tei-c.org/ns/1.0">
<text>
<group><text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Burton on Trent</rs> <date when-iso="1535">1535</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text><text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Stafford</rs> <date from-iso="1501" to-iso="160">16th Century</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text><text type="record">
<body>
<head><rs>Staffordshire</rs>, <rs>Stafford</rs> <date when-iso="1540">1540</date> <seg ana="taxon:ABCD">ABCD</seg></head>
<div type="transcription">
<div>
<head>Heading</head>
<ab>Text</ab>
</div>
</div>
</body>
</text></group>
</text>
</TEI>
'''
        actual = self._transform(text, SORT_RECORDS_XSLT_PATH)
        self.assertEqual(actual, expected)

    def test_tidy_bibls(self):
        text = '''<listBibl xmlns="http://www.tei-c.org/ns/1.0">
<msDesc xml:id="ABCD">
<msIdentifier>
<settlement>Bognor Regis</settlement>
<repository>Boris's Borough Books &amp; Records</repository>
<idno type="shelfmark">127.43#61-4/AN</idno>
<msName>Heading</msName>
</msIdentifier>
<ab type="edDesc">Prose<pb/>paragraph.</ab>
<ab type="techDesc">Technical<pb />paragraph.</ab>
</msDesc>
</listBibl>'''
        expected = '''<listBibl xmlns="http://www.tei-c.org/ns/1.0">
<msDesc xml:id="ABCD">
<msIdentifier>
<settlement>Bognor Regis</settlement>
<repository>Boris's Borough Books &amp; Records</repository>
<idno type="shelfmark">127.43#61-4/AN</idno>
<msName>Heading</msName>
</msIdentifier>
<ab type="edDesc">Prose|paragraph.</ab>
<ab type="techDesc">Technical|paragraph.</ab>
</msDesc>
</listBibl>
'''
        actual = self._transform(text, TIDY_BIBLS_XSLT_PATH)
        self.assertEqual(actual, expected)
