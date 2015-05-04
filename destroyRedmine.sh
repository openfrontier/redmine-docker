#/bin/bash

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}

docker stop ${REDMINE_NAME}
docker rm -v ${REDMINE_NAME}
docker stop ${PG_REDMINE_NAME}
docker rm -v ${PG_REDMINE_NAME}
