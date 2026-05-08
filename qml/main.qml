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
import QtQuick.Controls 6.4
import QtQuick.Layouts 6.4

ApplicationWindow {
    id: winWin
    visible: true
    width: 1300
    height: 850
    title: "Looperlative Display"

    // State color palette
    function stateColor(st) {
        switch(st) {
            case 1: return "#dd2222";   // recording  – red
            case 2: return "#22aa44";   // overdubbing – green
            case 3: return "#2255aa";   // stopped     – blue
            case 4: return "#22aa44";   // playing     – green
            case 5: return "#22aa44";   // replacing   – green
            default: return "#333333";  // empty
        }
    }
    function stateLabel(st) {
        switch(st) {
            case 1: return "REC";
            case 2: return "DUB";
            case 3: return "STOP";
            case 4: return "PLAY";
            case 5: return "REPL";
            default: return "EMPTY";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Status bar
        Rectangle {
            Layout.preferredHeight: 36
            Layout.margins: 4
            Layout.fillWidth: true
            color: "#161616"

            Rectangle {
                anchors.left: parent.left; anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 12; height: 12; radius: 6
                color: deviceFinder.found ? "#33dd33" : "#dd3333"
            }

            Label {
                anchors.left: parent.left; anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                width: 260
                text: deviceFinder.found ? deviceFinder.deviceVersion : "Searching..."
                color: deviceFinder.found ? "#aaaaaa" : "#885555"
                font.pixelSize: 12
                elide: Qt.ElideRight
            }

            Label {
                anchors.right: parent.right; anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "LoopDisplay 0.1"
                color: "#444444"
                font.pixelSize: 10
            }
        }

        // Track rows
        ColumnLayout {
            spacing: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 4

            Repeater {
                model: mixerModel.trackCount

                delegate: Rectangle {
                    id: trackRow
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 5

                    property var trackObj: mixerModel.track(index)
                    property bool isSelected: mixerModel.selectedTrackIndex === index

                    property color accentColor: {
                        switch(index) {
                            case 0: return "#4488ff";
                            case 1: return "#ffcc00";
                            case 2: return "#ff8800";
                            case 3: return "#00cccc";
                            case 4: return "#ff4444";
                            case 5: return "#44ff44";
                            case 6: return "#cc44ff";
                            case 7: return "#ffffff";
                            default: return "#888888";
                        }
                    }

                    // Track body — selected gets a tinted background
                    color: isSelected ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.08) : "#111111"

                    // Selected: thick left border in accentColor; unselected: invisible
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: isSelected ? 5 : 0
                        color: accentColor
                        radius: 3
                    }

                    // ── Left panel: track number + state badge ──
                    Item {
                        id: leftPanel
                        anchors.left: parent.left; anchors.leftMargin: isSelected ? 14 : 10
                        anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: 110

                        // Track number
                        Label {
                            id: trackNum
                            anchors.top: parent.top; anchors.topMargin: 8
                            anchors.left: parent.left
                            text: "T" + (index + 1)
                            color: accentColor
                            font.bold: true
                            font.pixelSize: 24
                        }

                        // State badge – large, prominent, color-coded
                        Rectangle {
                            id: stateBadge
                            anchors.top: trackNum.bottom; anchors.topMargin: 4
                            anchors.left: parent.left
                            width: 72
                            height: 22
                            radius: 4
                            color: stateColor(trackObj.state)

                            Label {
                                anchors.centerIn: parent
                                text: stateLabel(trackObj.state)
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 11
                                font.letterSpacing: 0.8
                            }

                            // Pulse animation for active states
                            SequentialAnimation on opacity {
                                running: trackObj.state === 1 || trackObj.state === 2 || trackObj.state === 5
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.55; duration: 500 }
                                NumberAnimation { to: 1.0;  duration: 500 }
                            }
                        }
                    }

                    // ── Right panel: scrubber + dials ──
                    RowLayout {
                        anchors.left: leftPanel.right; anchors.leftMargin: 6
                        anchors.right: parent.right; anchors.rightMargin: 10
                        anchors.top: parent.top; anchors.topMargin: 7
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 5
                        spacing: 8

                        // ── Loop position scrubber ──
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Label {
                                anchors.left: parent.left
                                anchors.top: parent.top; anchors.topMargin: 2
                                text: "Loop"
                                color: "#444444"; font.pixelSize: 9
                            }

                            Rectangle {
                                id: scrubTrack
                                anchors.left: parent.left; anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -6
                                height: 2
                                color: trackObj.hasLoop ? "#2a2a2a" : "#1e1e1e"
                            }

                            // Normal playhead (hidden while recording)
                            Rectangle {
                                anchors.verticalCenter: scrubTrack.verticalCenter
                                x: trackObj.hasLoop
                                   ? Math.max(0, Math.min(parent.width - 5, trackObj.loopProgress * parent.width))
                                   : 0
                                width: 5; height: 26
                                radius: 1
                                color: stateColor(trackObj.state)
                                visible: trackObj.hasLoop && trackObj.state !== 1
                            }

                            // Recording pulse bar — centered, pulses width
                            Rectangle {
                                id: recBar
                                anchors.verticalCenter: scrubTrack.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 6; height: 26
                                radius: 1
                                color: "#dd2222"
                                visible: trackObj.state === 1

                                SequentialAnimation on width {
                                    running: trackObj.state === 1
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 36; duration: 500; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 6;  duration: 500; easing.type: Easing.InOutSine }
                                }
                            }

                            Row {
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 0
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 6

                                Label {
                                    text: trackObj.hasLoop ? (trackObj.position / 48000).toFixed(1) + " s" : "—"
                                    color: "#bbbbbb"; font.pixelSize: 20; font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Label {
                                    text: trackObj.hasLoop ? "/" : ""
                                    color: "#555555"; font.pixelSize: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Label {
                                    text: trackObj.hasLoop ? (trackObj.length / 48000).toFixed(1) + " s" : ""
                                    color: "#888888"; font.pixelSize: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // ── Volume dial ──
                        Item {
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true

                            Canvas {
                                id: volDial
                                width: 52; height: 52
                                anchors.top: parent.top; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width / 2, cy = height / 2, r = width / 2 - 5;
                                    var startAngle = 2 * Math.PI / 3;
                                    var endAngle   = Math.PI / 3;
                                    var sweep      = 5 * Math.PI / 3;

                                    ctx.fillStyle = "#252525";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r + 3, 0, Math.PI * 2);
                                    ctx.fill();

                                    ctx.strokeStyle = "#3a3a3a";
                                    ctx.lineWidth = 4; ctx.lineCap = "butt";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, startAngle, endAngle);
                                    ctx.stroke();

                                    var norm = Math.max(0, Math.min(1, 1.0 + (trackObj.level || 0) / 96.0));
                                    var valAngle = startAngle + norm * sweep;
                                    if (norm > 0) {
                                        ctx.strokeStyle = accentColor;
                                        ctx.lineWidth = 4; ctx.lineCap = "butt";
                                        ctx.beginPath();
                                        ctx.arc(cx, cy, r, startAngle, valAngle);
                                        ctx.stroke();
                                    }

                                    var tx = Math.cos(valAngle), ty = Math.sin(valAngle);
                                    ctx.strokeStyle = "#ffffff";
                                    ctx.lineWidth = 2.5; ctx.lineCap = "round";
                                    ctx.beginPath();
                                    ctx.moveTo(cx + (r - 5) * tx, cy + (r - 5) * ty);
                                    ctx.lineTo(cx + (r + 4) * tx, cy + (r + 4) * ty);
                                    ctx.stroke();
                                }

                                Connections {
                                    target: trackObj
                                    function onDataChanged() { volDial.requestPaint() }
                                }
                            }

                            Label {
                                anchors.top: volDial.bottom; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Vol"
                                color: "#555555"; font.pixelSize: 9
                            }
                        }

                        // ── Pan dial ──
                        Item {
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true

                            Canvas {
                                id: panDial
                                width: 52; height: 52
                                anchors.top: parent.top; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width / 2, cy = height / 2, r = width / 2 - 5;
                                    var startAngle = 2 * Math.PI / 3;
                                    var endAngle   = Math.PI / 3;
                                    var sweep      = 5 * Math.PI / 3;

                                    ctx.fillStyle = "#252525";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r + 3, 0, Math.PI * 2);
                                    ctx.fill();

                                    ctx.strokeStyle = "#3a3a3a";
                                    ctx.lineWidth = 4; ctx.lineCap = "butt";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, startAngle, endAngle);
                                    ctx.stroke();

                                    // center reference notch at 12 o'clock (center pan)
                                    var cAngle = startAngle + sweep * 0.5;
                                    ctx.strokeStyle = "#555555";
                                    ctx.lineWidth = 1.5; ctx.lineCap = "butt";
                                    ctx.beginPath();
                                    ctx.moveTo(cx + (r - 4) * Math.cos(cAngle), cy + (r - 4) * Math.sin(cAngle));
                                    ctx.lineTo(cx + (r + 4) * Math.cos(cAngle), cy + (r + 4) * Math.sin(cAngle));
                                    ctx.stroke();

                                    var norm = Math.max(0, Math.min(1, ((trackObj.pan || 0) + 127) / 254.0));
                                    var valAngle = startAngle + norm * sweep;
                                    var tx = Math.cos(valAngle), ty = Math.sin(valAngle);
                                    ctx.strokeStyle = accentColor;
                                    ctx.lineWidth = 2.5; ctx.lineCap = "round";
                                    ctx.beginPath();
                                    ctx.moveTo(cx + (r - 5) * tx, cy + (r - 5) * ty);
                                    ctx.lineTo(cx + (r + 4) * tx, cy + (r + 4) * ty);
                                    ctx.stroke();
                                }

                                Connections {
                                    target: trackObj
                                    function onDataChanged() { panDial.requestPaint() }
                                }
                            }

                            Label {
                                anchors.top: panDial.bottom; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Pan"
                                color: "#555555"; font.pixelSize: 9
                            }
                        }

                        // ── Feedback dial ──
                        Item {
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true

                            Canvas {
                                id: fbDial
                                width: 52; height: 52
                                anchors.top: parent.top; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var cx = width / 2, cy = height / 2, r = width / 2 - 5;
                                    var startAngle = 2 * Math.PI / 3;
                                    var endAngle   = Math.PI / 3;
                                    var sweep      = 5 * Math.PI / 3;

                                    ctx.fillStyle = "#252525";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r + 3, 0, Math.PI * 2);
                                    ctx.fill();

                                    ctx.strokeStyle = "#3a3a3a";
                                    ctx.lineWidth = 4; ctx.lineCap = "butt";
                                    ctx.beginPath();
                                    ctx.arc(cx, cy, r, startAngle, endAngle);
                                    ctx.stroke();

                                    var norm = Math.max(0, Math.min(1, (trackObj.feedback || 0) / 100.0));
                                    var valAngle = startAngle + norm * sweep;
                                    if (norm > 0) {
                                        ctx.strokeStyle = accentColor;
                                        ctx.lineWidth = 4; ctx.lineCap = "butt";
                                        ctx.beginPath();
                                        ctx.arc(cx, cy, r, startAngle, valAngle);
                                        ctx.stroke();
                                    }

                                    var tx = Math.cos(valAngle), ty = Math.sin(valAngle);
                                    ctx.strokeStyle = "#ffffff";
                                    ctx.lineWidth = 2.5; ctx.lineCap = "round";
                                    ctx.beginPath();
                                    ctx.moveTo(cx + (r - 5) * tx, cy + (r - 5) * ty);
                                    ctx.lineTo(cx + (r + 4) * tx, cy + (r + 4) * ty);
                                    ctx.stroke();
                                }

                                Connections {
                                    target: trackObj
                                    function onDataChanged() { fbDial.requestPaint() }
                                }
                            }

                            Label {
                                anchors.top: fbDial.bottom; anchors.topMargin: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Fdbk"
                                color: "#555555"; font.pixelSize: 9
                            }
                        }

                    } // RowLayout (right panel)
                } // delegate Rectangle
            } // Repeater
        } // ColumnLayout tracks
    } // ColumnLayout root

    Component.onCompleted: {
        deviceFinder.startSearch();
        deviceNetwork.setPollIntervalMs(33);
        deviceNetwork.startPull();
    }
}
