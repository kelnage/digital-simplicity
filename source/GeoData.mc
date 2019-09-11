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

using Toybox.Position;

// Apparently we can't rely on the class Position.Info to exist, so let's make our own...
class GeoData {
	var accuracy = Position.QUALITY_NOT_AVAILABLE;
	var position = null;
	var altitude = null;

	static function valid(geo) {
	   return geo != null && geo.accuracy != Position.QUALITY_NOT_AVAILABLE;
	}

	static function parsePositionInfo(positionInfo) {
		var locationInfo = new GeoData();
		if(positionInfo has :accuracy) {
			locationInfo.accuracy = positionInfo.accuracy;
		}
		if(positionInfo has :position) {
			locationInfo.position = positionInfo.position;
		}
		if(positionInfo has :altitude) {
			locationInfo.altitude = positionInfo.altitude;
		}
        return locationInfo;
	}
	
    static function parseActivityInfo(activityInfo) {
        var locationInfo = new GeoData();
        if(Activity.Info has :currentLocationAccuracy && activityInfo.currentLocationAccuracy != null) {
            locationInfo.accuracy = activityInfo.currentLocationAccuracy;
            if(Position.Info has :position && Activity.Info has :currentLocation) {
                locationInfo.position = activityInfo.currentLocation;
            }
            if(Position.Info has :altitude && Activity.Info has :altitude) {
                locationInfo.altitude = activityInfo.altitude;
            }
        }
        return locationInfo;
    }
}
