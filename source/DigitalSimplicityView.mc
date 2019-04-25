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

var partialUpdates = false;
var locationInfo = null;

class DigitalSimplicityView extends WatchUi.WatchFace {
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
    var sunEvent;

    // icons
    var bluetoothIcon;
    var batteryIcon;

    // layout constants
    const fgColour = Graphics.COLOR_BLACK;
    const bgColour = Graphics.COLOR_LT_GRAY;
    const batteryX = 178;
    const batteryY = 59;
    const bluetoothX = 38;
    const bluetoothY = 57;
    const colonX = 130;
    const colonY = 123;

    // layout variables
    var topFormat;
    var bottomFormat;
    var barFormatList;

    function initialize() {
        WatchFace.initialize();
        partialUpdates = (Toybox.WatchUi.WatchFace has :onPartialUpdate);
    }

    function onLayout(dc) {
        barFormatList = [
            WatchUi.loadResource(Rez.Strings.CaloriesFormat),
            WatchUi.loadResource(Rez.Strings.KilojoulesFormat),
            WatchUi.loadResource(Rez.Strings.StepsFormat),
            WatchUi.loadResource(Rez.Strings.MetresFormat),
            WatchUi.loadResource(Rez.Strings.FeetFormat),
            WatchUi.loadResource(Rez.Strings.MinFormat),
            WatchUi.loadResource(Rez.Strings.MinFormat),
            WatchUi.loadResource(Rez.Strings.FloorsClimbedFormat),
            "",
            WatchUi.loadResource(Rez.Strings.HeartRateFormat),
            WatchUi.loadResource(Rez.Strings.TimeFormat),
            WatchUi.loadResource(Rez.Strings.PressureFormat),
            WatchUi.loadResource(Rez.Strings.TemperatureCelsiusFormat),
            WatchUi.loadResource(Rez.Strings.TemperatureFahrenheitFormat),
            WatchUi.loadResource(Rez.Strings.MetresFormat),
            WatchUi.loadResource(Rez.Strings.FeetFormat)
        ];
        batteryIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryTemplateIcon,
            :locX=>batteryX,
            :locY=>batteryY
        });
        bluetoothIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BluetoothIconBold,
            :locX=>bluetoothX,
            :locY=>bluetoothY
        });
        setLayout(Rez.Layouts.WatchFace(dc));
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
        var batteryString = stats.battery.format("%d") + "%";

        // Load appropriate stats
        var topStatString = getStatString(app.getProperty("TopBarStat"), activity);
        var bottomStatString = getStatString(app.getProperty("BottomBarStat"), activity);

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
        dc.setColor(Graphics.COLOR_DK_RED, bgColour);
        dc.fillRectangle(33, 194, moveNumber * 35, 3);
    }

    function needsSensorInfo(option) {
        return (option == BAR_OPTION_PRESSURE || option == BAR_OPTION_TEMPERATURE_C || option == BAR_OPTION_TEMPERATURE_F || option == BAR_OPTION_ALTITUDE_METRES || option == BAR_OPTION_ALTITUDE_FEET);
    }

    function getStatString(index, activity) {
        switch(index) {
            case BAR_OPTION_CALORIES:
                if(!(ActivityMonitor.Info has :calories)) {
                    return "N/S";
                }
                if(activity.calories != null) {
                    return Lang.format(
                        barFormatList[index],
                        [activity.calories]);
                }
                break;
            case BAR_OPTION_KILOJOULES:
                if(!(ActivityMonitor.Info has :calories)) {
                    return "N/S";
                }
                if(activity.calories != null) {
                    return Lang.format(
                        barFormatList[index],
                        [Math.floor(activity.calories * 4.184).format("%d")]);
                }
                break;
            case BAR_OPTION_STEPS:
                if(!(ActivityMonitor.Info has :steps)) {
                    return "N/S";
                }
                if(activity.steps != null) {
                    return Lang.format(
                        barFormatList[index],
                        [activity.steps]);
                }
                break;
            case BAR_OPTION_DISTANCE_METRES:
                if(!(ActivityMonitor.Info has :distance)) {
                    return "N/S";
                }
                if(activity.distance != null) {
                    return Lang.format(
                        barFormatList[index],
                        [Math.floor(activity.distance / 100).format("%d")]);
                }
                break;
            case BAR_OPTION_DISTANCE_FEET:
                if(!(ActivityMonitor.Info has :distance)) {
                    return "N/S";
                }
                if(activity.distance != null) {
                    return Lang.format(
                        barFormatList[index],
                        [Math.floor(activity.distance / 30.48).format("%d")]);
                }
                break;
            case BAR_OPTION_ACTIVITY_MIN_DAY:
                if(!(ActivityMonitor.Info has :activeMinutesDay)) {
                    return "N/S";
                }
                if(activity.activeMinutesDay != null) {
                    return Lang.format(
                        barFormatList[index],
                        [activity.activeMinutesDay.total]);
                }
                break;
            case BAR_OPTION_ACTIVITY_MIN_WEEK:
                if(!(ActivityMonitor.Info has :activeMinutesWeek)) {
                    return "N/S";
                }
                if(activity.activeMinutesWeek != null) {
                    return Lang.format(
                        barFormatList[index],
                        [activity.activeMinutesWeek.total]);
                }
                break;
            case BAR_OPTION_FLOORS_ASCENDED:
                if(!(ActivityMonitor.Info has :floorsClimbed)) {
                    return "N/S";
                }
                if(activity.floorsClimbed != null) {
                    return Lang.format(
                        barFormatList[index],
                        [activity.floorsClimbed]);
                }
                break;
            case BAR_OPTION_NOTHING:
                break;
            case BAR_OPTION_HEART_RATE:
                if(!(ActivityMonitor.Info has :getHeartRateHistory)) {
                    return "N/S";
                }
                var sample = activity.getHeartRateHistory(1, true).next();
                if(sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return Lang.format(
                        barFormatList[index],
                        [Math.floor(sample.heartRate).format("%d")]);
                }
                break;
            case BAR_OPTION_SUN_EVENT:
                if(sunEvent != null) {
                    return Lang.format(
                        barFormatList[index],
                        [
                            sunEvent.eventTimeInfo.hour.format("%02d"),
                            sunEvent.eventTimeInfo.min.format("%02d")
                        ]);
                }
                break;
            case BAR_OPTION_PRESSURE:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getPressureHistory({});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(
                                barFormatList[index],
                                [(sample.data / 100).format("%.1f")]);
                        }
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_TEMPERATURE_C:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getTemperatureHistory({});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(
                                barFormatList[index],
                                [sample.data.format("%.1f")]);
                        }
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_TEMPERATURE_F:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getTemperatureHistory({});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(
                                barFormatList[index],
                                [((sample.data * 1.8) + 32).format("%.1f")]);
                        }
                    }
                }
                else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_ALTITUDE_METRES:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getElevationHistory({});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(
                                barFormatList[index],
                                [sample.data.format("%d")]);
                        }
                    }
                }
                else if(Position.Info has :altitude && locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    return Lang.format(
                        barFormatList[index],
                        [locationInfo.altitude.format("%d")]);
                }
                else {
                    return "N/S";
                }
                break;
            case BAR_OPTION_ALTITUDE_FEET:
                if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
                    var sampleIterator = Toybox.SensorHistory.getElevationHistory({});
                    if(sampleIterator != null) {
                        var sample = sampleIterator.next();
                        if(sample != null && sample.data != null) {
                            return Lang.format(
                                barFormatList[index],
                                [(sample.data * 3.281).format("%d")]);
                        }
                    }
                }
                else if(Position.Info has :altitude && locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE) {
                    return Lang.format(
                        barFormatList[index],
                        [(locationInfo.altitude * 3.281).format("%d")]);
                }
                else {
                    return "N/S";
                }
                break;
        }
        return "";
    }

    function updatePosition() {
        // System.println("Fly my pretties");
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
