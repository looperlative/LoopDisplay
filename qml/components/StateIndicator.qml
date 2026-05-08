// Copyright (C) 2026 Robert Amstadt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import QtQuick 6.4

Rectangle {
    id: indicator
    width: 20
    height: 20
    radius: 10
    property bool active: false
    property color activeColor: "white"

    color: active ? activeColor : "#333333"

    Rectangle {
        anchors.centerIn: parent
        width: 8
        height: 8
        radius: 4
        color: active ? Qt.lighter(activeColor, 1.4) : "#222222"
    }

    SequentialAnimation on opacity {
        running: active
        loops: Animation.Infinite
        NumberAnimation { to: 0.6; duration: 400 }
        NumberAnimation { to: 1.0; duration: 400 }
    }
}
