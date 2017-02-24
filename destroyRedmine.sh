#/bin/bash

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}

docker stop ${REDMINE_NAME}
docker rm -v ${REDMINE_NAME}
docker stop ${PG_REDMINE_NAME}
docker rm -v ${PG_REDMINE_NAME}
docker volume rm redmine-data-volume
docker volume rm redmine-log-volume
