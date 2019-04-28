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

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;
using Toybox.ActivityMonitor;
using Toybox.Position;

// global state
var partialUpdates = false;

class DigitalSimplicityView extends WatchUi.WatchFace {
    enum {
        THEME_CLASSIC_GRAY,
        THEME_CLASSIC_WHITE,
        THEME_DARK_GRAY,
        THEME_DARK_WHITE,
        THEME_INVERSE_GRAY,
        THEME_INVERSE_WHITE
    }

    enum {
        BAR_OPTION_CALORIES,
        BAR_OPTION_KILOJOULES,
        BAR_OPTION_STEPS,
        BAR_OPTION_DISTANCE_METRES,
        BAR_OPTION_DISTANCE_FEET,
        BAR_OPTION_ACTIVITY_MIN_DAY,
        BAR_OPTION_ACTIVITY_MIN_WEEK,
        BAR_OPTION_FLOORS_ASCENDED,
        BAR_OPTION_NOTHING,
        BAR_OPTION_HEART_RATE,
        BAR_OPTION_SUN_EVENT, // 10
        BAR_OPTION_PRESSURE,
        BAR_OPTION_TEMPERATURE_C,
        BAR_OPTION_TEMPERATURE_F,
        BAR_OPTION_ALTITUDE_METRES,
        BAR_OPTION_ALTITUDE_FEET
    }

    // state
    var locationInfo = null;
    var sunEvent = null;

    // bitmaps
    var bluetoothIcon;
    var batteryIcon;

    // layout constants
    const batteryX = 178;
    const batteryY = 59;
    const bluetoothX = 38;
    const bluetoothY = 57;
    const colonX = 130;
    const colonY = 123;

    // layout variables
    var fgColour = Graphics.COLOR_BLACK;
    var bgColour = Graphics.COLOR_LT_GRAY;
    var moveColour = Graphics.COLOR_DK_RED;
    var topFormat;
    var bottomFormat;

    function initialize() {
        WatchFace.initialize();
        partialUpdates = (Toybox.WatchUi.WatchFace has :onPartialUpdate);
    }

    function loadConfig() {
        var app = Application.getApp();
        topFormat = getFormatString(app.getProperty("TopBarStat"));
        bottomFormat = getFormatString(app.getProperty("BottomBarStat"));
        moveColour = Graphics.COLOR_DK_RED;
        var colourTheme = app.getProperty("ColourTheme");
        switch(colourTheme) {
            case THEME_CLASSIC_GRAY:
            case THEME_CLASSIC_WHITE:
                fgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_CLASSIC_GRAY) {
                    bgColour = Graphics.COLOR_LT_GRAY;
                } else {
                    bgColour = Graphics.COLOR_WHITE;
                }
                batteryIcon = new WatchUi.Bitmap({
                    :rezId=>Rez.Drawables.BatteryIconBlack,
                    :locX=>batteryX,
                    :locY=>batteryY
                });
                bluetoothIcon = new WatchUi.Bitmap({
                    :rezId=>Rez.Drawables.BluetoothIconBlack,
                    :locX=>bluetoothX,
                    :locY=>bluetoothY
                });
                View.findDrawableById("TopLabel").setColor(bgColour);
                View.findDrawableById("BottomLabel").setColor(bgColour);
                break;
            case THEME_DARK_GRAY:
            case THEME_DARK_WHITE:
                bgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_DARK_GRAY) {
                    fgColour = Graphics.COLOR_LT_GRAY;
                    batteryIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BatteryIconGray,
                        :locX=>batteryX,
                        :locY=>batteryY
                    });
                    bluetoothIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BluetoothIconGray,
                        :locX=>bluetoothX,
                        :locY=>bluetoothY
                    });
                } else {
                    fgColour = Graphics.COLOR_WHITE;
                    batteryIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BatteryIconWhite,
                        :locX=>batteryX,
                        :locY=>batteryY
                    });
                    bluetoothIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BluetoothIconWhite,
                        :locX=>bluetoothX,
                        :locY=>bluetoothY
                    });
                }
                View.findDrawableById("TopLabel").setColor(fgColour);
                View.findDrawableById("BottomLabel").setColor(fgColour);
                break;
            case THEME_INVERSE_GRAY:
            case THEME_INVERSE_WHITE:
                bgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_INVERSE_GRAY) {
                    fgColour = Graphics.COLOR_LT_GRAY;
                    batteryIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BatteryIconGray,
                        :locX=>batteryX,
                        :locY=>batteryY
                    });
                    bluetoothIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BluetoothIconGray,
                        :locX=>bluetoothX,
                        :locY=>bluetoothY
                    });
                } else {
                    fgColour = Graphics.COLOR_WHITE;
                    batteryIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BatteryIconWhite,
                        :locX=>batteryX,
                        :locY=>batteryY
                    });
                    bluetoothIcon = new WatchUi.Bitmap({
                        :rezId=>Rez.Drawables.BluetoothIconWhite,
                        :locX=>bluetoothX,
                        :locY=>bluetoothY
                    });
                }
                View.findDrawableById("TopLabel").setColor(bgColour);
                View.findDrawableById("BottomLabel").setColor(bgColour);
                break;
        }
        var dateView = View.findDrawableById("DateLabel");
        var notificationView = View.findDrawableById("NotificationCountLabel");
        var batteryView = View.findDrawableById("BatteryLabel");
        var hoursView = View.findDrawableById("HoursLabel");
        var minutesView = View.findDrawableById("MinutesLabel");
        var periodView = View.findDrawableById("PeriodLabel");
        dateView.setColor(fgColour);
        notificationView.setColor(fgColour);
        batteryView.setColor(fgColour);
        hoursView.setColor(fgColour);
        minutesView.setColor(fgColour);
        periodView.setColor(fgColour);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadConfig();
    }

    function onUpdate(dc) {
        dc.clearClip();
        dc.setColor(fgColour, bgColour);

        // Get data
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var settings = System.getDeviceSettings();
        var stats = System.getSystemStats();
        var activity = ActivityMonitor.getInfo();
        var app = Application.getApp();

        // System.println(settings.connectionInfo);

        // Formatting
        var timeFormat = "$1$:$2$";
        var dateFormat = "$1$ $2$";

        // Format date and time appropriately
        var dateString = Lang.format(dateFormat, [now.day_of_week, now.day]);

        // Format notification count
        var nc = settings.notificationCount;
        var ncs = "";
        if(nc == 0) {
            ncs = "";
        } else {
            ncs = nc.format("%d");
        }

        // Format battery percentage
        var batteryString = Math.round(stats.battery).format("%d") + "%";

        // Load appropriate stats
        var topStatString = getStatString(app.getProperty("TopBarStat"), topFormat, activity);
        var bottomStatString = getStatString(app.getProperty("BottomBarStat"), bottomFormat, activity);

        // Update the views
        var dateView = View.findDrawableById("DateLabel");
        var notificationView = View.findDrawableById("NotificationCountLabel");
        var batteryView = View.findDrawableById("BatteryLabel");
        var topView = View.findDrawableById("TopLabel");
        var bottomView = View.findDrawableById("BottomLabel");

        dateView.setText(dateString.toLower());
        notificationView.setText(ncs);
        batteryView.setText(batteryString);
        topView.setText(topStatString);
        bottomView.setText(bottomStatString);
        drawTime(dc, settings, app, now);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        batteryIcon.draw(dc);
        drawBatteryStatus(dc, stats.battery);
        if(app.getProperty("DisplayMoveBar")) {
            drawMoveBar(dc, activity.moveBarLevel);
        }
        if(settings.phoneConnected) {
            bluetoothIcon.draw(dc);
        }
        onPartialUpdate(dc);
    }

    function onPartialUpdate(dc) {
        var now = System.getClockTime();
        var app = Application.getApp();
        dc.setClip(colonX, colonY, 8, 60);
        drawColon(dc, app.getProperty("BlinkingColon"), now.sec);
    }

    function drawTime(dc, settings, app, now) {
        var period = "";
        var hours = now.hour;
        var minutes = now.min.format("%02d");
        if (!settings.is24Hour) {
            if(hours < 12) {
                period = "am";
            } else {
                period = "pm";
            }
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (app.getProperty("UseMilitaryFormat")) {
                hours = hours.format("%02d");
            }
        }
        var hoursView = View.findDrawableById("HoursLabel");
        var minutesView = View.findDrawableById("MinutesLabel");
        var periodView = View.findDrawableById("PeriodLabel");
        hoursView.setText(hours + "");
        minutesView.setText(minutes);
        periodView.setText(period);
    }

    function drawColon(dc, blinking, seconds) {
        if(!blinking || !partialUpdates || seconds % 2 == 0) {
            dc.setColor(fgColour, bgColour);
            dc.fillRectangle(colonX, colonY + 17, 8, 8);
            dc.fillRectangle(colonX, colonY + 35, 8, 8);
        } else {
            dc.setColor(bgColour, bgColour);
            dc.fillRectangle(colonX, colonY, 8, 60);
            dc.setColor(fgColour, bgColour);
        }
    }

    function drawBatteryStatus(dc, battery) {
        dc.setColor(fgColour, bgColour);
        dc.fillRectangle(batteryX + 4, batteryY + 4, Math.floor(22 * (battery / 100)), 10);
    }

    function drawMoveBar(dc, moveNumber) {
        dc.setColor(moveColour, bgColour);
        dc.fillRectangle(33, 194, moveNumber * 35, 3);
    }

    function getFormatString(index) {
        // System.println("Entering getFormatString");
        switch(index) {
            case BAR_OPTION_CALORIES:
                return WatchUi.loadResource(Rez.Strings.CaloriesFormat);
            case BAR_OPTION_KILOJOULES:
                return WatchUi.loadResource(Rez.Strings.KilojoulesFormat);
            case BAR_OPTION_STEPS:
                return WatchUi.loadResource(Rez.Strings.StepsFormat);
            case BAR_OPTION_DISTANCE_METRES:
                return WatchUi.loadResource(Rez.Strings.MetresFormat);
            case BAR_OPTION_DISTANCE_FEET:
                return WatchUi.loadResource(Rez.Strings.FeetFormat);
            case BAR_OPTION_ACTIVITY_MIN_DAY:
                return WatchUi.loadResource(Rez.Strings.MinFormat);
            case BAR_OPTION_ACTIVITY_MIN_WEEK:
                return WatchUi.loadResource(Rez.Strings.MinFormat);
            case BAR_OPTION_FLOORS_ASCENDED:
                return WatchUi.loadResource(Rez.Strings.FloorsClimbedFormat);
            case BAR_OPTION_NOTHING:
                break;
            case BAR_OPTION_HEART_RATE:
                return WatchUi.loadResource(Rez.Strings.HeartRateFormat);
            case BAR_OPTION_SUN_EVENT:
                return WatchUi.loadResource(Rez.Strings.TimeFormat);
            case BAR_OPTION_PRESSURE:
                return WatchUi.loadResource(Rez.Strings.PressureFormat);
            case BAR_OPTION_TEMPERATURE_C:
                return WatchUi.loadResource(Rez.Strings.TemperatureCelsiusFormat);
            case BAR_OPTION_TEMPERATURE_F:
                return WatchUi.loadResource(Rez.Strings.TemperatureFahrenheitFormat);
            case BAR_OPTION_ALTITUDE_METRES:
                return WatchUi.loadResource(Rez.Strings.MetresFormat);
            case BAR_OPTION_ALTITUDE_FEET:
                return WatchUi.loadResource(Rez.Strings.FeetFormat);
        }
        // System.println("Exiting getFormatString without a result");
        return "";
    }

    function getStatString(index, formatString, activity) {
        // System.println("Entering getStatString");
        if(formatString == null) {
            System.println("Did not receive a format string");
            return "";
        }
        switch(index) {
            case BAR_OPTION_CALORIES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        return Lang.format(formatString,
                            [activity.calories]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_KILOJOULES:
                if(ActivityMonitor.Info has :calories) {
                    if(activity.calories != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.calories * 4.184).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_STEPS:
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
            case BAR_OPTION_DISTANCE_METRES:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.distance / 100).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_DISTANCE_FEET:
                if(ActivityMonitor.Info has :distance) {
                    if(activity.distance != null) {
                        return Lang.format(formatString,
                            [Math.floor(activity.distance / 30.48).format("%d")]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_ACTIVITY_MIN_DAY:
                if(ActivityMonitor.Info has :activeMinutesDay) {
                    if(activity.activeMinutesDay != null) {
                        return Lang.format(formatString,
                            [activity.activeMinutesDay.total]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_ACTIVITY_MIN_WEEK:
                if(ActivityMonitor.Info has :activeMinutesWeek) {
                    if(activity.activeMinutesWeek != null) {
                        return Lang.format(formatString,
                            [activity.activeMinutesWeek.total]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_FLOORS_ASCENDED:
                if(ActivityMonitor.Info has :floorsClimbed) {
                    if(activity.floorsClimbed != null) {
                        return Lang.format(formatString,
                            [activity.floorsClimbed]);
                    }
                } else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_NOTHING:
                break;
            case BAR_OPTION_HEART_RATE:
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
            case BAR_OPTION_SUN_EVENT:
                if(sunEvent != null) {
                    return Lang.format(formatString,
                        [
                            sunEvent.eventTimeInfo.hour.format("%02d"),
                            sunEvent.eventTimeInfo.min.format("%02d")
                        ]);
                }
                break;
            case BAR_OPTION_PRESSURE:
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
            case BAR_OPTION_TEMPERATURE_C:
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
            case BAR_OPTION_TEMPERATURE_F:
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
            case BAR_OPTION_ALTITUDE_METRES:
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
            case BAR_OPTION_ALTITUDE_FEET:
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

    function updatePosition() {
        // System.println("Entering updatePosition");
        if(Position has :getInfo) {
            locationInfo = Position.getInfo();
            if(Application.getApp().getProperty("TopBarStat") == 10 || Application.getApp().getProperty("BottomBarStat") == 10) {
                if(locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    var now = Time.now();
                    if(sunEvent == null || // if there is no previous reading, definitely calculate the sunrise/set data
                        (now.compare(sunEvent.eventTime) > 0 || now.compare(sunEvent.eventTime) < -43200) // time based checks
                        // TODO: location based checks?
                        ) {
                        // Using Time.today() rather than Time.now()
                        sunEvent = SunData.calculateSunriseSunset(Time.today(), locationInfo, false, sunEvent);
                    }
                }
            }
        }
        // System.println("Exiting updatePosition");
    }

    function onShow() {
        updatePosition();
    }

    function onHide() {
        // TODO
    }

    function onExitSleep() {
        updatePosition();
    }

    function onEnterSleep() {
        // TODO
    }
}

class DigitalSimplicityDelegate extends WatchUi.WatchFaceDelegate {
    function initialize() {
        WatchFaceDelegate.initialize();
    }

    function onPowerBudgetExceeded(powerInfo) {
        partialUpdates = false;
    }
}
