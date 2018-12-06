# Shlink Docker image

[Shlink](https://shlink.io) is a self-hosted URL shortener which includes both a REST and a CLI interface in order to interact with it.

This image provides an easy way to set up [shlink](https://shlink.io) on a container-based runtime.

It exposes a shlink instance served with [swoole](https://www.swoole.co.uk/), which persists data in a local [sqlite](https://www.sqlite.org/index.html) database.

## Usage

Shlink docker image exposes port `8080` in order to interact with its HTTP interface.

It also expects these two env vars to be provided, in order to properly generate short URLs at runtime.

* `SHORT_DOMAIN_HOST`: The custom short domain used for this shlink instance. For example **doma.in**.
* `SHORT_DOMAIN_SCHEMA`: Either **http** or **https**.

So based on this, to run shlink on a local docker service, you should run a command like this:

```bash
docker run --name shlink -p 8080:8080 -e SHORT_DOMAIN_HOST=doma.in -e SHORT_DOMAIN_SCHEMA=https shlinkio/shlink
```

### Interact with shlink's CLI on a running container.

### Interact with shlink's CLI as a stopped container entry point.

## Use external DB

The image comes with a working sqlite database, but in production you will probably want to usa a distributed database.

It is possible to use a set of env vars to make this shlink instance interact with an external MySQL database (PostgreSQL support will be included soon).

* `DB_DRIVER`: **[Mandatory]**. Use the value **mysql** to prevent the sqlite database to be used.
* `DB_NAME`: [Optional]. The database name to be used. Defaults to **shlink**.
* `DB_USER`: **[Mandatory]**. The username credential for the MySQL server.
* `DB_PASSWORD`: **[Mandatory]**. The password credential for the MySQL server.
* `DB_HOST`: **[Mandatory]**. The host name of the server running the MySQL engine.
* `DB_PORT`: [Optional]. The port in which the MySQL service is running. Defaults to **3306**.

Taking this into account, you could run set up shlink on a local docker service like this:

```bash
docker run --name shlink -p 8080:8080 -e SHORT_DOMAIN_HOST=doma.in -e SHORT_DOMAIN_SCHEMA=https -e DB_DRIVER=mysql -e DB_USER=root -e DB_PASSWORD=123abc -e DB_HOST=something.rds.amazonaws.com shlinkio/shlink
```

You could even link to a local database running on a different container:

```bash
docker run --name shlink -p 8080:8080 [...] -e DB_HOST=some_mysql_container --link some_mysql_container shlinkio/shlink
```

## Supported env vars

A few env vars have been already used in previous examples, but this image supports others that can be used to customize its behavior.

This is the complete list of supported env vars:

* `SHORT_DOMAIN_HOST`: The custom short domain used for this shlink instance. For example **doma.in**.
* `SHORT_DOMAIN_SCHEMA`: Either **http** or **https**.
* `DB_DRIVER`: Either **sqlite** or **mysql**.
* `DB_NAME`: The database name to be used when the driver is mysql. Defaults to **shlink**.
* `DB_USER`: The username credential to be used when the driver is mysql.
* `DB_PASSWORD`: The password credential to be used when the driver is mysql.
* `DB_HOST`: The host name of the database server  when the driver is mysql.
* `DB_PORT`: The port in which the database service is running when the driver is mysql. Defaults to **3306**.
* `DISABLE_TRACK_PARAM`: The name of a query param that can be used to visit short URLs avoiding the visit to be tracked. This feature won't be available if not value is provided.
* `DELETE_SHORT_URL_THRESHOLD`: The amount of visits on short URLs which will not allow them to be deleted. Defaults to `15`.
* `LOCALE`: Defines the default language for error pages when a user accesses a short URL which does not exist. Supported values are **es** and **en**. Defaults to **en**.
* `VALIDATE_URLS`: Boolean which tells if shlink should validate a status 20x (after following redirects) is returned when trying to shorten a URL. Defaults to `true`.
* `NOT_FOUND_REDIRECT_TO`: If a URL is provided here, when a user tries to access an invalid short URL, he/she will be redirected to this value. If this env var is not provided, the user will see a generic `404 - not found` page.

## Versions

Currently, the versions of this image match the shlink version it contains.

For example, installing shlinkio/shlink:v1.15.0, you will get an image containing shlink v1.15.0.

There are no official shlink images previous to v1.15.0.
