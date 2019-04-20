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
    var batteryFullIcon;
    var batteryThreeQuartersIcon;
    var batteryHalfIcon;
    var batteryOneQuarterIcon;
    var batteryLowIcon;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        var batteryX = 178;
        var batteryY = 58;
        var bluetoothX = 38;
        var bluetoothY = 59;

        bluetoothIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BluetoothIcon,
            :locX=>bluetoothX,
            :locY=>bluetoothY
        });
        batteryFullIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryFullIcon,
            :locX=>batteryX,
            :locY=>batteryY
        });
        batteryThreeQuartersIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryThreeQuartersIcon,
            :locX=>batteryX,
            :locY=>batteryY
        });
        batteryHalfIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryHalfIcon,
            :locX=>batteryX,
            :locY=>batteryY
        });
        batteryOneQuarterIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryOneQuarterIcon,
            :locX=>batteryX,
            :locY=>batteryY
        });
        batteryLowIcon = new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.BatteryLowIcon,
            :locX=>batteryX,
            :locY=>batteryY
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
        if(stats.battery < 10) {
            batteryLowIcon.draw(dc);
        } else if(stats.battery < 33) {
            batteryOneQuarterIcon.draw(dc);
        } else if(stats.battery < 66) {
            batteryHalfIcon.draw(dc);
        } else if(stats.battery < 90) {
            batteryThreeQuartersIcon.draw(dc);
        } else {
            batteryFullIcon.draw(dc);
        }
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
