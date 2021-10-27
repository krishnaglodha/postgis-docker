#!/usr/bin/env bash

# wait for postgres to come up
until psql -l; do
	sleep 1
done
echo "postgres ready"

echo "setting up OSM databases"
psql               \
--set=gs_role="${GS_PG_USER}"        \
--set=gs_pass="${GS_PG_PASSWORD}"        \
--set=imposm_db="${IMPOSM_DBNAME}"   \
--set=imposm_schema="${IMPOSM_DBSCHEMA_PRODUCTION}" \
--set=osm_shapefiles_db="${PG_OSM_SHAPEFILES_DB}"   \
--set=osm_shapefiles_schema="${PG_OSM_SHAPEFILES_SCHEMA}" \
--set=gwc_quota_db="${PG_GS_QUOTA_DB}"                    \
-f /db/setup_osm.sql

echo "restoring OSM shapefiles DB"
gunzip < /db/osm_shapefiles.sql.gz | psql -U postgres -d ${PG_OSM_SHAPEFILES_DB}
echo "Deleting source files"
rm -Rf /db/*
echo "DONE"