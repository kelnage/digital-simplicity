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
        OPTION_ACTIVITY_MIN_DAY,
        OPTION_ACTIVITY_MIN_WEEK,
        OPTION_FLOORS_ASCENDED,
        OPTION_NOTHING,
        OPTION_HEART_RATE,
        OPTION_SUN_EVENT, // 10
        OPTION_PRESSURE,
        OPTION_TEMPERATURE_C,
        OPTION_TEMPERATURE_F,
        OPTION_ALTITUDE_METRES,
        OPTION_ALTITUDE_FEET
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
        }
        // System.println("Exiting getFormatString without a result");
        return "";
    }

    static function getStatString(index, formatString, sunEvent, activity, settings) {
        // System.println("Entering getStatString");
        if(formatString == null) {
            System.println("Did not receive a format string");
            return "";
        }
        switch(index) {
            case OPTION_CALORIES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        return Lang.format(formatString,
                            [activity.calories]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_KILOJOULES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.calories * 4.184).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_STEPS:
                if(ActivityMonitor.Info has :steps) {
                    if(activity.steps != null) {
                        return Lang.format(formatString,
                            [activity.steps]);
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_METRES:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.distance / 100).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_DISTANCE_FEET:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.distance / 30.48).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_DAY:
                if(ActivityMonitor.Info has :activeMinutesDay) {
                    if(activity.activeMinutesDay != null) {
                        return Lang.format(formatString,
                            [activity.activeMinutesDay.total]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_ACTIVITY_MIN_WEEK:
                if(ActivityMonitor.Info has :activeMinutesWeek) {
                    if(activity.activeMinutesWeek != null) {
                        return Lang.format(formatString,
                            [activity.activeMinutesWeek.total]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_FLOORS_ASCENDED:
                if(ActivityMonitor.Info has :floorsClimbed) {
                    if(activity.floorsClimbed != null) {
                        return Lang.format(formatString,
                            [activity.floorsClimbed]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_NOTHING:
                break;
            case OPTION_HEART_RATE:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getHeartRateHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(formatString,
                                [Math.floor(sample.data).format("%d")]);
                        }
                    }
                } else {
                    return "N/S";
                }
                break;
            case OPTION_SUN_EVENT:
                if(sunEvent != null) {
                    if(settings.is24Hour) {
                        return Lang.format(formatString,
                            [
                                sunEvent.eventTimeInfo.hour.format("%02d"),
                                sunEvent.eventTimeInfo.min.format("%02d")
                            ]);
                    } else {
                        var hour = sunEvent.eventTimeInfo.hour;
                        var period = "am";
                        if(hour >= 12) {
                            if(hour > 12) {
                                hour = hour - 12;
                            }
                            period = "pm";
                        }
                        return Lang.format(formatString,
                            [
                                hour.format("%d"),
                                sunEvent.eventTimeInfo.min.format("%02d") + period
                            ]);
                    }
                }
                break;
            case OPTION_PRESSURE:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getPressureHistory({:period => 1});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(formatString,
                                [(sample.data / 100).format("%.1f")]);
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
                            return Lang.format(formatString,
                                [sample.data.format("%.1f")]);
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
                            return Lang.format(formatString,
                                [((sample.data * 1.8) + 32).format("%.1f")]);
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
                            return Lang.format(formatString,
                                [sample.data.format("%d")]);
                        }
                    }
                } else if(Position.Info has :altitude && locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    return Lang.format(formatString,
                        [locationInfo.altitude.format("%d")]);
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
                            return Lang.format(formatString,
                                [(sample.data * 3.281).format("%d")]);
                        }
                    }
                } else if(Position.Info has :altitude && locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    return Lang.format(formatString,
                        [(locationInfo.altitude * 3.281).format("%d")]);
                } else {
                    return "N/S";
                }
                break;
        }
        // System.println("Exiting getStatString without a result");
        return "";
    }
}
