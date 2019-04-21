/*
    This file is part of RockFace.

    RockFace is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    RockFace is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with RockFace.  If not, see <https://www.gnu.org/licenses/>.
*/

using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class RockFaceView extends WatchUi.WatchFace {
    // icons
    var bluetoothIcon;
    var batteryIcon;
    var colonIcon;
    var batteryDrawable = Rez.Drawables.BatteryFullIcon;

    // layout constants
    const fgColour = Graphics.COLOR_BLACK;
    const bgColour = Graphics.COLOR_LT_GRAY;
    const batteryX = 178;
    const batteryY = 58;
    const bluetoothX = 38;
    const bluetoothY = 59;
    const colonX = 130;
    const colonY = 120;

    // layout variables
    var topFormat;
    var bottomFormat;

    var barFormatList;
    var moveStringsList;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        barFormatList = [WatchUi.loadResource(Rez.Strings.CaloriesFormat),
            WatchUi.loadResource(Rez.Strings.KilojoulesFormat),
            WatchUi.loadResource(Rez.Strings.StepsFormat),
            WatchUi.loadResource(Rez.Strings.DistanceMetersFormat),
            WatchUi.loadResource(Rez.Strings.DistanceFeetFormat),
            WatchUi.loadResource(Rez.Strings.ActivityMinFormat),
            WatchUi.loadResource(Rez.Strings.ActivityMinFormat),
            WatchUi.loadResource(Rez.Strings.FloorsClimbedFormat),
            WatchUi.loadResource(Rez.Strings.MovementBarFormat),
            WatchUi.loadResource(Rez.Strings.HeartRateFormat)];
        moveStringsList = ["",
            WatchUi.loadResource(Rez.Strings.MovementBarOne),
            WatchUi.loadResource(Rez.Strings.MovementBarTwo),
            WatchUi.loadResource(Rez.Strings.MovementBarThree),
            WatchUi.loadResource(Rez.Strings.MovementBarFour),
            WatchUi.loadResource(Rez.Strings.MovementBarFive)];
        batteryIcon = new WatchUi.Bitmap({
            :rezId=>batteryDrawable,
            :locX=>batteryX,
            :locY=>batteryY
        });
        bluetoothIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BluetoothIcon,
            :locX=>bluetoothX,
            :locY=>bluetoothY
        });
        colonIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.Colon,
            :locX=>colonX,
            :locY=>colonY
        });
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        // TODO
    }

    // Update the view
    function onUpdate(dc) {
        dc.clearClip();

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

        // var timeString = Lang.format(timeFormat, [hours, minutes]);

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
        // var timeView = View.findDrawableById("TimeLabel");

        var dateView = View.findDrawableById("DateLabel");
        var notificationView = View.findDrawableById("NotificationCountLabel");
        var batteryView = View.findDrawableById("BatteryLabel");
        var topView = View.findDrawableById("TopLabel");
        var bottomView = View.findDrawableById("BottomLabel");

        // timeView.setText(timeString);
        dateView.setText(dateString.toLower());
        notificationView.setText(ncs);
        batteryView.setText(batteryString);
        topView.setText(topStatString);
        bottomView.setText(bottomStatString);
        drawTime(dc, settings, app, now);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var nextBatteryDrawable = checkBattery(stats.battery);
        if(nextBatteryDrawable != batteryDrawable) {
            batteryDrawable = nextBatteryDrawable;
            batteryIcon.setBitmap(batteryDrawable);
        }
        batteryIcon.draw(dc);
        if(settings.phoneConnected) {
            bluetoothIcon.draw(dc);
        }
    }

    function onPartialUpdate(dc) {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var app = Application.getApp();
        dc.setClip(colonX, colonY, 8, 60);
        drawColon(dc, app.getProperty("BlinkingColon"), now);
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
        drawColon(dc, app.getProperty("BlinkingColon"), now);
    }

    function drawColon(dc, blinking, now) {
        if(!blinking || now.sec % 2 == 0) {
            colonIcon.draw(dc);
        } else {
            dc.setColor(bgColour, bgColour);
            dc.fillRectangle(colonX, colonY, 8, 60);
            dc.setColor(fgColour, bgColour);
        }
    }

    function getStatString(index, activity) {
        switch(index) {
            case 0:
                if(activity.calories != null) {
                    return Lang.format(barFormatList[index], [activity.calories]);
                }
                break;
            case 1:
                if(activity.calories != null) {
                    return Lang.format(barFormatList[index], [Math.floor(activity.calories * 4.184).format("%d")]);
                }
                break;
            case 2:
                if(activity.steps != null) {
                    return Lang.format(barFormatList[index], [activity.steps]);
                }
                break;
            case 3:
                if(activity.distance != null) {
                    return Lang.format(barFormatList[index], [Math.floor(activity.distance / 100).format("%d")]);
                }
                break;
            case 4:
                if(activity.distance != null) {
                    return Lang.format(barFormatList[index], [Math.floor(activity.distance / 30.48).format("%d")]);
                }
                break;
            case 5:
                if(activity.activeMinutesDay != null) {
                    return Lang.format(barFormatList[index], [activity.activeMinutesDay.total]);
                }
                break;
            case 6:
                if(activity.activeMinutesWeek != null) {
                    return Lang.format(barFormatList[index], [activity.activeMinutesWeek.total]);
                }
                break;
            case 7:
                if(activity.floorsClimbed != null) {
                    return Lang.format(barFormatList[index], [activity.floorsClimbed]);
                }
                break;
            case 8:
                if(activity.moveBarLevel != null) {
                    return Lang.format(barFormatList[index], [moveStringsList[activity.moveBarLevel]]);
                }
                break;
            case 9:
                var sample = activity.getHeartRateHistory(1, true).next();
                if(sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return Lang.format(barFormatList[index], [Math.floor(sample.heartRate).format("%d")]);
                }
                break;
        }
        return "";
    }

    // Designed to use slightly less battery as available power decreases
    function checkBattery(batteryLevel) {
        if(batteryLevel < 10) {
            return Rez.Drawables.BatteryLowIcon;
        } else if(batteryLevel < 33) {
            return Rez.Drawables.BatteryOneQuarterIcon;
        } else if(batteryLevel < 66) {
            return Rez.Drawables.BatteryHalfIcon;
        } else if(batteryLevel < 90) {
            return Rez.Drawables.BatteryThreeQuartersIcon;
        }
        return Rez.Drawables.BatteryFullIcon;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        // TODO
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        // TODO
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        // TODO
    }

}
