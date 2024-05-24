# Records of Early English Drama (REED)

Records of Early English Drama (REED) is an international research collaboration
that is establishing for the first time the context from which the drama of
Shakespeare and his contemporaries grew.

The project is [TEI XML](https://tei-c.org/)-based
published via [Apache Cocoon](https://cocoon.apache.org/), a
[Tomcat](https://tomcat.apache.org/) web application. The project has
been containerised using [Docker Compose](https://docs.docker.com/compose/) to
enhance deployment efficiency and sustainability. The containerised setup
comprises five main services: an
[nginx proxy](https://github.com/nginx-proxy/nginx-proxy), a Tomcat server, a
[Django](http://djangoproject.com/) application, a
[Postgres](http://postgresql.org/) database, and an
[nginx](https://www.nginx.com/) server.

1. [`nginx-proxy`](https://hub.docker.com/r/nginxproxy/nginx-proxy): This
   service acts as a reverse proxy, dynamically routing incoming HTTP requests
   to the appropriate backend services based on the requested hostname and path.
   It ensures that traffic is directed correctly and efficiently within the
   application infrastructure.
1. [`tomcat`](https://hub.docker.com/_/tomcat): This service hosts the
   Java-based web application. It is responsible for processing and delivering
   dynamic content generated from the TEI XML data.
1. [`django`](https://hub.docker.com/_/python): This service runs the Django web
   application framework, which is used for developing the backend of the
   project.
1. [`postgres`](https://hub.docker.com/_/postgres): This service runs the
   PostgreSQL database. It stores all the data for the Django application.
1. [`nginx`](https://hub.docker.com/_/nginx): This service is dedicated to
   serving static assets, images, and other resources required by the web
   application. By offloading the delivery of static content to a separate
   server, it improves the overall performance and responsiveness of the web
   application.

# Get Started

Follow these steps to set up and run the project using Docker Compose.

**Note** that these instructions cover only the local setup; server deployment
is not covered here.

### Pre-requisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/)

### Running the application

1. **Clone this repository**
1. **Set up the environment file**

Create a `.env` file inside the compose directory with the following content:

```sh
# Set to true in production environments
PRODUCTION=false

# Ports for nginx proxy
NGINX_PROXY_PORTS=80:80

# Django settings
DJANGO_ADMINS=("eREED Admin", "reedkiln@library.utoronto.ca")
DJANGO_SERVER_EMAIL=reedkiln@library.utoronto.ca
DJANGO_DEFAULT_FROM_EMAIL=reedkiln@library.utoronto.ca
# Use a strong and unique key in production
DJANGO_SECRET_KEY=generate_secret_key
DJANGO_VIRTUAL_PATH=~^/(accounts|djadmin|eats)/

# Nginx settings
NGINX_VIRTUAL_PATH=~^/(assets/|solr/|static/|robots.txt)

# PostgreSQL settings
# In production, use Docker secrets or environment variables managed by the orchestrator
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_DB=database_name
DATABASE_USER=database_user
DATABASE_PASSWORD=database_pwd

# Tomcat settings
TOMCAT_VIRTUAL_PATH=/

# Host settings
VIRTUAL_HOST=localhost,127.0.0.1
```

Ensure to replace database_name, database_user, and database_pwd with your
actual database credentials.

1. **Start the services**

   Use Docker Compose to build and start the services:

   ```bash
   docker compose up --build
   ```

1. **Access the application**

   Once all services are running, you can access the web application via your
   web browser at [http://localhost/](http://localhost/).

1. **Load data into the database**

   Get a copy of the database data and make sure it is compressed with `gzip`,
   place the file in `volumes/postgres_backups` and run the command:

   ```bash
   docker compose exec postgres restore db_backup_name.sql.gz
   ```

   If you get the error `dropdb: error: database removal failed: ERROR:  
 database "ereed" is being accessed by other users` when running the command,
   stop the django service `docker compose stop django` and run the restore
   command again.

   After restoring a database backup it is recommended to stop and restart the
   whole Docker stack.

1. **Stop the services**

   To stop the application press CTRL+C in the same terminal window where the
   compose script is running. Or in a different terminal window:

   ```bash
    docker compose stop
   ```
