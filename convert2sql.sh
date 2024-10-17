#!/bin/bash
set -e -u -o pipefail

TARGET_SQL="inserts.sql"
CLEAN_JQ="clean.jq"
RECORDS_JSON=$1


echo 'CREATE TABLE statement'
cat << EOF > $TARGET_SQL
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE TABLE IF NOT EXISTS locations (
	id serial PRIMARY KEY,
	accuracy integer DEFAULT NULL,
	altitude smallint DEFAULT NULL,
	velocity smallint DEFAULT NULL,
	source VARCHAR(12) DEFAULT NULL,
	activity VARCHAR(15) DEFAULT NULL,
	geog GEOGRAPHY(Point) NOT NULL,
	timestamp timestamp with time zone,
	created_timestamp timestamp NOT NULL DEFAULT current_timestamp
);
CREATE INDEX IF NOT EXISTS locations_geog ON locations USING GIST (geog);
EOF

echo "INSERT INTO locations(accuracy, altitude, velocity, source, activity, geog, timestamp) VALUES" >> $TARGET_SQL

jq -r -f $CLEAN_JQ $RECORDS_JSON >> $TARGET_SQL
sed -i '$ s/,$/;/g' $TARGET_SQL
