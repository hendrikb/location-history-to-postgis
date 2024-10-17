.PHONY: all clean distclean db/start db/load db/console db/stop convert2sql split

all: convert2sql split
	@echo "[$@] postgis.sql.gz contains the SQL you are looking for. Have fun!"
	@echo "[$@] If you need a database now, run 'make db/start' now"

convert2sql:
	@echo "[$@] Converting Records.json to INSERT statement"
	./convert2sql.sh Records.json
	@echo "[$@] Done"

split:
	@echo "[$@] Splitting one big INSERT into multiple insert statements"
	./split.sh inserts.sql
	@echo "[$@] Done"

db/start:
	@echo "[$@] Launching local playground database via docker"
	mkdir -p $(PWD)/pgdata
	docker run -d -e'POSTGRES_PASSWORD=password' -e'POSTGRES_HOST_AUTH_METHOD=trust' --name "psql" --rm -v $(PWD)/pgdata:/home/postgres/pgdata -v$(PWD)/postgis.sql.gz:/tmp/postgis.sql.gz  -p5432:5432  timescale/timescaledb-ha:pg16.3-ts2.15.1-all
	@echo "[$@] Done. PostgreSQL database available through localhost:5432"
	@echo "[$@] If you want to insert the postgis.sql.gz into that database, run 'make db/load' now."


db/load:
	@echo "[$@] Inserting SQL dump into docker playground database"
	docker exec psql 'rm' '-f' '/tmp/input.sql'
	docker exec psql 'cp' '-f' '/tmp/postgis.sql.gz' '/tmp/input.sql.gz'
	docker exec psql 'gunzip' '-f' '/tmp/input.sql.gz'
	docker exec psql 'psql' '-f' '/tmp/input.sql'
	@echo "[$@] Done. You can connect to localhost:5432 (user & database name: postgres) now and play around with the data in the 'locations' table"

db/console:
	docker exec -ti psql psql
db/stop:
	docker stop psql

clean:
	rm -rf *.sql*

distclean: db/stop clean
	rm -rf pgdata/
