#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
POSTGRES_IMAGE=${POSTGRES_IMAGE:-postgres}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-openfrontier/redmine:agile}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}
GERRIT_VOLUME=${GERRIT_VOLUME:-gerrit-volume}

NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE:-200m}
REDMINE_SYS_DATA_SQL=redmine-init-system.sql
REDMINE_DEMO_DATA_SQL=redmine-init-demo.sql
INIT_DATE=`date +%Y-%m-%d\ %H:%M:%S.%N|cut -c 1-26`

CI_NETWORK=${CI_NETWORK:-ci-network}

# Redmine init data
sed -e "s/{INIT_DATE}/${INIT_DATE}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}.template > ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -i "s/{HOST_IP}/${LDAP_SERVER}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -i "s/{LDAP_ACCOUNTBASE}/${LDAP_ACCOUNTBASE}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -e "s/{INIT_DATE}/${INIT_DATE}/g" ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}.template > ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}

# Start PostgreSQL.
docker run \
--name ${PG_REDMINE_NAME} \
--net ${CI_NETWORK} \
-P \
-e POSTGRES_USER=redmine \
-e POSTGRES_PASSWORD=redmine \
-e POSTGRES_DB=redmine \
-v ~/redmine-docker/${REDMINE_SYS_DATA_SQL}:/${REDMINE_SYS_DATA_SQL}:ro \
-v ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}:/${REDMINE_DEMO_DATA_SQL}:ro \
--restart=unless-stopped \
-d ${POSTGRES_IMAGE}

while [ -z "$(docker logs ${PG_REDMINE_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

# Create Redmine volume.
docker run \
--name ${REDMINE_VOLUME} \
--entrypoint="echo" \
${REDMINE_IMAGE_NAME} \
"Create Redmine volume."

# Start Redmine.
docker run \
--name=${REDMINE_NAME} \
--net ${CI_NETWORK} \
-e DB_ADAPTER=postgresql \
-e DB_HOST=${PG_REDMINE_NAME} \
-e DB_NAME=redmine \
-e DB_USER=redmine \
-e DB_PASS=redmine \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
-e NGINX_MAX_UPLOAD_SIZE=${NGINX_MAX_UPLOAD_SIZE} \
--volumes-from ${REDMINE_VOLUME} \
--volumes-from ${GERRIT_VOLUME}:ro \
--restart=unless-stopped \
-d ${REDMINE_IMAGE_NAME}
