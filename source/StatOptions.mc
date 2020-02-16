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

using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Lang;
using Toybox.Math;
using Toybox.WatchUi;

module StatOptions {
    enum {
        OPTION_CALORIES,
        OPTION_KILOJOULES,
        OPTION_STEPS,
        OPTION_DISTANCE_METRES,
        OPTION_DISTANCE_FEET,
        OPTION_ACTIVITY_MIN_DAY, // 5
        OPTION_ACTIVITY_MIN_WEEK,
        OPTION_FLOORS_ASCENDED,
        OPTION_NOTHING,
        OPTION_HEART_RATE,
        OPTION_SUN_EVENT, // 10
        OPTION_PRESSURE,
        OPTION_TEMPERATURE_C,
        OPTION_TEMPERATURE_F,
        OPTION_ALTITUDE_METRES,
        OPTION_ALTITUDE_FEET, // 15
        OPTION_DISTANCE_KILOMETRES,
        OPTION_DISTANCE_MILES
    }

    const formatStrings = {
        OPTION_CALORIES => Rez.Strings.CaloriesFormat,
        OPTION_KILOJOULES => Rez.Strings.KilojoulesFormat,
        OPTION_STEPS => Rez.Strings.StepsFormat,
        OPTION_DISTANCE_METRES => Rez.Strings.MetresFormat,
        OPTION_DISTANCE_FEET => Rez.Strings.FeetFormat,
        OPTION_ACTIVITY_MIN_DAY => Rez.Strings.MinFormat,
        OPTION_ACTIVITY_MIN_WEEK => Rez.Strings.MinFormat,
        OPTION_FLOORS_ASCENDED => Rez.Strings.FloorsClimbedFormat,
        OPTION_HEART_RATE => Rez.Strings.HeartRateFormat,
        OPTION_SUN_EVENT => Rez.Strings.TimeFormat,
        OPTION_PRESSURE => Rez.Strings.PressureFormat,
        OPTION_TEMPERATURE_C => Rez.Strings.TemperatureCelsiusFormat,
        OPTION_TEMPERATURE_F => Rez.Strings.TemperatureFahrenheitFormat,
        OPTION_ALTITUDE_METRES => Rez.Strings.MetresFormat,
        OPTION_ALTITUDE_FEET => Rez.Strings.FeetFormat,
        OPTION_DISTANCE_KILOMETRES => Rez.Strings.KilometresFormat,
        OPTION_DISTANCE_MILES => Rez.Strings.MilesFormat
    };

    function requiresLocation(index) {
        return StatOptions.requiresSunData(index) ||
            ((index == OPTION_ALTITUDE_METRES || index == OPTION_ALTITUDE_FEET) && !hasSensorHistory(:getElevationHistory));
    }

    function requiresSunData(index) {
        return index == OPTION_SUN_EVENT;
    }

    function hasSensorHistory(type) {
        return (Toybox has :SensorHistory) && (Toybox.SensorHistory has type);
    }

    function getFirstValue(type) {
        var getHist = new Toybox.Lang.Method(Toybox.SensorHistory, type);
        var it = getHist.invoke({:period => 1});
        if(it != null) {
            var sample = it.next();
            if(sample != null) {
                return sample.data;
            }
        }
        return null;
    }

    function getFormatString(index) {
        // System.println("Entering getFormatString");
        var resource = formatStrings[index];
        if(resource == null) {
            // System.println("Exiting getFormatString without a result");
            return "";
        }
        return WatchUi.loadResource(resource);
    }

    function getStatString(index, formatString, geo, sunEvent, actInfo, actMonInfo, settings) {
        // System.println("Entering getStatString");
        if(formatString == null) {
            System.println("Did not receive a format string");
            return "";
        }
        var args = null;
        switch(index) {
            case OPTION_CALORIES:
                if(ActivityMonitor.Info has :calories) {
                    if(actMonInfo.calories != null) {
                        args = [actMonInfo.calories];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_KILOJOULES:
                if(ActivityMonitor.Info has :calories) {
                    if(actMonInfo.calories != null) {
                        args = [Math.floor(actMonInfo.calories * 4.184).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_STEPS:
                if(ActivityMonitor.Info has :steps) {
                    if(actMonInfo.steps != null) {
                        args = [actMonInfo.steps];
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_METRES:
                if(ActivityMonitor.Info has :distance) {
                    if(actMonInfo.distance != null) {
                        args = [Math.floor(actMonInfo.distance / 100).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_FEET:
                if(ActivityMonitor.Info has :distance) {
                    if(actMonInfo.distance != null) {
                        args = [Math.floor(actMonInfo.distance / 30.48).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_DAY:
                if(ActivityMonitor.Info has :activeMinutesDay) {
                    if(actMonInfo.activeMinutesDay != null) {
                        args = [actMonInfo.activeMinutesDay.total];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_WEEK:
                if(ActivityMonitor.Info has :activeMinutesWeek) {
                    if(actMonInfo.activeMinutesWeek != null) {
                        args = [actMonInfo.activeMinutesWeek.total];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_FLOORS_ASCENDED:
                if(ActivityMonitor.Info has :floorsClimbed) {
                    if(actMonInfo.floorsClimbed != null) {
                        args = [actMonInfo.floorsClimbed];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_NOTHING:
                return "";
            case OPTION_HEART_RATE:
                if(Activity.Info has :currentHeartRate) {
                    if(actInfo.currentHeartRate != null) {
                        args = [Math.floor(actInfo.currentHeartRate).format("%d")];
                    }
                } else if(hasSensorHistory(:getHeartRateHistory)) {
                    data = getFirstValue(:getHeartRateHistory);
                    if(data != null) {
                        args = [Math.floor(data).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_SUN_EVENT:
                if(sunEvent != null) {
                    if(settings.is24Hour) {
                        args = [sunEvent.eventTimeInfo.hour.format("%02d"), sunEvent.eventTimeInfo.min.format("%02d")];
                    } else {
                        var hour = sunEvent.eventTimeInfo.hour;
                        var period = "am";
                        if(hour >= 12) {
                            if(hour > 12) {
                                hour = hour - 12;
                            }
                            period = "pm";
                        }
                        args = [hour.format("%d"), sunEvent.eventTimeInfo.min.format("%02d") + period];
                    }
                }
                break;
            case OPTION_PRESSURE:
                if(hasSensorHistory(:getPressureHistory)) {
                    var data = getFirstValue(:getPressureHistory);
                    if(data != null) {
                        args = [(data / 100).format("%.1f")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_TEMPERATURE_C:
                if(hasSensorHistory(:getTemperatureHistory)) {
                    var data = getFirstValue(:getTemperatureHistory);
                    if(data != null) {
                        args = [data.format("%.1f")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_TEMPERATURE_F:
                if(hasSensorHistory(:getTemperatureHistory)) {
                    var data = getFirstValue(:getTemperatureHistory);
                    if(data != null) {
                        args = [((data * 1.8) + 32).format("%.1f")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ALTITUDE_METRES:
                if(hasSensorHistory(:getElevationHistory)) {
                    var data = getFirstValue(:getElevationHistory);
                    if(data != null) {
                        args = [data.format("%d")];
                    }
                } else if(GeoData.valid(geo) && geo.altitude != null) {
                    args = [geo.altitude.format("%d")];
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ALTITUDE_FEET:
                if(hasSensorHistory(:getElevationHistory)) {
                    var data = getFirstValue(:getElevationHistory);
                    if(data != null) {
                        args = [(data * 3.281).format("%d")];
                    }
                } else if(GeoData.valid(geo) && geo.altitude != null) {
                    args = [(geo.altitude * 3.281).format("%d")];
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_KILOMETRES:
                if(ActivityMonitor.Info has :distance) {
                    if(actMonInfo.distance != null) {
                        args = [(actMonInfo.distance / 100000.0).format("%.2f")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_MILES:
                if(ActivityMonitor.Info has :distance) {
                    if(actMonInfo.distance != null) {
                        args = [(actMonInfo.distance / 160934.4).format("%.2f")];
                    }
                } else {
                    return "N/S";
                }
                break;
        }
        if(args != null) {
            return Lang.format(formatString, args);
        }
        // System.println("Exiting getStatString without a result");
        return "N/D";
    }
}
