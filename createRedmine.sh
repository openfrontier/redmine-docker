#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-sameersbn/redmine}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}
GERRIT_VOLUME=${GERRIT_VOLUME:-gerrit-volume}

# Start PostgreSQL.
docker run \
--name ${PG_REDMINE_NAME} \
-P \
-e POSTGRES_USER=redmine \
-e POSTGRES_PASSWORD=redmine \
-e POSTGRES_DB=redmine \
-d postgres

while [ -z "$(docker logs ${PG_REDMINE_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

# Create Redmine volume.
docker run \
--name ${REDMINE_VOLUME} \
-v ~/redmine-docker/init:/app/init \
${REDMINE_IMAGE_NAME} \
app:volume

# Start Gerrit.
docker run \
--name=${REDMINE_NAME} \
--link pg-redmine:postgresql \
-e DB_NAME=redmine \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
--volumes-from ${REDMINE_VOLUME} \
--volumes-from ${GERRIT_VOLUME}:ro \
-d ${REDMINE_IMAGE_NAME}
