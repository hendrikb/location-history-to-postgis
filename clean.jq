def escape(s): if s then "'\(s | ascii_downcase)'" else null end;

0 as $newer_than_ts |

# "INSERT INTO locations(accuracy, altitude, velocity, source, activity, geog, timestamp)"

.locations[] |
select ( .latitudeE7 and .longitudeE7) |
{
  accuracy: .accuracy?,
  altitude: .altitude?,
  velocity: .velocity?,
  source: .source?,
  activity: .activity[0].activity[0].type?,
  lat: (.latitudeE7/pow(10;7)?),
  lon: (.longitudeE7/pow(10;7)?),
  timestamp: .timestamp? | sub("(?<time>.*)\\..*Z"; "\(.time)Z")
}
| select ( .timestamp | fromdateiso8601 > $newer_than_ts)
| "(\(.accuracy),\(.altitude),\(.velocity),\(escape(.source)),\(escape(.activity)),ST_GeomFromText('POINT(\(.lon) \(.lat))', 4326),'\(.timestamp)'),"

