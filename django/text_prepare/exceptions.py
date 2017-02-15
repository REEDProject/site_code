class TextPrepareDocumentError (Exception):

    """Base class for exceptions involving uploaded documents."""

    pass


class TextPrepareDocumentValidationError (TextPrepareDocumentError):

    """Exception class for document validation errors."""

    pass
