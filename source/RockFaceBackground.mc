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

using Toybox.WatchUi as Ui;

class Background extends Ui.Drawable {
    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        var mainBackground = new Rez.Drawables.MainBackground();
        mainBackground.draw( dc );
    }
}