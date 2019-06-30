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
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;
using Toybox.WatchUi;

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

    // state
    var locationInfo = null;
    var sunEvent = null;
    var is24Hour = false;

    // bitmaps
    var alarmIcon;
    var bluetoothIcon;
    var batteryIcon;

    // layout constants
    const alarmX = 79;
    const alarmY = 92;
    const baselineY = 123;
    const midlineY = 89;
    const batteryX = 178;
    const batteryY = 59;
    const bluetoothX = 38;
    const bluetoothY = 57;
    const periodX = 32;
    const secondsY = 124;
    const colonY = 123;
    // workaround until font is completed
    const days = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];

    // layout variables
    var fgColour = Graphics.COLOR_BLACK;
    var bgColour = Graphics.COLOR_LT_GRAY;
    var moveColour = Graphics.COLOR_DK_RED;
    var colonX = 130;
    var secondsX = 191;
    var topFormat;
    var bottomFormat;

    function initialize() {
        WatchFace.initialize();
        partialUpdates = (Toybox.WatchUi.WatchFace has :onPartialUpdate);
    }

    function loadConfig() {
        // System.println("Loading config");
        var app = Application.getApp();
        var settings = System.getDeviceSettings();
        is24Hour = settings.is24Hour;
        topFormat = StatOptions.getFormatString(app.getProperty("TopBarStat"));
        bottomFormat = StatOptions.getFormatString(app.getProperty("BottomBarStat"));
        moveColour = Graphics.COLOR_DK_RED;
        var colourTheme = app.getProperty("ColourTheme");
        var displaySeconds = app.getProperty("DisplaySeconds");
        var dateView = View.findDrawableById("DateLabel");
        var notificationView = View.findDrawableById("NotificationCountLabel");
        var batteryView = View.findDrawableById("BatteryLabel");
        var hoursView = View.findDrawableById("HoursLabel");
        var minutesView = View.findDrawableById("MinutesLabel");
        var secondsView = View.findDrawableById("SecondsLabel");
        var periodView = View.findDrawableById("PeriodLabel");
        if(displaySeconds) {
            var baselineX = 208;
            if(is24Hour) {
                baselineX = 221;
            }
            periodView.setLocation(periodX, 89);
            hoursView.setLocation(baselineX - 116, baselineY); // 92 normal, 105 if 24 hours
            colonX = baselineX - 113; // 95 normal, 108 if 24 hours
            minutesView.setLocation(baselineX - 32, baselineY); // 176 normal, 189 if 24 hours
            secondsX = baselineX - 30;
            secondsView.setLocation(baselineX, baselineY);
        } else {
            periodView.setLocation(periodX, 161);
            hoursView.setLocation(128, baselineY);
            minutesView.setLocation(210, baselineY);
            colonX = 130;
            secondsView.setText("");
        }
        switch(colourTheme) {
            case THEME_DARK_GRAY:
            case THEME_DARK_WHITE:
                bgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_DARK_GRAY) {
                    fgColour = Graphics.COLOR_LT_GRAY;
                } else {
                    fgColour = Graphics.COLOR_WHITE;
                }
                break;
            case THEME_INVERSE_GRAY:
            case THEME_INVERSE_WHITE:
                bgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_INVERSE_GRAY) {
                    fgColour = Graphics.COLOR_LT_GRAY;
                } else {
                    fgColour = Graphics.COLOR_WHITE;
                }
                break;
            default:
                fgColour = Graphics.COLOR_BLACK;
                if(colourTheme == THEME_CLASSIC_GRAY) {
                    bgColour = Graphics.COLOR_LT_GRAY;
                } else {
                    bgColour = Graphics.COLOR_WHITE;
                }
                break;
        }
        switch(colourTheme) {
            case THEME_DARK_GRAY:
            case THEME_DARK_WHITE:
                View.findDrawableById("TopLabel").setColor(fgColour);
                View.findDrawableById("BottomLabel").setColor(fgColour);
                break;
            default:
                View.findDrawableById("TopLabel").setColor(bgColour);
                View.findDrawableById("BottomLabel").setColor(bgColour);
                break;
        }
        switch(fgColour) {
            case Graphics.COLOR_BLACK:
                alarmIcon = new WatchUi.Bitmap({
                    :rezId=>Rez.Drawables.AlarmIconBlack,
                    :locX=>alarmX,
                    :locY=>alarmY
                });
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
                break;
            case Graphics.COLOR_LT_GRAY:
                alarmIcon = new WatchUi.Bitmap({
                    :rezId=>Rez.Drawables.AlarmIconGray,
                    :locX=>alarmX,
                    :locY=>alarmY
                });
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
                break;
            case Graphics.COLOR_WHITE:
                alarmIcon = new WatchUi.Bitmap({
                    :rezId=>Rez.Drawables.AlarmIconWhite,
                    :locX=>alarmX,
                    :locY=>alarmY
                });
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
                break;
        }
        dateView.setColor(fgColour);
        notificationView.setColor(fgColour);
        batteryView.setColor(fgColour);
        hoursView.setColor(fgColour);
        minutesView.setColor(fgColour);
        secondsView.setColor(fgColour);
        periodView.setColor(fgColour);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        loadConfig();
    }

    function onUpdate(dc) {
        dc.clearClip();
        dc.setColor(fgColour, bgColour);

        var settings = System.getDeviceSettings();
        if(is24Hour != settings.is24Hour) {
            // this will be slow - but should not be called regularly
            // workaround for onSettingsChanged not being triggered by device settings changes
            // is24Hour will be updated by loadConfig
            loadConfig();
        }

        // Get data
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var stats = System.getSystemStats();
        var activity = ActivityMonitor.getInfo();
        var app = Application.getApp();

        // Format date and time appropriately
        var dateString = getDate(now);

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
        var topStatString = StatOptions.getStatString(app.getProperty("TopBarStat"), topFormat, sunEvent, activity, settings);
        var bottomStatString = StatOptions.getStatString(app.getProperty("BottomBarStat"), bottomFormat, sunEvent, activity, settings);

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
        if(settings.alarmCount > 0) {
            alarmIcon.draw(dc);
        }
        if(settings.phoneConnected) {
            bluetoothIcon.draw(dc);
        }
        drawColon(dc, app.getProperty("BlinkingColon"), now.sec);
    }

    function onPartialUpdate(dc) {
        var now = System.getClockTime();
        var app = Application.getApp();
        if(app.getProperty("DisplaySeconds")) {
            dc.setClip(secondsX, secondsY, 30, 22);
            drawSeconds(dc, now.sec);
        }
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
        }
        var hoursView = View.findDrawableById("HoursLabel");
        var minutesView = View.findDrawableById("MinutesLabel");
        var periodView = View.findDrawableById("PeriodLabel");
        if(app.getProperty("DisplaySeconds")) {
            var secondsView = View.findDrawableById("SecondsLabel");
            secondsView.setText(now.sec.format("%02d"));
        }
        hoursView.setText(hours + "");
        minutesView.setText(minutes);
        periodView.setText(period);
    }

    function drawSeconds(dc, seconds) {
        dc.setColor(bgColour, bgColour);
        dc.fillRectangle(secondsX, secondsY, 30, 22);
        dc.setColor(fgColour, bgColour);
        var secondsView = View.findDrawableById("SecondsLabel");
        secondsView.setText(seconds.format("%02d"));
        secondsView.draw(dc);
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

    function getDate(time) {
        // Assumes Time.FORMAT_SHORT
        return Lang.format("$1$ $2$", [days[time.day_of_week - 1], time.day]);
    }

    function parseActivityInfo(activityInfo) {
        var locationInfo = new Position.Info();
        if(Activity.Info has :currentLocationAccuracy && activityInfo.currentLocationAccuracy != null) {
            locationInfo.accuracy = activityInfo.currentLocationAccuracy;
            if(Position.Info has :position && Activity.Info has :currentLocation) {
                locationInfo.position = activityInfo.currentLocation;
            }
            if(Position.Info has :altitude && Activity.Info has :altitude) {
                locationInfo.altitude = activityInfo.altitude;
            }
        } else {
            locationInfo.accuracy = Position.QUALITY_NOT_AVAILABLE;
        }
        return locationInfo;
    }

    function updatePosition() {
        // System.println("Entering updatePosition");
        var top = Application.getApp().getProperty("TopBarStat");
        var bottom = Application.getApp().getProperty("BottomBarStat");
        if(StatOptions.requiresLocation(top) || StatOptions.requiresLocation(bottom)) {
            if(Position has :getInfo) {
                locationInfo = Position.getInfo();
            }
            if((locationInfo == null || locationInfo.accuracy == Position.QUALITY_NOT_AVAILABLE) && Activity has :getActivityInfo && Activity.Info has :currentLocation) {
                locationInfo = parseActivityInfo(Activity.getActivityInfo());
            }
            if(locationInfo != null && locationInfo.accuracy != Position.QUALITY_NOT_AVAILABLE &&
                    (StatOptions.requiresSunData(top) || StatOptions.requiresSunData(bottom))) {
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
