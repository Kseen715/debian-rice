/***************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.0
import org.kde.plasma.private.showdesktop 0.1

Item {
    id: root

    readonly property bool inPanel: (plasmoid.location === PlasmaCore.Types.TopEdge
                                     || plasmoid.location === PlasmaCore.Types.RightEdge
                                     || plasmoid.location === PlasmaCore.Types.BottomEdge
                                     || plasmoid.location === PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor === PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (plasmoid.configuration.useCustomButtonImage
                                                  && plasmoid.configuration.customButtonImage.length !== 0)
    property QtObject dashWindow: null


    readonly property bool showAllButtons: plasmoid.configuration.showAllButtonsCheckBox
    property int buttonHeight: 10
    readonly property int rowSpacing:    15
    readonly property int columnSpacing: 12
    //==========================
    property QtObject showdesktop: ShowDesktop { }
    //==========================
    onWidthChanged: {
        updateSizeHints()
        updateButtonHeight()
    }
    onHeightChanged: {
        updateSizeHints()
        updateButtonHeight()
    }

    onDashWindowChanged: {
        if (dashWindow) {
            dashWindow.visualParent = root;
        }
    }
    onShowAllButtonsChanged: {
        updateSizeHints()
        updateButtonHeight()
    }

    function updateSizeHints() {
        if(plasmoid.configuration.showAllButtonsCheckBox){
            if (vertical) {
                root.Layout.minimumHeight = units.iconSizes.smallMedium*3 + 4*root.columnSpacing;
                root.Layout.maximumHeight = units.iconSizes.smallMedium*3 + 4*root.columnSpacing;
                root.Layout.minimumWidth = units.iconSizes.small;
                root.Layout.maximumWidth = inPanel ? units.iconSizeHints.panel : -1;
            } else {
                root.Layout.minimumWidth = units.iconSizes.smallMedium*3 + 4* root.rowSpacing + units.smallSpacing*2;
                root.Layout.maximumWidth = units.iconSizes.smallMedium*3 + 4* root.rowSpacing + units.smallSpacing*2;
                root.Layout.minimumHeight = units.iconSizes.small;
                root.Layout.maximumHeight = inPanel ? units.iconSizeHints.panel : -1;
            }
        }else{

            if (vertical) {
                root.Layout.minimumHeight = units.iconSizes.smallMedium + root.columnSpacing;
                root.Layout.maximumHeight = units.iconSizes.smallMedium + root.columnSpacing;
                root.Layout.minimumWidth = units.iconSizes.small;
                root.Layout.maximumWidth = inPanel ? units.iconSizeHints.panel : -1;
            } else {
                root.Layout.minimumWidth = units.iconSizes.smallMedium +  root.rowSpacing + units.smallSpacing*2;
                root.Layout.maximumWidth = units.iconSizes.smallMedium +  root.rowSpacing + units.smallSpacing*2;
                root.Layout.minimumHeight = units.iconSizes.small;
                root.Layout.maximumHeight = inPanel ? units.iconSizeHints.panel : -1;
            }
        }
    }

    function updateButtonHeight(){
        if (root.showAllButtons){
            root.buttonHeight = vertical ? root.height : (root.height > units.iconSizes.smallMedium ? units.iconSizes.smallMedium + (root.height-units.iconSizes.smallMedium)/2 : root.height)
        }
        else{
            if(vertical)
                root.buttonHeight = root.height
            else
                root.buttonHeight = root.height > units.iconSizes.smallMedium ? units.iconSizes.smallMedium + (root.height-units.iconSizes.smallMedium)/2 : root.height
        }
    }
    Connections {
        target: units.iconSizeHints
        onPanelChanged: updateSizeHints()
    }

    Rectangle {
        id: rectForm
        default property alias data: grid.data
        width:  vertical ? root.width : root.width-units.smallSpacing*2;
        height: vertical ? root.height : (root.height > units.iconSizes.smallMedium ? units.iconSizes.smallMedium + (root.height-units.iconSizes.smallMedium)/2 : root.height)
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter : parent.horizontalCenter
        
        //radius: (width <=units.iconSizes.smallMedium || height <= units.iconSizes.smallMedium) ? 5 : 12 //TODO: FIXME
        radius: (width < 24 || height <= 24) ? 5 : 12
        color: plasmoid.configuration.backgroundPanelCheckBox ?  "transparent" : "#AA000000" //TODO: put color in settings (dark theme)
        Grid {
            id: grid
            columns: vertical ? 1 : (root.showAllButtons ? 3 : 1)
            rows:    vertical ? (root.showAllButtons ? 3 : 1) : 1
            columnSpacing: root.columnSpacing
            rowSpacing:    root.rowSpacing
            anchors.centerIn: rectForm

            Item{
                height: root.buttonHeight > units.iconSizes.smallMedium ? units.iconSizes.smallMedium : root.buttonHeight
                width:  height
                PlasmaCore.IconItem{
                    id: buttonIcon
                    implicitHeight: root.buttonHeight > units.iconSizes.smallMedium ? units.iconSizes.smallMedium : root.buttonHeight
                    width:  height
                    source: {
                        if(useCustomButtonImage){
                            return plasmoid.configuration.customButtonImage
                        }
                        else{
                            return plasmoid.configuration.iconsDarkThemeCheckBox ? Qt.resolvedUrl("assets/grid_black.svg") : Qt.resolvedUrl("assets/grid.svg");
                        }
                    }
                    onSourceChanged: updateSizeHints()
                    smooth: true
                    visible: false

                }
                ColorOverlay {
                    anchors.fill: buttonIcon
                    source:       buttonIcon
                    color:        plasmoid.configuration.overlayColorCheckBox ? plasmoid.configuration.overlayColor : "#00000000"
                }
                MouseArea
                {
                    id: mouseArea
                    property bool wasExpanded: false;
                    anchors.fill: parent
                    hoverEnabled: !dashWindow || !dashWindow.visible
                    onPressed: {
                        if (!isDash) {
                            wasExpanded = plasmoid.expanded
                        }
                    }
                    onClicked: {
                        if (isDash) {
                            dashWindow.toggle();
                            justOpenedTimer.start();
                        } else {
                            plasmoid.expanded = !wasExpanded;
                        }
                    }
                }
            }


            PlasmaCore.IconItem {
                id: buttonIcon2
                visible: plasmoid.configuration.showAllButtonsCheckBox
                implicitHeight: root.buttonHeight > units.iconSizes.smallMedium ? units.iconSizes.smallMedium : root.buttonHeight
                width:  height
                source: plasmoid.configuration.iconsDarkThemeCheckBox ? Qt.resolvedUrl("assets/desktop_black.svg") : Qt.resolvedUrl("assets/desktop.svg");
                active: mouseArea.containsMouse && !justOpenedTimer.running
                smooth: true
                onSourceChanged: updateSizeHints()
                MouseArea {
                    anchors.fill: parent
                    onClicked: showdesktop.showingDesktop = !showdesktop.showingDesktop
                }
            }

            PlasmaCore.IconItem {
                id: buttonIcon3
                visible: plasmoid.configuration.showAllButtonsCheckBox
                implicitHeight: root.buttonHeight > units.iconSizes.smallMedium ? units.iconSizes.smallMedium : root.buttonHeight
                width:  height
                source: plasmoid.configuration.iconsDarkThemeCheckBox ? Qt.resolvedUrl("assets/expose_black.svg") : Qt.resolvedUrl("assets/expose.svg");
                active: mouseArea.containsMouse && !justOpenedTimer.running
                smooth: true
                onSourceChanged: updateSizeHints()
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        exposeDesktop()
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        if (isDash) {
            dashWindow = Qt.createQmlObject("DashboardRepresentation {}", root);
            plasmoid.activated.connect(function() {
                dashWindow.toggle()
                justOpenedTimer.start()
            })
        }
        updateButtonHeight()
    }
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }
    function exposeDesktop() {
        executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Expose"')
    }
}
