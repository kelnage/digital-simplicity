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
