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

using Toybox.Test;
using Toybox.Time;

(:debug)
class DateTest {

    (:test)
    function testDayStrings(logger) {
        var letters = {};
        var time = Time.now();
        for(var i = 0; i < 7; i++) {
            var info = Time.Gregorian.info(time, Time.FORMAT_MEDIUM);
            System.println(info.day_of_week + ": " + info.day_of_week.toLower());
            var trigraph = info.day_of_week.toLower();
            for(var j = 0; j < 3; j++) {
                letters.put(trigraph.substring(j, j+1), true);
            }
            time = time.add(new Time.Duration(86400));
        }
        var uniqueLetters = letters.keys();
        // System.print("fre: ");
        for(var k = 0; k < uniqueLetters.size(); k++) {
            System.print(uniqueLetters[k]);
        }
        System.println("");
        return true;
    }
}
