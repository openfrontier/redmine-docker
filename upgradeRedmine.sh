#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-sameersbn/redmine}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}
GERRIT_VOLUME=${GERRIT_VOLUME:-gerrit-volume}

# Stop and remove redmine container.
docker stop ${REDMINE_NAME}
docker rm -v ${REDMINE_NAME}

# Start Redmine.
docker run \
--name=${REDMINE_NAME} \
--link ${PG_REDMINE_NAME}:postgresql \
-e DB_NAME=redmine \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
--volumes-from ${REDMINE_VOLUME} \
--volumes-from ${GERRIT_VOLUME}:ro \
-d ${REDMINE_IMAGE_NAME}
