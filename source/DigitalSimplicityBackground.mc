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

class Background extends Ui.Drawable {
    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        var app = Application.getApp();
        var mainBackground;
        switch(app.getProperty("ColourTheme")) {
            case DigitalSimplicityView.THEME_CLASSIC_GRAY:
                mainBackground = new Rez.Drawables.ClassicGrayBackground();
                break;
            case DigitalSimplicityView.THEME_CLASSIC_WHITE:
                mainBackground = new Rez.Drawables.ClassicWhiteBackground();
                break;
            case DigitalSimplicityView.THEME_DARK_GRAY:
                mainBackground = new Rez.Drawables.DarkGrayForeground();
                break;
            case DigitalSimplicityView.THEME_DARK_WHITE:
                mainBackground = new Rez.Drawables.DarkWhiteForeground();
                break;
            case DigitalSimplicityView.THEME_INVERSE_GRAY:
                mainBackground = new Rez.Drawables.InverseGrayForeground();
                break;
            case DigitalSimplicityView.THEME_INVERSE_WHITE:
                mainBackground = new Rez.Drawables.InverseWhiteForeground();
                break;
        }
        mainBackground.draw( dc );
    }
}