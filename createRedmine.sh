#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-sameersbn/redmine}

docker run \
--name ${PG_REDMINE_NAME} \
-P \
-e POSTGRES_USER=redmine \
-e POSTGRES_PASSWORD=redmine \
-e POSTGRES_DB=redmine \
-d postgres

while [ -z "$(docker logs ${PG_REDMINE_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 5
done

docker run \
--name=${REDMINE_NAME} \
--link pg-redmine:postgresql \
-e DB_NAME=redmine \
-e DB_USER=redmine \
-e DB_PASS=redmine \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
--volumes-from gerrit \
-d ${REDMINE_IMAGE_NAME}
