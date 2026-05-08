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
import QtQuick.Controls 6.4

Item {
    id: row
    width: parent.width
    height: 80

    property var trackData: ({});
    property int trackIndex: 0
    property bool selected: false

    property string trackColor: {
        switch(trackIndex) {
            case 0: return "#4488ff";
            case 1: return "#ffcc00";
            case 2: return "#ff44ff";
            case 3: return "#00cccc";
            case 4: return "#ff4444";
            case 5: return "#44ff44";
            case 6: return "#aa6600";
            default: return "#ffffff";
        }
    }

    // Selected track highlight
    Rectangle {
        anchors.fill: parent
        color: selected ? trackColor + "33" : "transparent"
        radius: 4
    }

    // Track number
    Label {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 14
        text: "T" + trackIndex
        color: trackColor
        font.bold: trackData.isPlaying
    }

    // State LED indicator
    StateIndicator {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.top: parent.top
        anchors.topMargin: 29
        active: trackData.isPlaying
        activeColor: trackData.state === 1 ? "#ff4444" :
                     trackData.state === 2 ? "#44ff44" :
                     trackData.state === 3 ? "#444444" :
                     trackData.state === 4 ? "#44ff44" :
                     trackData.state === 5 ? "#ffcc00" :
                     "#333333"
    }

    // Loop arc (position arc)
    LoopArc {
        anchors.left: parent.left
        anchors.leftMargin: 70
        anchors.top: parent.top
        anchors.topMargin: 19
        size: 100
        arcSize: 100 * trackData.loopProgress
        color: trackColor
    }

    // Level meter
    LevelMeter {
        anchors.left: parent.left
        anchors.leftMargin: 180
        anchors.top: parent.top
        anchors.topMargin: 10
        level: 1
    }

    // Pan knob
    PanKnob {
        anchors.left: parent.left
        anchors.leftMargin: 220
        anchors.top: parent.top
        anchors.topMargin: 17
        value: trackData.pan
        color: trackColor
    }

    // Feedback dial
    FeedbackDial {
        anchors.left: parent.left
        anchors.leftMargin: 270
        anchors.top: parent.top
        anchors.topMargin: 19
        value: trackData.feedback
        color: trackColor
    }

    // Track name
    Label {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 14
        text: "Track " + trackIndex
        color: trackColor
    }

    // Separator line
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: selected ? trackColor + "66" : "#333333"
    }
}
