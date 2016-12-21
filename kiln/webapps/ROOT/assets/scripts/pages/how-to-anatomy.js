$(document).ready(function() {
        var intro = introJs();
        intro.setOptions({
            steps: [
                {
                    element: '#step1',
                    title: 'Place &amp; Date',
                    intro: 'The place and the date or date range to which the record relates. Imagine the situation where we knew your own journal covered a couple of years, but we were not sure to which exact date within those years a particular entry referred.',
                    note: 'A date range is shown as you would expect with a dash, eg, 1452–3. But, if you come across a date with a diagonal in it, such as 1452/3, this means that the date of the record falls between 1 January 1453 and 24 March 1453. The weird description comes about because the scribe would have thought of that period as falling in 1452, whereas since 1752 (England) and 1600 (Scotland), we have thought of the new year as beginning on 1 January not 25 March, and so we would regard that as coming from 1453.',
                    position: "right"

                },
                {
                    element: '#step2',
                    title: 'Document Title',
                    intro: "This will usually be a descriptive title. If a record has come down to us through the work of antiquaries, that will be shown by an \'(A)\' after the title.",
                    position: 'bottom-right-aligned'
                },
                {
                    element: '#step3',
                    title: 'Archive &amp; Shelfmark',
                    intro: 'The archive where you can find the document, followed by the shelfmark as used by the archive.',
                    position: 'right'
                },
                {
                    element: '#step4',
                    title: 'Date &amp; Subtitle',
                    intro: 'This line can contain three main bits of information: (a) Where precisely the record itself appears in the document, usually identified by a page, folio, or membrane number, (b) in brackets any narrower date that we can offer for the date of the record itself, and (c) in brackets any relevant subtitle, if there is one, to show the original scribe\'s categorization of the record.',
                    note: 'All this information is about the record, not about the event to which it relates. Sometimes you can work that out, but not always.',
                    position: 'right'
                },
                {
                    element: '#step5',
                    title: 'Language &amp; Spelling',
                    intro: 'We do not change the language or spelling of the record (we have translations and glossary definitions to help instead).',
                    position: 'right'
                },
                {
                    element: '#step6',
                    title: 'Unreadable Text',
                    intro: 'If text is unreadable, we show this by angle brackets around the number of letters we think might be missing, indicated by dots.',
                    position: 'bottom-right-aligned'
                },
                {
                    element: '#step7',
                    title: 'Expanded Abbreviations & Contractions',
                    intro: 'We do always expand abbreviations or contractions, where possible according to the scribe’s preference, but we show that we have done this by putting the expanded material in italics.',
                    position: 'bottom'
                },
                {
                    element: '#step8',
                    intro: 'If there was a space left in the original text, eg, for a name that was not subsequently filled in, we show it by writing <i>(blank)</i>.',
                    title: 'Space In Original Text',
                    position: 'right'
                },
                {
                    element: '#step9',
                    title: 'Omitted Text',
                    intro: 'We use ellipses to show where we have omitted text that is not essential.',
                    position: 'right',
                }
            ],
            showStepNumbers: 'false',
            nextLabel:       'Next',
            prevLabel:       'Prev',

        });
    $('.walkthrough').on('click', function() {
        intro.exit();
        if ($(this).attr("id") != 'step1') {
            let num =  $(this).attr("id").match(/\d+/)[0];
            intro.goToStep(num-1).start();
        }
        else {
            intro.start();
        }
    });

});
$(window).load(function() {
    $(".close-walkthrough").on("click", function() {
        alert("stuff");
        intro.exit();
    })
})
