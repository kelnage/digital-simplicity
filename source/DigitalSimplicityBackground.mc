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

using Toybox.WatchUi as Ui;
using Toybox.Graphics;

class Background extends Ui.Drawable {
    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        var app = Application.getApp();
        var backColour;
        var lineColour;
        var rectColour;
        switch(app.getProperty("ColourTheme")) {
            case DigitalSimplicityView.THEME_CLASSIC_GRAY:
                backColour = Graphics.COLOR_BLACK;
                lineColour = Graphics.COLOR_BLACK;
                rectColour = Graphics.COLOR_LT_GRAY;
                break;
            case DigitalSimplicityView.THEME_CLASSIC_WHITE:
                backColour = Graphics.COLOR_BLACK;
                lineColour = Graphics.COLOR_BLACK;
                rectColour = Graphics.COLOR_WHITE;
                break;
            case DigitalSimplicityView.THEME_DARK_GRAY:
                backColour = Graphics.COLOR_BLACK;
                lineColour = Graphics.COLOR_LT_GRAY;
                rectColour = Graphics.COLOR_BLACK;
                break;
            case DigitalSimplicityView.THEME_DARK_WHITE:
                backColour = Graphics.COLOR_BLACK;
                lineColour = Graphics.COLOR_WHITE;
                rectColour = Graphics.COLOR_BLACK;
                break;
            case DigitalSimplicityView.THEME_INVERSE_GRAY:
                backColour = Graphics.COLOR_LT_GRAY;
                lineColour = Graphics.COLOR_LT_GRAY;
                rectColour = Graphics.COLOR_BLACK;
                break;
            case DigitalSimplicityView.THEME_INVERSE_WHITE:
                backColour = Graphics.COLOR_WHITE;
                lineColour = Graphics.COLOR_WHITE;
                rectColour = Graphics.COLOR_BLACK;
                break;
        }
        dc.setColor(rectColour, backColour);
        dc.clear();
        dc.fillRectangle(0, 40, 240, 160);
        dc.setColor(lineColour, backColour);
        dc.setPenWidth(3);
        // top line
        dc.drawLine(33, 44, 207, 44);
        // bottom line
        dc.drawLine(33, 195, 207, 195);
        // left arc
        dc.drawArc(120, 120, 116, Graphics.ARC_COUNTER_CLOCKWISE, 139, 221);
        // right arc
        dc.drawArc(119, 120, 116, Graphics.ARC_CLOCKWISE, 41, 319);
    }
}
