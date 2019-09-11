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

using Toybox.ActivityMonitor;
using Toybox.Lang;
using Toybox.Math;
using Toybox.WatchUi;

class StatOptions {
    static enum {
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

    static function requiresLocation(index) {
        return StatOptions.requiresSunData(index) ||
            ((index == OPTION_ALTITUDE_METRES || index == OPTION_ALTITUDE_FEET) && !(Toybox has :SensorHistory && Toybox.SensorHistory has :getElevationHistory));
    }

    static function requiresSunData(index) {
        return index == OPTION_SUN_EVENT;
    }

    static function getFormatString(index) {
        // System.println("Entering getFormatString");
        switch(index) {
            case OPTION_CALORIES:
                return WatchUi.loadResource(Rez.Strings.CaloriesFormat);
            case OPTION_KILOJOULES:
                return WatchUi.loadResource(Rez.Strings.KilojoulesFormat);
            case OPTION_STEPS:
                return WatchUi.loadResource(Rez.Strings.StepsFormat);
            case OPTION_DISTANCE_METRES:
                return WatchUi.loadResource(Rez.Strings.MetresFormat);
            case OPTION_DISTANCE_FEET:
                return WatchUi.loadResource(Rez.Strings.FeetFormat);
            case OPTION_ACTIVITY_MIN_DAY:
                return WatchUi.loadResource(Rez.Strings.MinFormat);
            case OPTION_ACTIVITY_MIN_WEEK:
                return WatchUi.loadResource(Rez.Strings.MinFormat);
            case OPTION_FLOORS_ASCENDED:
                return WatchUi.loadResource(Rez.Strings.FloorsClimbedFormat);
            case OPTION_NOTHING:
                break;
            case OPTION_HEART_RATE:
                return WatchUi.loadResource(Rez.Strings.HeartRateFormat);
            case OPTION_SUN_EVENT:
                return WatchUi.loadResource(Rez.Strings.TimeFormat);
            case OPTION_PRESSURE:
                return WatchUi.loadResource(Rez.Strings.PressureFormat);
            case OPTION_TEMPERATURE_C:
                return WatchUi.loadResource(Rez.Strings.TemperatureCelsiusFormat);
            case OPTION_TEMPERATURE_F:
                return WatchUi.loadResource(Rez.Strings.TemperatureFahrenheitFormat);
            case OPTION_ALTITUDE_METRES:
                return WatchUi.loadResource(Rez.Strings.MetresFormat);
            case OPTION_ALTITUDE_FEET:
                return WatchUi.loadResource(Rez.Strings.FeetFormat);
            case OPTION_DISTANCE_KILOMETRES:
                return WatchUi.loadResource(Rez.Strings.KilometresFormat);
            case OPTION_DISTANCE_MILES:
                return WatchUi.loadResource(Rez.Strings.MilesFormat);
        }
        // System.println("Exiting getFormatString without a result");
        return "";
    }

    static function getStatString(index, formatString, geo, sunEvent, activity, settings) {
        // System.println("Entering getStatString");
        if(formatString == null) {
            System.println("Did not receive a format string");
            return "";
        }
        var args = null;
        switch(index) {
            case OPTION_CALORIES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        args = [activity.calories];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_KILOJOULES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        args = [Math.floor(activity.calories * 4.184).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_STEPS:
                if(ActivityMonitor.Info has :steps) {
                    if(activity.steps != null) {
                        args = [activity.steps];
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_METRES:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        args = [Math.floor(activity.distance / 100).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_FEET:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        args = [Math.floor(activity.distance / 30.48).format("%d")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_DAY:
                if(ActivityMonitor.Info has :activeMinutesDay) {
                    if(activity.activeMinutesDay != null) {
                        args = [activity.activeMinutesDay.total];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_WEEK:
                if(ActivityMonitor.Info has :activeMinutesWeek) {
                    if(activity.activeMinutesWeek != null) {
                        args = [activity.activeMinutesWeek.total];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_FLOORS_ASCENDED:
                if(ActivityMonitor.Info has :floorsClimbed) {
                    if(activity.floorsClimbed != null) {
                        args = [activity.floorsClimbed];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_NOTHING:
                return "";
            case OPTION_HEART_RATE:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getHeartRateHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [Math.floor(sample.data).format("%d")];
                        }
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
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getPressureHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [(sample.data / 100).format("%.1f")];
                        }
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_TEMPERATURE_C:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getTemperatureHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [sample.data.format("%.1f")];
                        }
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_TEMPERATURE_F:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getTemperatureHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [((sample.data * 1.8) + 32).format("%.1f")];
                        }
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ALTITUDE_METRES:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [sample.data.format("%d")];
                        }
                    }
                } else if(GeoData.valid(geo) && geo.altitude != null) {
                    args = [geo.altitude.format("%d")];
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ALTITUDE_FEET:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getElevationHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            args = [(sample.data * 3.281).format("%d")];
                        }
                    }
                } else if(GeoData.valid(geo) && geo.altitude != null) {
                    args = [geo.altitude.format("%d")];
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_KILOMETRES:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        args = [(activity.distance / 100000.0).format("%.2f")];
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_MILES:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        args = [(activity.distance / 160934.4).format("%.2f")];
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
