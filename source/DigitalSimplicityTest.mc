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
using Toybox.Application;
using Toybox.System;
using Toybox.Test;
using Toybox.Time;

(:debug)
class DigitalSimplicityTest {    
    (:test)
    function testStatOptions(logger) {
        var app = Application.getApp();
        var geo = GeoData.parsePositionInfo(Position.getInfo());
        var sunEvent = SunData.calculateSunriseSunset(Time.today(), geo, false, null);
        var actInfo = Activity.getActivityInfo();
        var actMonInfo = ActivityMonitor.getInfo();
        var settings = System.getDeviceSettings();
        
        for(var i = 0; i < 18; i++) {
            logger.debug("Bar Test #" + i);
            StatOptions.getStatString(i, StatOptions.getFormatString(i), geo, sunEvent, actInfo, actMonInfo, settings);
        }
        return true;
    }
}
