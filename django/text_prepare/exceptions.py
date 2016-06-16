class TextPrepareDocumentError (Exception):

    """Base class for exceptions involving uploaded documents."""

    pass


class TextPrepareDocumentTextExtractionError (TextPrepareDocumentError):

    """Exception class for errors pertaining to extracting the text from
    an uploaded document."""

    pass


class TextPrepareDocumentUpdateError (TextPrepareDocumentError):

    """Exception class for errors pertaining to updating a Word
    document."""

    pass


class TextPrepareDocumentValidationError (TextPrepareDocumentError):

    """Exception class for document validation errors."""

    pass
