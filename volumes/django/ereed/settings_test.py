import os
from .settings import *

# Set the testing flag
TESTING = True

# Use an in-memory SQLite database for faster tests
DATABASES = {
    "default": {
        "ENGINE": "django.contrib.gis.db.backends.spatialite",
        "NAME": ":memory:",
    }
}

SPATIALITE_LIBRARY_PATH = "mod_spatialite"

# Use a fast password hasher for testing
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]

# Reduce logging output during tests
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {
            "level": "ERROR",
            "class": "logging.StreamHandler",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": "ERROR",
            "propagate": True,
        },
    },
}

# Configure a simpler cache backend for testing
CACHES = {
    "django_cache_manager.cache_backend": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "unique-snowflake",
    }
}

# Set a different secret key for testing
SECRET_KEY = "test-secret-key"


# Disable migrations to speed up tests
class DisableMigrations(object):
    def __contains__(self, item):
        return True

    def __getitem__(self, item):
        return None


MIGRATION_MODULES = DisableMigrations()

# Optionally disable middleware that you do not need during testing
MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# Use a simpler email backend for testing
EMAIL_BACKEND = "django.core.mail.backends.locmem.EmailBackend"
