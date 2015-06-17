#!/bin/bash
set -e

PG_REDMINE_NAME=${PG_REDMINE_NAME:-pg-redmine}
REDMINE_NAME=${REDMINE_NAME:-redmine}
REDMINE_IMAGE_NAME=${REDMINE_IMAGE_NAME:-sameersbn/redmine}
REDMINE_VOLUME=${REDMINE_VOLUME:-redmine-volume}
GERRIT_NAME=${GERRIT_NAME:-gerrit}

REDMINE_DB=${REDMINE_DB:-redmine}
REDMINE_DB_USER=${REDMINE_DB_USER:-redmine}
REDMINE_DB_PASS=${REDMINE_DB_PASS:-redmine}

REDMINE_SYS_DATA_SQL=redmine-init-system.sql
REDMINE_DEMO_DATA_SQL=redmine-init-demo.sql
INIT_DATE=`date +%Y-%m-%d\ %H:%M:%S.%N|cut -c 1-26`

# Redmine init data
sed -e "s/{INIT_DATE}/${INIT_DATE}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}.template > ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -i "s/{HOST_IP}/${LDAP_SERVER}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -i "s/{LDAP_ACCOUNTBASE}/${LDAP_ACCOUNTBASE}/g" ~/redmine-docker/${REDMINE_SYS_DATA_SQL}
sed -e "s/{INIT_DATE}/${INIT_DATE}/g" ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}.template > ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}

# Start PostgreSQL.
docker run \
--name ${PG_REDMINE_NAME} \
-p 5432:5432 \
-e POSTGRES_DB=${REDMINE_DB} \
-e POSTGRES_USER=${REDMINE_DB_USER} \
-e POSTGRES_PASSWORD=${REDMINE_DB_PASS} \
-v ~/redmine-docker/${REDMINE_SYS_DATA_SQL}:/${REDMINE_SYS_DATA_SQL}:ro \
-v ~/redmine-docker/${REDMINE_DEMO_DATA_SQL}:/${REDMINE_DEMO_DATA_SQL}:ro \
-d postgres

while [ -z "$(docker logs ${PG_REDMINE_NAME} 2>&1 | grep 'autovacuum launcher started')" ]; do
    echo "Waiting postgres ready."
    sleep 1
done

# Create Redmine volume.
docker run \
--name ${REDMINE_VOLUME} \
--volumes-from ${GERRIT_NAME} \
--entrypoint="echo" \
${REDMINE_IMAGE_NAME} \
"Create Redmine volume."

# Start Redmine.
docker run \
--name=${REDMINE_NAME} \
-p 80:80 \
-e DB_TYPE=postgres \
-e DB_HOST=$(docker inspect -f '{{.Node.IP}}' ${PG_REDMINE_NAME}) \
-e DB_NAME=${REDMINE_DB} \
-e DB_USER=${REDMINE_DB_USER} \
-e DB_PASS=${REDMINE_DB_PASS} \
-e REDMINE_RELATIVE_URL_ROOT=/redmine \
-e REDMINE_FETCH_COMMITS=hourly \
--volumes-from ${REDMINE_VOLUME} \
-d ${REDMINE_IMAGE_NAME}
