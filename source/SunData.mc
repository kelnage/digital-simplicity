using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;

class SunData {
    enum {
        SUNRISE, SUNSET
    }

    var timeObtained;
    var locationObtained;
    var eventTime;
    var eventTimeInfo;
    var eventType;

    function initialize(otime, oloc, etime, etype) {
        timeObtained = otime;
        locationObtained = oloc;
        eventTime = etime;
        eventTimeInfo = Gregorian.info(eventTime, Time.FORMAT_MEDIUM);
        eventType = etype;
    }

    // math functions

    // Preserves sign
    static function mod(a, n) {
        var v = a;
        if(a < 0) {
            v = -1 * v;
        }
        while(v >= n) {
            v = v - n;
        }
        if(a < 0) {
            v = -1 * v;
        }
        return v;
    }

    static function sin(x) {
        return Math.sin(Math.toRadians(x));
    }

    static function cos(x) {
        return Math.cos(Math.toRadians(x));
    }

    static function asin(x) {
        return Math.toDegrees(Math.asin(x));
    }

    static function acos(x) {
        return Math.toDegrees(Math.acos(x));
    }

    static function unixToJulian(unix) {
        return (unix.toDouble() / 86400.0d) + 2440587.5d;
    }

    static function julianToUnix(julian) {
        return (julian.toDouble() - 2440587.5d) * 86400.0d;
    }

    // All math is degrees, conversion between it and radians is handled by above trig functions
    // moment is a Time.Moment object, that should represent the moment of midnight on the current day (or tomorrow if nextDay is true)
    // locationInfo is a Position.Info object
    // altitude is in metres
    static function calculateSunriseSunset(moment, locationInfo, nextDay) {
        System.println("Updating sunevent data");
        var latlon = locationInfo.position.toDegrees();
        var latitude = latlon[0];
        var longitude = latlon[1];
        var altitude = 0;
        if(locationInfo has :altitude && locationInfo.altitude != null && locationInfo.altitude > 0) {
            altitude = locationInfo.altitude;
        }
        // var julianDate = unixToJulian(moment.value());
        // System.println(Lang.format("Moment: $1$, Julian: $2$, Unix: $3$", [moment.value(), julianDate, julianToUnix(julianDate)]));
        // System.println(Lang.format("Lat: $1$, Lon: $2$, Alt: $3$", [latitude, longitude, altitude]));
        // var TWOPI = Math.PI * 2;
        var n = Math.round(unixToJulian(moment.value()) + 0.5) - 2451545.0d + 0.0008d;
        // System.println("n = " + n);
        var Jstar = n - (longitude / 360.0d);
        // System.println("Jstar = " + Jstar);
        // 357.5291 degrees = 6.2400599667 rads
        var M = mod((357.5291d + (0.98560028d * Jstar)), 360.0);
        // System.println("M = " + M);
        var sinM = sin(M);
        var C = (1.9148d * sinM) + (0.02d * sin(2 * M)) + (0.0003d * sin(3 * M));
        // System.println("C = " + C);
        // 180 degrees = PI rads
        // 102.9372 degrees = 1.7965930628 rads
        var l = mod((M + C + 180.0d + 102.9372d), 360.0);
        // System.println("l = " + l);
        var Jtransit = 2451545.0d + Jstar + (0.0053d * sinM) - (0.0069d * sin(2 * l));
        // System.println("Jtransit = " + Jtransit);
        // 23.44 degrees = 0.40910518 rads
        var delta = asin(sin(l) * sin(23.44d));
        // System.println("delta = " + delta);
        // -0.83 degrees = -0.01448623 rads
        // Altitude correction: Math.toRadians()
        var altCorrection = -2.076 * (Math.sqrt(altitude) / 60);
        var omega = acos((sin(-0.83d + altCorrection) - (sin(latitude) * sin(delta))) / (cos(latitude) * cos(delta)));
        // System.println("omega = " + omega);
        // var dstAdjust = new Time.Duration(System.getClockTime().timeZoneOffset);
        var now = Time.now();
        var sunrise = new Time.Moment(julianToUnix(Jtransit - (omega / 360.0d)));
        var sunset = new Time.Moment(julianToUnix(Jtransit + (omega / 360.0d)));
        // System.println("Now: " + now.value() + ", Sunrise: " + sunrise.value() + ", Sunset: " + sunset.value());
        // if we're calculating tomorrow's sunrise or we are before today's sunrise, show ETA of sunrise
        if(nextDay || now.compare(sunrise) < 0) {
            // var sunriseString = Lang.format("$1$:$2$", [sunriseInfo.hour.format("%02d"), sunriseInfo.min.format("%02d")]);
            // System.println("Sunrise: " + sunriseString);
            return new SunData(now, locationInfo, sunrise, SunData.SUNRISE);
            // return [now, sunriseInfo, locationInfo, SUNRISE];
        }
        // if we're already past sunset, show the time of sunrise tomorrow
        if(now.compare(sunset) > 0) {
            return calculateSunriseSunset(moment.add(new Time.Duration(Gregorian.SECONDS_PER_DAY)), locationInfo, true);
        }
        // otherwise, return sunset time
        // var sunriseString = Lang.format("$1$:$2$", [sunsetInfo.hour.format("%02d"), sunsetInfo.min.format("%02d")]);
        // System.println("Sunset: " + sunriseString);
        // return [now, sunsetInfo, SUNSET];
        return new SunData(now, locationInfo, sunset, SunData.SUNSET);
    }
}
