# Google Location History to PostGIS

This is a little play-around project that converts Google Maps Location History
(de: "Standordverlauf") records available through [Google
Takeout](https://takeout.google.com/) into [PostGIS](https://postgis.net/)
compatible SQL files.

This is a proof-of-concept: It does not serve any bigger purpose other than to provide the ability to play around with the technologies involved. Feel free to get some inspiration here and there.

**Use Cases**:

* Visualize your entire Google Maps Location history through a GIS tool like
  [QGis](https://www.qgis.org/).
* Do statistics or number crunching directly through SQL or other number
  crunching tools like [Jupyter Notebooks](https://jupyter.org/).
* Learn some tools in this stack, from [jq](https://jqlang.github.io/jq/) to
  [docker](https://www.docker.com/).


This tool is somewhat of a successor to my many-years-old 
[google_takeout_fun](https://github.com/hendrikb/google_takeout_fun) project
that had very similar purposes but worked entirely on the
ElasticSearch+Logstash+Kibana ([ELK](https://www.elastic.co/elastic-stack)) stack which has since back than lost a bit
of traction, I would say.


# Getting started
## Prerequisite

### Get your Google Maps Timeline history files from Google Takeout

In your [Google Account activity settings
page](https://myaccount.google.com/activitycontrols/location) you have to have
*Location History* enabled.

**Disclaimer**: This will allow Google to track your physical location on your
mobile devices. They will store that data and present it to you through their
[Google Maps Timeline Page](https://www.google.com/maps/timeline)! **Do not use
this feature unless you are willing to share your 24/7 location data with that
Company or their partners. Read their official documentation, TOCs and privacy
statements!** Be aware, you are sacrificing good parts of your privacy. Don't
even think about enabling this feature on other people's accounts without their
explicit knowledge and consent! You have been warned. For none of the matters
described here the author of this document can be held liable.

We will download that data set in the next step in order to work with it.

### Technical requirements

For step `00` you will require development standard tools like `bash`, `jq`,
`bc` and `make` on your Linux machine. This has not been tested with Macs.

For step `01` you will need a working `docker` setup.

## 00 Get your Data from Google

Head over to [Google Takeout](https://takeout.google.com/settings/takeout) and
schedule your "Location History" Download in JSON format.

This will take a while, once it's done you will receive a notification. Download
the file, extract the archive somewhere. Then put the included large `.json`
file (named `Records.json`recently) into this project's working directory.

## 01 Turn your Records.json into PostGIS SQL

Run `make` to convert your huge JSON file from Google Takeout into a gzipped
SQL file that you can feed into PostgreSQL/PostGIS.

Then, you are basically done: `postgis.sql.gz` contains the crucial `CREATE
EXTENSION IF NOT EXISTS` and `CREATE TABLE IF NOT EXISTS` statements that will
get your PostGIS setup ready. The rest of that file contains INSERT statements
for each location record found in your Google Maps timeline.

## 02 If you don't know how to continue: local PostGIS with Docker

To play around quickly, I have provided `make db/start` which gets you an empty PostGIS database container named `psql` ready with its data folder mapped to your local directory `./pgdata`

After that: `make db/load` will load the recently created SQL file into the
`postgres` database of that otherwise rather unconfigured database system.

**Note**: If you execute `make db/load` multiple times, the data set gets
inserted repeatedly and you typically don't want that

## 03 Playing around on the local PostGIS

For your convenience, run `make db/console` to get a `psql` console on the
container. You can execute regular SQL statements and play around with the
dataset:

```sql
-- Show all activities and count how much of them are there
SELECT activity, COUNT(activity) FROM locations GROUP by activity;

-- How many coordinate log entries do we have in the table anyway
SELECT COUNT(*) FROM locations;

-- On what (and how many in total) days have I visited the Alexanderplatz area in Berlin?
SELECT date(timestamp) as day, count(timestamp) as visits
    FROM locations
    WHERE ST_DWithin(geog, 'POINT(13.409553 52.520861)', 100.0)
    GROUP BY day ORDER BY day;
```

 I recommend using more professional tools to visualize the data. [QGis](https://www.qgis.org/) can do that.

 Other useful tools might be listed here: [awesome-gis](https://github.com/sshuair/awesome-gis).



## 99 Clean up everything

If you worked with the database, feel encouraged to run `make db/stop` to stop
the database container and throw away the container (but **not** the mapped
database directory under `./pgdata`, it will stay there.)

Afterwards, `make distclean` will remove all intermediary files, **including**
that database folder `pgdata`.
