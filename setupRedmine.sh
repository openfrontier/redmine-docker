#!/bin/bash
set -e

REDMINE_SYS_DATA_SQL=redmine-init-system.sql

docker exec pg-redmine gosu postgres psql -d redmine -U redmine -f /${REDMINE_SYS_DATA_SQL}
