#!/bin/bash
set -e
REDMINE_CONF1=redmine-init-system.sql

docker exec openldap ldapadd -f /${REDMINE_CONF1} -x -D "cn=admin,${SLAPD_DN}" -w ${SLAPD_PASSWORD}
