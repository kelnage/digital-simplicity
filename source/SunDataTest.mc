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

class SunDataTest {

    (:test)
    function testSimpleMod(logger) {
        try {
            var success = true;
            var n = 5;
            for(var a = 0; a <= n; a++) {
                Test.assertMessage(SunData.mod(a, n) == (a % n), "For " + a + " mod " + n + " expected: " + (a % n) + "; got: " + SunData.mod(a, n));
                success = success && SunData.mod(a, n) == (a % n);
            }
            return success;
        } catch( ex ) {
            ex.printStackTrace();
            return false;
        }
    }
}
