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

using Toybox.Application;
using Toybox.WatchUi;

class DigitalSimplicityApp extends Application.AppBase {
    var view = null;

    function initialize() {
        AppBase.initialize();
        view = new DigitalSimplicityView();
    }

    // Initialise the view - likely only called once?
    function getInitialView() {
        return [ view ];
    }

    // Update settings if a view is available
    function onSettingsChanged() {
        if(view != null) {
            view.loadConfig();
            WatchUi.requestUpdate();
        }
    }

}