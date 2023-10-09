FROM python:3.12.0-alpine

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
LABEL org.opencontainers.image.authors="info@khulnasoft.com"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
# TODO: Change this to 2048.  See khulnasoft-lab/orchestrator#130 for more
# details.
ARG KHULNASOFT_UID=421
ARG KHULNASOFT_GID=${KHULNASOFT_UID}
ARG KHULNASOFT_USER="khulnasoft"
ENV KHULNASOFT_GROUP=${KHULNASOFT_USER}
ENV KHULNASOFT_HOME="/home/${KHULNASOFT_USER}"

###
# Upgrade the system
#
# Note that we use apk --no-cache to avoid writing to a local cache.
# This results in a smaller final image, at the cost of slightly
# longer install times.
###
RUN apk --update --no-cache --quiet upgrade

###
# Create unprivileged user
###
RUN addgroup --system --gid ${KHULNASOFT_UID} ${KHULNASOFT_GROUP} \
    && adduser --system --uid ${KHULNASOFT_UID} --ingroup ${KHULNASOFT_GROUP} ${KHULNASOFT_USER}

###
# Dependencies
#
# We need redis so we can use redis-cli to communicate with redis.  I
# also reinstall wget with openssl, since otherwise wget does not seem
# to know how to HTTPS.
#
# Note that we use apk --no-cache to avoid writing to a local cache.
# This results in a smaller final image, at the cost of slightly
# longer install times.
###
ENV DEPS \
    openssl \
    redis \
    wget
RUN apk --no-cache --quiet add ${DEPS}

###
# Make sure pip, setuptools, and wheel are the latest versions
#
# Note that we use pip3 --no-cache-dir to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN pip3 install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel

###
# Install Python dependencies
###
RUN pip3 install --no-cache-dir --upgrade \
    https://github.com/khulnasoft-lab/mongo-db-from-config/tarball/develop \
    pytz

###
# Put this just before we change users because the copy (and every
# step after it) will always be rerun by Docker, but we need to be
# root for the chown command.
###
COPY src/*.py src/*.sh ${KHULNASOFT_HOME}
COPY src/include ${KHULNASOFT_HOME}/include
RUN chown -R ${KHULNASOFT_USER}:${KHULNASOFT_GROUP} ${KHULNASOFT_HOME}

###
# Prepare to run
###
# TODO: Right now we need to be root at runtime in order to create
# files in ${KHULNASOFT_HOME}/shared, but see khulnasoft-lab/orchestrator#130.
# USER ${KHULNASOFT_USER}:${KHULNASOFT_GROUP}
WORKDIR ${KHULNASOFT_HOME}
ENTRYPOINT ["./save_to_db.sh"]
