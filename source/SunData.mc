/*
    This file is part of DigitalSimplicity.

    DigitalSimplicity is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    DigitalSimplicity is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with DigitalSimplicity.  If not, see <https://www.gnu.org/licenses/>.
*/

using Toybox.Lang;
using Toybox.Math;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Position;

class SunData {
    static const TWOPI = Math.PI * 2.0d;

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

    function toString() {
        return timeObtained.value() + ";"
            + locationObtained.position.toDegrees() + ";"
            + eventTime.value() + ";"
            + eventType;
    }

    // works with floating point numbers and preserves sign
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

    static function unixToJulian(unix) {
        return (unix.toDouble() / 86400.0d) + 2440587.5d;
    }

    static function julianToUnix(julian) {
        return (julian.toDouble() - 2440587.5d) * 86400.0d;
    }

    // All math is radians
    // Adapted from the formulas on Wikipedia: https://en.wikipedia.org/wiki/Sunrise_equation
    // moment is a Time.Moment object, that should represent the moment of midnight on the current day (or tomorrow if nextDay is true)
    // locationInfo is a Position.Info object
    // altitude is in metres
    static function calculateSunriseSunset(moment, locationInfo, nextDay, prevData) {
        // System.println(moment.value() + ";"
        //     + locationInfo.accuracy + ";" + locationInfo.position.toDegrees() + ";" + locationInfo.altitude + ";"
        //     + nextDay + ";"
        //     + prevData);
        var now = Time.now();
        // skip calculating sunrise/set data for the current day if:
        // - we already have previous sunset data AND
        // - the current time is after the time of that sunset AND
        // - we would be calculating the data for the same day (are we getting ourselves in trouble assuming every day is 86400 seconds?)
        if(prevData != null && prevData.eventType == SunData.SUNSET && now.compare(prevData.eventTime) > 0 && now.compare(moment) < 86400) {
            return calculateSunriseSunset(moment.add(new Time.Duration(Gregorian.SECONDS_PER_DAY)), locationInfo, true, null);
        }
        // System.println("Updating sunevent data");
        var latlon = locationInfo.position.toRadians();
        var lat = latlon[0];
        var lon = latlon[1];
        var altitude = 0;
        if(Position.Info has :altitude && locationInfo.altitude != null && locationInfo.altitude > 0) {
            altitude = locationInfo.altitude;
        }
        // DAYS
        var n = Math.round(unixToJulian(moment.value()) + 0.5) - 2451545.0d + 0.0008d;
        // JULIAN DAYS
        var Jstar = n - (lon / TWOPI);
        // 357.5291 degrees = 6.24006 radians
        // 0.98560028 degrees = 0.01720197 radians
        // ANGULAR DISTANCE
        var M = mod((6.24006d + (0.01720197 * Jstar)), TWOPI);
        var sinM = Math.sin(M);
        // 1.9148 degrees = 0.03342 radians
        // 0.02 degrees = 0.000349 radians
        // 0.0003 degrees = 0.00000524 radians
        // ANGULAR DIFFERENCE
        var C = (0.03342d * sinM) + (0.000349d * Math.sin(2 * M)) + (0.00000524 * Math.sin(3 * M));
        // 180 degrees = PI radians
        // 102.9372 degrees = 1.79659 radians
        // ANGULAR DISTANCE
        var lambda = mod((M + C + Math.PI + 1.79659d), TWOPI);
        // JULIAN DAYS
        var Jtransit = 2451545.0d + Jstar + (0.0053d * sinM) - (0.0069d * Math.sin(2 * lambda));
        // 23.44 degrees = 0.40911 radians
        // sin(0.40911) = 0.397793
        // ANGULAR DISTANCE
        var delta = Math.asin(Math.sin(lambda) * 0.397793d);
        // ANGULAR DISTANCE
        var omega = Math.acos((Math.sin(Math.toRadians(-0.83d + ((-2.076 * Math.sqrt(altitude)) / 60))) - (Math.sin(lat) * Math.sin(delta))) / (Math.cos(lat) * Math.cos(delta)));
        var sunrise = new Time.Moment(julianToUnix(Jtransit - (omega / TWOPI)));
        var sunset = new Time.Moment(julianToUnix(Jtransit + (omega / TWOPI)));
        // System.println("Now: " + now.value() + ", Sunrise: " + sunrise.value() + ", Sunset: " + sunset.value());
        // if we're calculating tomorrow's sunrise or we are before today's sunrise, show ETA of sunrise
        if(nextDay || now.compare(sunrise) < 0) {
            return new SunData(now, locationInfo, sunrise, SunData.SUNRISE);
        }
        // if we're already past sunset, show the time of sunrise tomorrow
        if(now.compare(sunset) > 0) {
            return calculateSunriseSunset(moment.add(new Time.Duration(Gregorian.SECONDS_PER_DAY)), locationInfo, true, null);
        }
        // otherwise, return sunset time
        return new SunData(now, locationInfo, sunset, SunData.SUNSET);
    }
}
