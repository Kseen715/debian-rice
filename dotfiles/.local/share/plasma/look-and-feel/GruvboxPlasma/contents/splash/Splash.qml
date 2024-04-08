/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0

Image {
    id: root
    source: "images/background.jpg"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

        

      DataSource {
            id: timeSource
            engine: "time"
            connectedSources: ["Local"]
            interval: 1000
        }
        Column {
            spacing: units.smallSpacing*2
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                margins: units.gridUnit * 2
            }
            Text {
                text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleLongDate)
                font.pointSize: 22
                renderType: Text.QtRendering
                color: "mintcream"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
                font.pointSize: 40
                renderType: Text.QtRendering
                color: "mintcream"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Row {
            id: footer
            spacing: units.smallSpacing*2
            anchors {
                bottom: parent.bottom
                margins: units.gridUnit
            }
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                color: "#eff0f1"
                // Work around Qt bug where NativeRendering breaks for non-integer scale factors
                // https://bugreports.qt.io/browse/QTBUG-67007
                // renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
                // text: "Welcome to Plasma"
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "This is the first text the user sees while starting in the splash screen, should be translated as something short, is a form that can be seen on a product. Plasma is the project name so shouldn't be translated.", "Plasma made by KDE")
            }
            Image {
                id: kdeLogo
                source: "images/kde.svgz"
                // source: "images/badland.svg"

                sourceSize.height: units.gridUnit * 2
                sourceSize.width: units.gridUnit * 2
            }
        }

        Rectangle {
            id: topRect
            y: root.height*0.8
            radius: 3
            color: "#222222"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            height: 6
            width: root.width*0.2
            Rectangle {
                radius: 3
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width / 6) * (stage - 1)
                color: "#8ec07c"
                Behavior on width { 
                    PropertyAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

    SequentialAnimation {
        id: introAnimation
        running: false
        loops: Animation.Infinite
            SequentialAnimation{
                PropertyAnimation {
                property: "scale"
                target: kdeLogo
                from: 0.9
                to: 1.1
                duration: 800
                easing.type: Easing.InBack
                }

                PropertyAnimation {
                property: "scale"
                target: kdeLogo
                from: 1.1
                to: 0.9
                duration: 800
                easing.type:Easing.OutBack
                }

            }
    }
}
