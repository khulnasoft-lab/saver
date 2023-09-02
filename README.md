# pshtt, trustymail, and sslyze Saver #

[![GitHub Build Status](https://github.com/khulnasoft-lab/saver/workflows/build/badge.svg)](https://github.com/khulnasoft-lab/saver/actions/workflows/build.yml)
[![CodeQL](https://github.com/khulnasoft-lab/saver/workflows/CodeQL/badge.svg)](https://github.com/khulnasoft-lab/saver/actions/workflows/codeql-analysis.yml)
[![Known Vulnerabilities](https://snyk.io/test/github/khulnasoft-lab/saver/badge.svg)](https://snyk.io/test/github/khulnasoft-lab/saver)

## Docker Image ##

[![Docker Pulls](https://img.shields.io/docker/pulls/khulnasoft-lab/saver)](https://hub.docker.com/r/khulnasoft-lab/saver)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/khulnasoft-lab/saver)](https://hub.docker.com/r/khulnasoft-lab/saver)
[![Platforms](https://img.shields.io/badge/platforms-amd64%20%7C%20arm%2Fv6%20%7C%20arm%2Fv7%20%7C%20arm64%20%7C%20ppc64le%20%7C%20s390x-blue)](https://hub.docker.com/r/khulnasoft-lab/saver/tags)

This is a Docker container for saving to a [Mongo
database](https://www.mongodb.com/)
[pshtt](https://github.com/khulnasoft-lab/pshtt),
[trustymail](https://github.com/khulnasoft-lab/trustymail), and
[sslyze](https://github.com/nabla-c0d3/sslyze) results collected via
[domain-scan](https://github.com/18F/domain-scan).

This Docker container is intended to be run via
[orchestrator](https://github.com/khulnasoft-lab/orchestrator).

**N.B.:** The secrets in the `src/secrets` directory are only used
when testing via the `docker-compose.yml` composition.  Normally this
Docker container is run via the Docker composition in
[khulnasoft-lab/orchestrator](https://github.com/khulnasoft-lab/orchestrator), which
expects the secrets in a different location.

## Running ##

### Running with Docker ###

To run the `khulnasoft-lab/saver` image via Docker:

```console
docker run khulnasoft/saver:1.3.2
```

### Running with Docker Compose ###

1. Create a `docker-compose.yml` file similar to the one below to use [Docker Compose](https://docs.docker.com/compose/).

    ```yaml
    ---
    version: "3.7"

    services:
      saver:
        image: khulnasoft-lab/saver:1.3.2
        volumes:
          - type: bind
            source: <your_log_dir>
            target: /home/khulnasoft/shared
    ```

1. Start the container and detach:

    ```console
    docker compose up --detach
    ```

## Using secrets with your container ##

This container also supports passing sensitive values via [Docker
secrets](https://docs.docker.com/engine/swarm/secrets/).  Passing sensitive
values like your credentials can be more secure using secrets than using
environment variables.  See the
[secrets](#secrets) section below for a table of all supported secret files.

1. To use secrets, create a `database_creds.yml` file in [this
   format](https://github.com/khulnasoft-lab/mongo-db-from-config#usage):

    ```yaml
    ---
    version: '1'

    database:
      name: cyhy
      uri: mongodb://user:the_password@cyhy.example.com:27017/cyhy

    ```

1. Then add the secrets to your `docker-compose.yml` file:

    ```yaml
    ---
    version: "3.7"

    secrets:
      database_creds:
        file: database_creds.yml

    services:
      trustymail_reporter:
        image: khulnasoft-lab/saver:1.3.2
        volumes:
          - type: bind
            source: <your_log_dir>
            target: /home/khulnasoft/shared
        secrets:
          - source: database_creds
            target: database_creds.yml
    ```

## Updating your container ##

### Docker Compose ###

1. Pull the new image from Docker Hub:

    ```console
    docker compose pull
    ```

1. Recreate the running container by following the [previous instructions](#running-with-docker-compose):

    ```console
    docker compose up --detach
    ```

### Docker ###

1. Stop the running container:

    ```console
    docker stop <container_id>
    ```

1. Pull the new image:

    ```console
    docker pull khulnasoft-lab/saver:1.3.2
    ```

1. Recreate and run the container by following the [previous instructions](#running-with-docker).

## Image tags ##

The images of this container are tagged with [semantic
versions](https://semver.org) of the underlying saver project that they
containerize.  It is recommended that most users use a version tag (e.g.
`:1.3.2`).

| Image:tag | Description |
|-----------|-------------|
|`khulnasoft-lab/saver:1.3.2`| An exact release version. |
|`khulnasoft-lab/saver:1.3`| The most recent release matching the major and minor version numbers. |
|`khulnasoft-lab/saver:1`| The most recent release matching the major version number. |
|`khulnasoft-lab/saver:edge` | The most recent image built from a merge into the `develop` branch of this repository. |
|`khulnasoft-lab/saver:nightly` | A nightly build of the `develop` branch of this repository. |
|`khulnasoft-lab/saver:latest`| The most recent release image pushed to a container registry.  Pulling an image using the `:latest` tag [should be avoided.](https://vsupalov.com/docker-latest-tag/) |

See the [tags tab](https://hub.docker.com/r/khulnasoft-lab/saver/tags) on Docker
Hub for a list of all the supported tags.

## Volumes ##

| Mount point | Purpose        |
|-------------|----------------|
| /home/khulnasoft/shared | Output |

## Ports ##

There are no ports exposed by this container.

<!-- The following ports are exposed by this container: -->

<!-- | Port | Purpose        | -->
<!-- |------|----------------| -->
<!-- | 8080 | Example only; nothing is actually listening on the port | -->

<!-- The sample [Docker composition](docker-compose.yml) publishes the -->
<!-- exposed port at 8080. -->

## Environment variables ##

### Required ###

There are no required environment variables.

<!--
| Name  | Purpose | Default |
|-------|---------|---------|
| `REQUIRED_VARIABLE` | Describe its purpose. | `null` |
-->

### Optional ###

There are no optional environment variables.

<!--
| Name  | Purpose | Default |
|-------|---------|---------|
| `OPTIONAL_VARIABLE` | Describe its purpose. | `null` |
-->

## Secrets ##

| Filename      | Purpose              |
|---------------|----------------------|
| database_creds.yml | Cyber Hygiene read-only database credentials in [this format](https://github.com/khulnasoft-lab/mongo-db-from-config#usage). |

## Building from source ##

Build the image locally using this git repository as the [build context](https://docs.docker.com/engine/reference/commandline/build/#git-repositories):

```console
docker build \
  --build-arg VERSION=1.3.2 \
  --tag khulnasoft-lab/saver:1.3.2 \
  https://github.com/khulnasoft-lab/saver.git#develop
```

## Cross-platform builds ##

To create images that are compatible with other platforms, you can use the
[`buildx`](https://docs.docker.com/buildx/working-with-buildx/) feature of
Docker:

1. Copy the project to your machine using the `Code` button above
   or the command line:

    ```console
    git clone https://github.com/khulnasoft-lab/saver.git
    cd saver
    ```

1. Create the `Dockerfile-x` file with `buildx` platform support:

    ```console
    ./buildx-dockerfile.sh
    ```

1. Build the image using `buildx`:

    ```console
    docker buildx build \
      --file Dockerfile-x \
      --platform linux/amd64 \
      --build-arg VERSION=1.3.2 \
      --output type=docker \
      --tag khulnasoft-lab/saver:1.3.2 .
    ```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
