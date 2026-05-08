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
import QtQuick.Layouts 6.4

Item {
    id: root
    width: 12
    height: 60
    property real level: 0.0
    signal levelChanged()

    function setLevel(newLevel) {
        level = newLevel;
        levelChanged();
    }

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // LED background
            ctx.fillStyle = "gray";
            ctx.fillRect(0, 0, width, height);

            // Red zone
            ctx.fillStyle = "yellow";
            ctx.fillRect(0, height * (1 - 0.25), width, height * 0.25);

            // Green zone
            ctx.fillStyle = "#44ff44";
            ctx.fillRect(0, 0, width, height);

            // Current level - bright green/red
            ctx.fillStyle = "green";
            ctx.fillRect(0, height * level, width, height * (1 - level));
        }
    }
}
