from skyfield.api import load, wgs84
from skyfield.almanac import find_discrete, risings_and_settings
from datetime import datetime, timedelta
import pytz

def calculate_venus_positions(latitude, longitude, date_str, time_str):
    ts = load.timescale()
    eph = load('de421.bsp')
    venus = eph['venus']
    earth = eph['earth']

    # Convert input time to UTC
    local_tz = pytz.FixedOffset(int(longitude / 15 * 60))
    local_dt = local_tz.localize(datetime.strptime(f"{date_str} {time_str}", "%Y-%m-%d %H:%M:%S"))
    utc_dt = local_dt.astimezone(pytz.UTC)
    
    print(f"Local time: {local_dt}")
    print(f"UTC time: {utc_dt}")

    t = ts.from_datetime(utc_dt)

    # Set up observer location
    observer = earth + wgs84.latlon(latitude, longitude)

    # Calculate Venus position at the specified time
    astrometric = observer.at(t).observe(venus)
    subpoint = wgs84.subpoint_of(astrometric)
    
    print(f"Venus position at specified time:")
    print(f"Latitude: {subpoint.latitude.degrees:.2f}, Longitude: {subpoint.longitude.degrees:.2f}")

    # Calculate next Venus rising and setting times
    f = risings_and_settings(eph, venus, observer)
    t0 = t
    t1 = ts.from_datetime(utc_dt + timedelta(days=1))
    times, events = find_discrete(t0, t1, f)

    results = []
    for ti, event in zip(times, events):
        event_type = 'Rising' if event else 'Setting'
        astrometric = earth.at(ti).observe(venus)
        subpoint = wgs84.subpoint_of(astrometric)
        results.append({
            'event': event_type,
            'time': ti.utc_strftime('%Y-%m-%d %H:%M:%S'),
            'latitude': subpoint.latitude.degrees,
            'longitude': subpoint.longitude.degrees,
        })

    return results

if __name__ == "__main__":
    import sys
    latitude = float(sys.argv[1])
    longitude = float(sys.argv[2])
    date_str = sys.argv[3]
    time_str = sys.argv[4]
    results = calculate_venus_positions(latitude, longitude, date_str, time_str)
    for event in results:
        print(f"{event['event']}: {event['time']}, Lat: {event['latitude']:.2f}, Lon: {event['longitude']:.2f}")