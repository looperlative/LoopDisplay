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
    width: size
    height: size
    property int size: 100
    property real arcSize: 0
    property color color: "white"
    property real progress: arcSize / size

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // Background arc (full)
            ctx.strokeStyle = "#333333";
            ctx.lineWidth = 3;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(width/2, height/2, width/2 - 5, Math.PI * 0.75, Math.PI * 1.75);
            ctx.stroke();

            // Progress arc
            ctx.strokeStyle = color;
            ctx.beginPath();
            ctx.arc(width/2, height/2, width/2 - 5, Math.PI * 0.75,
                   Math.PI * 0.75 + (progress * Math.PI));
            ctx.stroke();

            // End cap dot
            if (progress > 0) {
                var endX = width/2 + (width/2 - 5) * Math.cos(Math.PI * 0.75 + (progress * Math.PI));
                var endY = height/2 + (width/2 - 5) * Math.sin(Math.PI * 0.75 + (progress * Math.PI));
                ctx.fillStyle = color;
                ctx.beginPath();
                ctx.arc(endX, endY, 3, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }
}
