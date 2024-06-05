FROM python:3.8-slim-bookworm

ARG APP_HOME=/app
ARG EXPORTS_HOME=/exports

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV BUILD_ENV ${BUILD_ENVIRONMENT}

WORKDIR ${APP_HOME}

RUN addgroup --system django \
  && adduser --system --ingroup django django

RUN apt-get update \
  # dependencies for building Python packages
  && apt-get install -y build-essential git \
  # curl for node
  # curl \
  # psycopg2 dependencies
  libpq-dev \
  # gdal libraries
  binutils libproj-dev gdal-bin libsqlite3-mod-spatialite \
  # lxml depedndencies
  # libxml2-dev libxslt-dev python-dev \
  # python3-lxml \
  # cleaning up unused files
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

COPY ./django/requirements.txt /requirements/
RUN pip install -U pip \
  && pip install -r /requirements/requirements.txt

COPY ./services/django/patches/base.py /usr/local/lib/python3.8/site-packages/django/db/models/
COPY ./services/django/patches/libgeos.py /usr/local/lib/python3.8/site-packages/django/contrib/gis/geos/

COPY --chown=django:django ./services/django/entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint
RUN chmod +x /entrypoint

RUN chown -R django:django ${APP_HOME}
RUN mkdir -p ${EXPORTS_HOME} \
  && chown -R django:django ${EXPORTS_HOME}

USER django

ENTRYPOINT ["/entrypoint"]
# ENTRYPOINT ["tail", "-f", "/dev/null"]