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
    var bluetoothIcon;
    var batteryIcon;
    var batteryDrawable = Rez.Drawables.BatteryFullIcon;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        var batteryX = 178;
        var batteryY = 58;
        var bluetoothX = 38;
        var bluetoothY = 59;
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
        // Get data
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var settings = System.getDeviceSettings();
        var stats = System.getSystemStats();
        var activity = ActivityMonitor.getInfo();

        // Formatting
        var timeFormat = "$1$:$2$";
        var dateFormat = "$1$ $2$";
        var period = "";

        // Format date and time appropriately
        var dateString = Lang.format(dateFormat, [now.day_of_week, now.day]);
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
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, minutes]);

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

        // Update the views
        var timeView = View.findDrawableById("TimeLabel");
        // var hoursView = View.findDrawableById("HoursLabel");
        // var minutesView = View.findDrawableById("MinutesLabel");
        var dateView = View.findDrawableById("DateLabel");
        var periodView = View.findDrawableById("PeriodLabel");
        var notificationView = View.findDrawableById("NotificationCountLabel");
        var batteryView = View.findDrawableById("BatteryLabel");
        var topView = View.findDrawableById("TopLabel");
        var bottomView = View.findDrawableById("BottomLabel");

        timeView.setText(timeString);
        // hoursView.setText(hours + "");
        // minutesView.setText(minutes);
        dateView.setText(dateString.toLower());
        periodView.setText(period);
        notificationView.setText(ncs);
        batteryView.setText(batteryString);
        topView.setText("- " + activity.calories + " -");
        bottomView.setText("- " + activity.steps + " -");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw optional icons
        if(settings.phoneConnected) {
            bluetoothIcon.draw(dc);
        }
        var nextBatteryDrawable = checkBattery(stats.battery);
        if(nextBatteryDrawable != batteryDrawable) {
            batteryDrawable = nextBatteryDrawable;
            batteryIcon.setBitmap(batteryDrawable);
        }
        batteryIcon.draw(dc);
    }

    // Designed to use less battery as available power decreases
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
