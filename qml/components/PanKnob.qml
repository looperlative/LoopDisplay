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
    width: 40
    height: 40
    property real value: 0.0
    property color color: "white"

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2;
            var cy = height / 2;
            var radius = width / 2 - 5;

            // Knob base
            ctx.fillStyle = "#444444";
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.fill();

            // Background arc
            ctx.strokeStyle = "#222222";
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(cx, cy, radius - 5, Math.PI * 0.75, Math.PI * 1.75);
            ctx.stroke();

            // Pan position arc
            var panAngle = Math.PI * 0.75 + ((value + 127) / 255 * Math.PI);
            ctx.strokeStyle = color;
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.arc(cx, cy, radius - 5, Math.PI * 0.75, panAngle);
            ctx.stroke();
        }
    }
}
