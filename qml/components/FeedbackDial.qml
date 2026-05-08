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

            var cx = width/2;
            var cy = height/2;
            var radius = width/2 - 3;

            // Dial background
            ctx.fillStyle = "#333333";
            ctx.beginPath();
            ctx.arc(cx, cy, radius, Math.PI * 0.75, Math.PI * 1.75);
            ctx.lineWidth = radius * 0.4;
            ctx.strokeStyle = "#222222";
            ctx.stroke();

            // Feedback level arc
            var angle = Math.PI * 0.75 + (value / 200.0 * Math.PI);
            ctx.strokeStyle = color;
            ctx.lineWidth = radius * 0.35;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, Math.PI * 0.75, angle);
            ctx.stroke();

            // Center dot
            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(cx, cy, 3, 0, Math.PI * 2);
            ctx.fill();
        }
    }
}
