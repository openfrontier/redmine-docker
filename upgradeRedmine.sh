#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-sameersbn/redmine}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}
GERRIT_VOLUME=${GERRIT_VOLUME:-gerrit-volume}
NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}

# Stop and remove redmine container.
if [ -z "$(docker ps -a | grep ${REDMINE_VOLUME})" ]; then
  echo "${REDMINE_VOLUME} does not exist."
  exit 1
elif [ -z "$(docker ps -a | grep ${PG_REDMINE_NAME})" ]; then
  echo "${PG_REDMINE_NAME} does not exist."
  exit 1
elif [ -n "$(docker ps -a | grep ${REDMINE_NAME} | grep -v ${REDMINE_VOLUME} | grep -v ${PG_REDMINE_NAME})" ]; then
  docker stop ${REDMINE_NAME}
  docker rm -v ${REDMINE_NAME}
fi

# Start Redmine.
docker run \
--name=${REDMINE_NAME} \
--link ${PG_REDMINE_NAME}:postgresql \
-e DB_NAME=redmine \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
-e SMTP_DOMAIN=${HOST_NAME} \
-e SMTP_HOST=${SMTP_SERVER} \
-e SMTP_PORT=${SMTP_PORT} \
-e SMTP_USER=${SMTP_USER} \
-e SMTP_PASS=${SMTP_PASS} \
-e NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE} \
--volumes-from ${REDMINE_VOLUME} \
--volumes-from ${GERRIT_VOLUME}:ro \
--restart=unless-stopped \
-d ${REDMINE_IMAGE_NAME}
