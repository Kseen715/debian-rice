/***************************************************************************
 *   Copyright (C) 2015 by Eike Hein <hein@kde.org>                        *
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

import QtQuick 2.4
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kwindowsystem 1.0
import org.kde.plasma.private.shell 2.0

import org.kde.plasma.private.kicker 0.1 as Kicker

import QtQuick.Controls.Styles 1.4

import "code/tools.js" as Tools

/* TODO
 * Reverse middleRow layout + keyboard nav + filter list text alignment in rtl locales.
 * Keep cursor column when arrow'ing down past non-full trailing rows into a lower grid.
 * Make DND transitions cleaner by performing an item swap instead of index reinsertion.
*/

Kicker.DashboardWindow {
    id: root

    property bool smallScreen: false
    property int iconSize: smallScreen ? units.iconSizes.large : units.iconSizes.huge
    property int cellSize: iconSize + theme.mSize(theme.defaultFont).height
                           + (2 * units.smallSpacing)
                           + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                           highlightItemSvg.margins.left + highlightItemSvg.margins.right))
    //property int columns: ((Math.ceil(width / cellSize)+2*units.largeSpacing) * cellSize > width) ? (Math.floor(width / cellSize) - 1) : (Math.ceil(width / cellSize))   //Math.floor( 0.9 * )
    property int columns: ((Math.ceil(width / cellSize) * cellSize +2*units.largeSpacing) > width) ? (Math.floor(width / cellSize) - 1) : (Math.ceil(width / cellSize))
    property bool searching: (searchField.text != "")
    property var widgetExplorer: null



    keyEventProxy: searchField
    backgroundColor: "transparent"

    onKeyEscapePressed: {
        if (searching) {
            searchField.clear();
        } else {
            root.toggle();
        }
    }

    onVisibleChanged: {
        tabBar.activeTab = 0;
        reset();

        if (visible) {
            preloadAllAppsTimer.restart();
        }
    }

    onSearchingChanged: {
        if (!searching) {
            reset();
        } else {
            filterList.currentIndex = -1;

            if (tabBar.activeTab == 1) {
                widgetExplorer.widgetsModel.filterQuery = "";
                widgetExplorer.widgetsModel.filterType = "";
            }
        }
    }

    function reset() {
        searchField.clear();
        globalFavoritesGrid.currentIndex = -1;
        systemFavoritesGrid.currentIndex = -1;
        filterList.currentIndex = 0;
        funnelModel.sourceModel = rootModel.modelForRow(0);
        mainGrid.model = (tabBar.activeTab == 0) ? funnelModel : root.widgetExplorer.widgetsModel;
        mainGrid.currentIndex = -1;
        filterListScrollArea.focus = true;
        filterList.model = (tabBar.activeTab == 0) ? rootModel : root.widgetExplorer.filterModel;
    }

    function updateWidgetExplorer() {
        if (tabBar.activeTab == 1 /* Widgets */ || tabBar.hoveredTab == 1) {
            if (!root.widgetExplorer) {
                root.widgetExplorer = widgetExplorerComponent.createObject(root, {
                                                                               containment: containmentInterface.screenContainment(plasmoid)
                                                                           });
            }
        } else if (root.widgetExplorer) {
            root.widgetExplorer.destroy();
            root.widgetExplorer = null;
        }
    }

    mainItem: MouseArea {
        id: rootItem

        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        Connections {
            target: kicker

            onReset: {
                if (!searching) {
                    filterList.applyFilter();

                    if (tabBar.activeTab == 0) {
                        funnelModel.reset();
                    }
                }
            }

            onDragSourceChanged: {
                if (!dragSource) {
                    // FIXME TODO HACK: Reset all views post-DND to work around
                    // mouse grab bug despite QQuickWindow::mouseGrabberItem==0x0.
                    // Needs a more involved hunt through Qt Quick sources later since
                    // it's not happening with near-identical code in the menu repr.
                    rootModel.refresh();
                } else if (tabBar.activeTab == 1) {
                    root.toggle();
                    containmentInterface.ensureMutable(containmentInterface.screenContainment(plasmoid));
                    kwindowsystem.showingDesktop = true;
                }
            }
        }

        KWindowSystem {
            id: kwindowsystem
        }

        Component {
            id: widgetExplorerComponent

            WidgetExplorer { showSpecialFilters: false }
        }

        Connections {
            target: plasmoid
            onUserConfiguringChanged: {
                if (plasmoid.userConfiguring) {
                    root.hide()
                }
            }
        }

        PlasmaComponents.Menu {
            id: contextMenu

            PlasmaComponents.MenuItem {
                action: plasmoid.action("configure")
            }
        }

        PlasmaExtras.Heading {
            id: dummyHeading

            visible: false

            width: 0

            level: 1
        }

        PlasmaExtras.Heading {
            id: dummyHeading2

            visible: false

            width: 0

            level: 2
        }

        TextMetrics {
            id: headingMetrics

            font: dummyHeading.font
        }

        Kicker.FunnelModel {
            id: funnelModel

            onSourceModelChanged: {
                if (mainColumn.visible) {
                    mainGrid.currentIndex = -1;
                    mainGrid.forceLayout();
                }
            }
        }

        Timer {
            id: preloadAllAppsTimer

            property bool done: false

            interval: 1000
            repeat: false

            onTriggered: {
                if (done || searching) {
                    return;
                }

                for (var i = 0; i < rootModel.count; ++i) {
                    var model = rootModel.modelForRow(i);

                    if (model.description === "KICKER_ALL_MODEL") {
                        allAppsGrid.model = model;
                        done = true;
                        break;
                    }
                }
            }

            function defer() {
                if (running && !done) {
                    restart();
                }
            }
        }

        Kicker.ContainmentInterface {
            id: containmentInterface
        }

        DashboardTabBar {
            id: tabBar

            y: 0

            anchors.horizontalCenter: parent.horizontalCenter

            visible: (plasmoid.immutability !== PlasmaCore.Types.SystemImmutable)

            onActiveTabChanged: {
                updateWidgetExplorer();
                reset();
            }

            onHoveredTabChanged: updateWidgetExplorer()

            Keys.onDownPressed: {
                mainColumn.tryActivate(0, 0);
            }
        }

        TextEdit {
            id: searchField

            width: 0
            height: 0

            visible: false

            persistentSelection: true

            onTextChanged: {
                if (tabBar.activeTab == 0) {
                    runnerModel.query = searchField.text;
                } else {
                    widgetExplorer.widgetsModel.searchTerm = searchField.text;
                }
            }

            function clear() {
                text = "";
            }

            onSelectionStartChanged: Qt.callLater(searchHeading.updateSelection)
            onSelectionEndChanged: Qt.callLater(searchHeading.updateSelection)
        }

        Rectangle {
            anchors.fill: parent;
            visible: plasmoid.configuration.backgroundColorCheckBox
            color: plasmoid.configuration.backgroundColor
            opacity: 0.75
        }

        Image {
            id: mybackground
            visible: plasmoid.configuration.backgroundImageCheckBox
            anchors.fill: parent;
            source: plasmoid.configuration.backgroundImage
            fillMode: Image.PreserveAspectCrop;
        }
        
        ColorOverlay {
            id: eff1
            visible: plasmoid.configuration.backgroundImageCheckBox
            anchors.fill: mybackground
            source:       mybackground
            color: plasmoid.configuration.invertColors ? "#ccfcfcfc" : "#88000000"
            //cached: true TODO: put in settings
        }
        PlasmaComponents.TextField {
            id: textBox

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            y: Math.ceil((middleRow.anchors.topMargin / 2) - (smallScreen ? (height/10) : 0))
            width: 350
            horizontalAlignment: TextInput.Center
            LayoutMirroring.enabled: true
            textColor: plasmoid.configuration.invertColors ? "black" : "#f1f1f1"
            text: searching ? i18n("%1", searchField.text) : i18n("Search")
            smooth: true
            height: Math.ceil(dummyHeading2.font.pointSize*2.5)
            style: TextFieldStyle {
                font.pointSize: dummyHeading2.font.pointSize
                background: Rectangle {
                    radius: 8
                    color: "transparent"//plasmoid.configuration.invertColors ? "#f1f1f1" : "black"
                    opacity: 1
                }
            }
            layer.enabled: true
            layer.effect: DropShadow {
                verticalOffset: 1
                horizontalOffset: 1
                color: plasmoid.configuration.invertColors ? "#00000000" : "#aa000000"
                radius: 2
                samples: 5
            }
            opacity: root.visible ? 1.0 : 0.3
            Behavior on opacity { SmoothedAnimation { duration: units.longDuration*3; velocity: 0.01 } }
        }

        Rectangle {
            id: mySeparator1
            height: 1
            color: '#ff531f' //TODO: fix theme
            anchors {
                top:   textBox.bottom
                left:  textBox.left
                right: textBox.right
            }
        }

        //PlasmaCore.IconItem {
        Image {
            id: searchIcon
            height: units.iconSizes.medium//Math.ceil(textBox.height*0.75)
            width:  height
            source: Qt.resolvedUrl("assets/search32.svg");
            //source: "nepomuk" //TODO get main color from theme
            anchors.left: textBox.left
            anchors.leftMargin: 10
            anchors.verticalCenter: textBox.verticalCenter

        }

        TextEdit {
            id: searchHeading

            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            y: (middleRow.anchors.topMargin / 2) - (smallScreen ? (height/10) : 0)

            font.pointSize: dummyHeading.font.pointSize
            wrapMode: Text.NoWrap
            opacity: 1.0

            selectByMouse: false
            cursorVisible: false

            color: plasmoid.configuration.invertColors ? "black" : "#f1f1f1"
            text: searching ? i18n("'%1'", searchField.text) : i18n("Type to search...")

            function updateSelection() {
                if (!searchField.selectedText) {
                    return;
                }
                var delta = text.lastIndexOf(searchField.text, text.length - 2);
                searchHeading.select(searchField.selectionStart + delta, searchField.selectionEnd + delta);
            }
            visible: false
        }

        PlasmaComponents.ToolButton {
            id: cancelSearchButton

            anchors {
                right: textBox.right
                rightMargin: 10
                verticalCenter: textBox.verticalCenter
            }

            width: units.iconSizes.medium
            height: width

            visible: (searchField.text != "")

            iconName:  Qt.resolvedUrl("assets/clear.svg")
            flat: true

            onClicked: searchField.clear();

            Keys.onPressed: {
                if (event.key === Qt.Key_Tab) {
                    event.accepted = true;

                    if (runnerModel.count) {
                        mainColumn.tryActivate(0, 0);
                    } else {
                        systemFavoritesGrid.tryActivate(0, 0);
                    }
                } else if (event.key === Qt.Key_Backtab) {
                    event.accepted = true;

                    if (tabBar.visible) {
                        tabBar.focus = true;
                    } else if (globalFavoritesGrid.enabled) {
                        globalFavoritesGrid.tryActivate(0, 0);
                    } else {
                        systemFavoritesGrid.tryActivate(0, 0);
                    }
                }
            }
        }

        Row {
            id: middleRow

            width: (root.columns * cellSize) + 2*units.largeSpacing
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: units.gridUnit * (smallScreen ? 5 : 6)
                bottom: parent.bottom
                bottomMargin: (units.gridUnit * 2)
            }

            layoutDirection: Qt.RightToLeft
            spacing: units.largeSpacing
            

            Item {
                id: favoritesColumn

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                
                property int columns: 2
                width: (favoritesColumn.columns * cellSize) + units.gridUnit

                PlasmaExtras.Heading {
                    id: favoritesColumnLabel

                    enabled: (tabBar.activeTab == 0)

                    anchors {
                        top: parent.top
                    }

                    x: units.smallSpacing
                    width: parent.width - x

                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap

                    color: plasmoid.configuration.invertColors ? "black" : "#f1f1f1"

                    level: 2

                    text: i18n("Favorites")

                    opacity: (enabled ? 1.0 : 0.3)

                    Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 1
                        horizontalOffset: 1
                        color: plasmoid.configuration.invertColors ? "#00000000" : "#aa000000"
                        radius: 2
                        samples: 5
                    }
                }

                PlasmaCore.SvgItem {
                    id: favoritesColumnLabelUnderline

                    enabled: (tabBar.activeTab == 0)

                    anchors {
                        top: favoritesColumnLabel.bottom
                    }

                    width: parent.width - units.gridUnit
                    height: lineSvg.horLineHeight

                    svg: lineSvg
                    elementId: "horizontal-line"
                    visible: false

                    opacity: (enabled ? 1.0 : 0.3)

                    Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }
                }

                ItemGridView {
                    id: globalFavoritesGrid

                    enabled: (tabBar.activeTab == 0)

                    anchors {
                        top: favoritesColumnLabelUnderline.bottom
                        topMargin: units.largeSpacing
                    }

                    property int rows: (Math.floor((parent.height - favoritesColumnLabel.height
                                                    - favoritesColumnLabelUnderline.height - units.largeSpacing) / cellSize)
                                        - systemFavoritesGrid.rows)

                    width: parent.width
                    height: rows * cellSize

                    cellWidth: cellSize
                    cellHeight: cellSize
                    iconSize: units.iconSizes.large

                    model: globalFavorites
                    layoutDirection: Qt.RightToLeft
                    dropEnabled: true
                    usesPlasmaTheme: false

                    opacity: (enabled ? 1.0 : 0.3)

                    Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }

                    onCurrentIndexChanged: {
                        preloadAllAppsTimer.defer();
                    }

                    onKeyNavLeft: { //<>
                        mainColumn.tryActivate(currentRow(), 0);
                    }

                    onKeyNavDown: {
                        systemFavoritesGrid.tryActivate(0, currentCol());
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Tab) {
                            event.accepted = true;

                            if (tabBar.visible) {
                                // tabBar.focus = true;
                            } else if (searching) {
                                cancelSearchButton.focus = true;
                            } else {
                                mainColumn.tryActivate(0, 0);
                            }
                        } else if (event.key === Qt.Key_Backtab) {
                            event.accepted = true;
                            systemFavoritesGrid.tryActivate(0, 0);
                        }
                    }

                    Binding {
                        target: globalFavorites
                        property: "iconSize"
                        value: root.iconSize
                    }
                }
                Rectangle {
                    id: mySeparator
                    height: 1
                    color: '#dcdcdc'
                    anchors {
                        top:   globalFavoritesGrid.bottom
                        left:  globalFavoritesGrid.left
                        right: globalFavoritesGrid.right
                    }
                }

                ItemGridView {
                    id: systemFavoritesGrid

                    anchors {
                        
                        top: mySeparator.bottom
                        topMargin: 10
                        
                    }

                    property int rows: Math.ceil(count / Math.floor(width / cellSize))

                    width: parent.width
                    height: rows * cellSize

                    cellWidth: cellSize
                    cellHeight: cellSize
                    iconSize: units.iconSizes.large

                    model: systemFavorites

                    dropEnabled: true
                    usesPlasmaTheme: false
                    layoutDirection: Qt.RightToLeft

                    onCurrentIndexChanged: {
                        preloadAllAppsTimer.defer();
                    }

                    onKeyNavLeft: { //<>
                        mainColumn.tryActivate(globalFavoritesGrid.rows + currentRow(), 0);
                    }

                    onKeyNavUp: {
                        globalFavoritesGrid.tryActivate(globalFavoritesGrid.rows - 1, currentCol());
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Tab) {
                            event.accepted = true;

                            if (globalFavoritesGrid.enabled) {
                                globalFavoritesGrid.tryActivate(0, 0);
                            } else if (tabBar.visible) {
                                // tabBar.focus = true;
                            } else if (searching && !runnerModel.count) {
                                cancelSearchButton.focus = true;
                            } else {
                                mainColumn.tryActivate(0, 0);
                            }
                        } else if (event.key === Qt.Key_Backtab) {
                            event.accepted = true;

                            if (filterList.enabled) {
                                filterList.forceActiveFocus();
                            } else if (searching && !runnerModel.count) {
                                cancelSearchButton.focus = true;
                            } else {
                                mainColumn.tryActivate(0, 0);
                            }
                        }
                    }
                }
            }


            Item {
                id: mainColumn

                anchors.top: parent.top
                property int columns: root.columns - favoritesColumn.columns - filterListColumn.columns

                width: (mainColumn.columns* cellSize) //+ units.gridUnit
                height: Math.floor(parent.height / cellSize) * cellSize + mainGridContainer.headerHeight

                property Item visibleGrid: mainGrid

                function tryActivate(row, col) {
                    if (visibleGrid) {
                        visibleGrid.tryActivate(row, col);
                    }
                }


                Item {
                    id: mainGridContainer

                    anchors.fill: parent
                    z: (opacity == 1.0) ? 1 : 0

                    enabled: (opacity == 1.0) ? 1 : 0

                    property int headerHeight: mainColumnLabel.height + mainColumnLabelUnderline.height + units.largeSpacing

                    opacity: {
                        if (tabBar.activeTab == 0 && searching) {
                            return 0.0;
                        }

                        if (filterList.allApps) {
                            return 0.0;
                        }

                        return 1.0;
                    }

                    onOpacityChanged: {
                        if (opacity == 1.0) {
                            mainColumn.visibleGrid = mainGrid;
                        }
                    }

                    PlasmaExtras.Heading {
                        id: mainColumnLabel

                        anchors {
                            top: parent.top
                        }

                        x: units.smallSpacing
                        width: parent.width - x

                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                        opacity: 1.0

                        color: plasmoid.configuration.invertColors ? "black" : "#f1f1f1"

                        level: 2

                        text: (tabBar.activeTab == 0) ? funnelModel.description : i18n("Widgets")
                        layer.enabled: true
                        layer.effect: DropShadow {
                            verticalOffset: 1
                            horizontalOffset: 1
                            color: plasmoid.configuration.invertColors ? "#00000000" : "#aa000000"
                            radius: 2
                            samples: 5
                        }
                    }

                    PlasmaCore.SvgItem {
                        id: mainColumnLabelUnderline

                        visible: false//<>mainGrid.count

                        anchors {
                            top: mainColumnLabel.bottom
                        }

                        width: parent.width - units.gridUnit
                        height: lineSvg.horLineHeight

                        svg: lineSvg
                        elementId: "horizontal-line"
                    }

                    ItemGridView {
                        id: mainGrid

                        anchors {
                            top: mainColumnLabelUnderline.bottom
                            topMargin: units.largeSpacing
                        }

                        width: parent.width
                        height: systemFavoritesGrid.y + systemFavoritesGrid.height - mainGridContainer.headerHeight

                        cellWidth: (tabBar.activeTab == 0 ? cellSize : cellSize * 2)
                        cellHeight: cellWidth
                        iconSize: (tabBar.activeTab == 0 ? root.iconSize : cellWidth - (units.largeSpacing * 2))

                        model: funnelModel

                        onCurrentIndexChanged: {
                            preloadAllAppsTimer.defer();
                        }

                        onKeyNavRight: { //<>
                            if (tabBar.activeTab == 0) {
                                var row = currentRow();
                                var target = row + 1 > globalFavoritesGrid.rows ? systemFavoritesGrid : globalFavoritesGrid;
                                var targetRow = row + 1 > globalFavoritesGrid.rows ? row - globalFavoritesGrid.rows : row;
                                target.tryActivate(targetRow, favoritesColumn.columns - 1);
                            }
                        }

                        onKeyNavLeft: { //<>
                            filterListScrollArea.focus = true;
                        }

                        onKeyNavUp: { //<>
                            // if (tabBar.visible) {
                            // tabBar.focus = true;
                            // }
                        }

                        onItemActivated: {
                            if (tabBar.activeTab == 1) {
                                containmentInterface.ensureMutable(containmentInterface.screenContainment(plasmoid));
                                root.widgetExplorer.addApplet(currentItem.m.pluginName);
                                root.toggle();
                                kwindowsystem.showingDesktop = true;
                            }
                        }
                    }
                }

                ItemMultiGridView {
                    id: allAppsGrid

                    anchors {
                        top: parent.top
                    }

                    z: (opacity == 1.0) ? 1 : 0
                    width: parent.width
                    height: systemFavoritesGrid.y + systemFavoritesGrid.height

                    enabled: (opacity == 1.0) ? 1 : 0

                    opacity: filterList.allApps ? 1.0 : 0.0

                    onOpacityChanged: {
                        if (opacity == 1.0) {
                            allAppsGrid.flickableItem.contentY = 0;
                            mainColumn.visibleGrid = allAppsGrid;
                        }
                    }

                    onKeyNavRight: {//<>
                        var row = 0;

                        for (var i = 0; i < subGridIndex; i++) {
                            row += subGridAt(i).lastRow() + 2; // Header counts as one.
                        }

                        row += subGridAt(subGridIndex).currentRow();

                        var target = row + 1 > globalFavoritesGrid.rows ? systemFavoritesGrid : globalFavoritesGrid;
                        var targetRow = row + 1 > globalFavoritesGrid.rows ? row - globalFavoritesGrid.rows : row;
                        target.tryActivate(targetRow, favoritesColumn.columns - 1);
                    }

                    onKeyNavLeft: {//<>
                        filterListScrollArea.focus = true;
                    }
                }

                ItemMultiGridView {
                    id: runnerGrid

                    anchors {
                        top: parent.top
                    }

                    z: (opacity == 1.0) ? 1 : 0
                    width: parent.width
                    height: Math.min(implicitHeight, systemFavoritesGrid.y + systemFavoritesGrid.height)

                    enabled: (opacity == 1.0) ? 1 : 0

                    model: runnerModel

                    grabFocus: true

                    opacity: (tabBar.activeTab == 0 && searching) ? 1.0 : 0.0

                    onOpacityChanged: {
                        if (opacity == 1.0) {
                            mainColumn.visibleGrid = runnerGrid;
                        }
                    }

                    onKeyNavLeft: {
                        var row = 0;

                        for (var i = 0; i < subGridIndex; i++) {
                            row += subGridAt(i).lastRow() + 2; // Header counts as one.
                        }

                        row += subGridAt(subGridIndex).currentRow();

                        var target = row + 1 > globalFavoritesGrid.rows ? systemFavoritesGrid : globalFavoritesGrid;
                        var targetRow = row + 1 > globalFavoritesGrid.rows ? row - globalFavoritesGrid.rows : row;
                        target.tryActivate(targetRow, favoritesColumn.columns - 1);
                    }
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Tab) {
                        event.accepted = true;

                        if (filterList.enabled) {
                            filterList.forceActiveFocus();
                        } else {
                            systemFavoritesGrid.tryActivate(0, 0);
                        }
                    } else if (event.key === Qt.Key_Backtab) {
                        event.accepted = true;

                        if (searching) {
                            cancelSearchButton.focus = true;
                        } else if (tabBar.visible) {
                            tabBar.focus = true;
                        } else if (globalFavoritesGrid.enabled) {
                            globalFavoritesGrid.tryActivate(0, 0);
                        } else {
                            systemFavoritesGrid.tryActivate(0, 0);
                        }
                    }
                }
            }



            Item {
                id: filterListColumn
                anchors {
                    top: parent.top
                    topMargin: mainColumnLabelUnderline.y + mainColumnLabelUnderline.height + units.largeSpacing
                    bottom: parent.bottom
                }                

                property int columns: 2
                width: (filterListColumn.columns * cellSize)
                
                PlasmaExtras.ScrollArea {
                    id: filterListScrollArea

                    width: parent.width
                    height: mainGrid.height

                    enabled: !searching

                    property alias currentIndex: filterList.currentIndex

                    opacity: root.visible ? (searching ? 0.2 : 1.0) : 0.2

                    Behavior on opacity { SmoothedAnimation { duration: units.longDuration; velocity: 0.01 } }

                    verticalScrollBarPolicy: (opacity == 1.0) ? Qt.ScrollBarAsNeeded : Qt.ScrollBarAlwaysOff

                    onEnabledChanged: {
                        if (!enabled) {
                            filterList.currentIndex = -1;
                        }
                    }

                    onCurrentIndexChanged: {
                        focus = (currentIndex != -1);
                    }

                    ListView {
                        id: filterList

                        //anchors.margins: 10
                        
                        focus: true

                        property bool allApps: false
                        property int eligibleWidth: width
                        property int hItemMargins: Math.max(highlightItemSvg.margins.left + highlightItemSvg.margins.right,
                                                            listItemSvg.margins.left + listItemSvg.margins.right)

                        model: rootModel

                        boundsBehavior: Flickable.StopAtBounds
                        snapMode: ListView.SnapToItem
                        spacing: 0
                        keyNavigationWraps: true

                        delegate: MouseArea {
                            id: item

                            signal actionTriggered(string actionId, variant actionArgument)
                            signal aboutToShowActionMenu(variant actionMenu)

                            property var m: model
                            property int textWidth: label.contentWidth
                            property int mouseCol
                            property bool hasActionList: ((model.favoriteId !== null)
                                                          || (("hasActionList" in model) && (model.hasActionList === true)))
                            property Item menu: actionMenu

                            width: parent.width
                            height: Math.ceil((label.paintedHeight
                                               + Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                          listItemSvg.margins.top + listItemSvg.margins.bottom)) / 2) * 1.5//<>2

                            Accessible.role: Accessible.MenuItem
                            Accessible.name: model.display

                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            hoverEnabled: true

                            onContainsMouseChanged: {
                                if (!containsMouse) {
                                    updateCurrentItemTimer.stop();
                                }
                            }

                            onPositionChanged: { // Lazy menu implementation.
                                mouseCol = mouse.x;

                                if (justOpenedTimer.running || ListView.view.currentIndex === 0 || index === ListView.view.currentIndex) {
                                    updateCurrentItem();
                                } else if ((index == ListView.view.currentIndex - 1) && mouse.y < (height - 6)
                                           || (index == ListView.view.currentIndex + 1) && mouse.y > 5) {

                                    if (mouse.x > ListView.view.eligibleWidth - 5) {
                                        updateCurrentItem();
                                    }
                                } else if (mouse.x > ListView.view.eligibleWidth) {
                                    updateCurrentItem();
                                }

                                updateCurrentItemTimer.restart();
                            }

                            onPressed: {
                                if (mouse.buttons & Qt.RightButton) {
                                    if (hasActionList) {
                                        openActionMenu(item, mouse.x, mouse.y);
                                    }
                                }
                            }

                            onClicked: {
                                if (mouse.button == Qt.LeftButton) {
                                    updateCurrentItem();
                                }
                            }

                            onAboutToShowActionMenu: {
                                var actionList = hasActionList ? model.actionList : [];
                                Tools.fillActionMenu(i18n, actionMenu, actionList, ListView.view.model.favoritesModel, model.favoriteId);
                            }

                            onActionTriggered: {
                                if (Tools.triggerAction(ListView.view.model, model.index, actionId, actionArgument) === true) {
                                    plasmoid.expanded = false;
                                }
                            }

                            function openActionMenu(visualParent, x, y) {
                                aboutToShowActionMenu(actionMenu);
                                actionMenu.visualParent = visualParent;
                                actionMenu.open(x, y);
                            }

                            function updateCurrentItem() {
                                ListView.view.currentIndex = index;
                                ListView.view.eligibleWidth = Math.min(width, mouseCol);
                            }

                            ActionMenu {
                                id: actionMenu

                                onActionClicked: {
                                    actionTriggered(actionId, actionArgument);
                                }
                            }

                            Timer {
                                id: updateCurrentItemTimer

                                interval: 50
                                repeat: false

                                onTriggered: parent.updateCurrentItem()
                            }

                            PlasmaExtras.Heading {
                                id: label

                                anchors {
                                    fill: parent
                                    leftMargin: highlightItemSvg.margins.left
                                    rightMargin: highlightItemSvg.margins.right
                                }

                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                                opacity: 1.0

                                color: plasmoid.configuration.invertColors ? "black" : "#f1f1f1"

                                level: 4

                                text: model.display
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    verticalOffset: 1
                                    horizontalOffset: 1
                                    color: plasmoid.configuration.invertColors ? "#00000000" : "#aa000000"
                                    radius: 2
                                    samples: 5
                                }
                            }
                        }

                        highlight: PlasmaComponents.Highlight {
                            anchors {
                                top: filterList.currentItem ? filterList.currentItem.top : undefined
                                left: filterList.currentItem ? filterList.currentItem.left : undefined
                                bottom: filterList.currentItem ? filterList.currentItem.bottom : undefined
                            }

                            opacity: filterListScrollArea.focus ? 1.0 : 0.7

                            width: (highlightItemSvg.margins.left
                                    + filterList.currentItem.textWidth
                                    + highlightItemSvg.margins.right
                                    + units.smallSpacing)

                            visible: filterList.currentItem
                        }

                        highlightFollowsCurrentItem: false
                        highlightMoveDuration: 0
                        highlightResizeDuration: 0

                        onCurrentIndexChanged: applyFilter()

                        onCountChanged: {
                            var width = 0;

                            for (var i = 0; i < rootModel.count; ++i) {
                                headingMetrics.text = rootModel.labelForRow(i);

                                if (headingMetrics.width > width) {
                                    width = headingMetrics.width;
                                }
                            }
                            filterListColumn.columns   = 2
                            //<>filterListColumn.columns = Math.ceil(width / cellSize);
                            //<>filterListScrollArea.width = width + hItemMargins;//<>+(units.gridUnit * 2);
                        }

                        function applyFilter() {
                            if (!searching && currentIndex >= 0) {
                                if (tabBar.activeTab == 1) {
                                    root.widgetExplorer.widgetsModel.filterQuery = currentItem.m.filterData;
                                    root.widgetExplorer.widgetsModel.filterType = currentItem.m.filterType;

                                    allApps = false;
                                    funnelModel.sourceModel = model;

                                    return;
                                }

                                if (preloadAllAppsTimer.running) {
                                    preloadAllAppsTimer.stop();
                                }

                                var model = rootModel.modelForRow(currentIndex);

                                if (model.description === "KICKER_ALL_MODEL") {
                                    allAppsGrid.model = model;
                                    allApps = true;
                                    funnelModel.sourceModel = null;
                                    preloadAllAppsTimer.done = true;
                                } else {
                                    funnelModel.sourceModel = model;
                                    allApps = false;
                                }
                            } else {
                                funnelModel.sourceModel = null;
                                allApps = false;
                            }
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Right) {
                                event.accepted = true;

                                var currentRow = Math.max(0, Math.ceil(currentItem.y / mainGrid.cellHeight) - 1);
                                //mainColumn.tryActivate(currentRow, mainColumn.columns - 1);
                                mainColumn.tryActivate(0, 0);
                            } else if (event.key === Qt.Key_Tab) {
                                event.accepted = true;
                                systemFavoritesGrid.tryActivate(0, 0);
                            } else if (event.key === Qt.Key_Backtab) {
                                event.accepted = true;
                                mainColumn.tryActivate(0, 0);
                            }
                        }
                    }
                }
            }






        }

        onPressed: {
            if (mouse.button == Qt.RightButton) {
                contextMenu.open(mouse.x, mouse.y);
            }
        }

        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                root.toggle();
            }
        }

        
        PlasmaCore.IconItem {

            anchors{
                top: parent.top
                topMargin: units.gridUnit
                rightMargin: units.gridUnit
                right: parent.right
            }
            implicitHeight: units.iconSizes.smallMedium
            width:          units.iconSizes.smallMedium
            source: plasmoid.configuration.invertColors ? Qt.resolvedUrl("assets/close_black.svg") : Qt.resolvedUrl("assets/close.svg");
            smooth: true
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.toggle();
                }
            }
        }
        
        Rectangle{

            id: myMenu

            anchors{
                bottomMargin: units.gridUnit//Math.floor(units.gridUnit * 0.5)
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                //                left: parent.left
                //                leftMargin: units.gridUnit*2
            }

            color: "transparent"//plasmoid.configuration.backgroundImageCheckBox ? "#AA000000" : "transparent" //TODO: put in settings
            // radius: 8

            property double iSize: units.iconSizes.smallMedium//units.iconSizes.medium//units.gridUnit*1.5
            property double iSpacing: units.gridUnit*3
            height: myMenu.iSize
            width: 3*iSize+(myMenu.iSpacing*3)

            opacity: root.visible ? 1.0 : 0
            Behavior on opacity { SmoothedAnimation { duration: units.longDuration*3; velocity: 0.01 } }

            Row{
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                spacing: myMenu.iSpacing

                PlasmaCore.IconItem {
                    id: buttonIcon
                    implicitHeight: myMenu.iSize
                    width:  implicitHeight
                    source: plasmoid.configuration.invertColors ? Qt.resolvedUrl("assets/grid_black.svg") : Qt.resolvedUrl("assets/grid.svg");
                    smooth: true



                    // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
                    // to be an icon and round it to the nearest icon size again to avoid scaling artifacts.
                    //roundToIconSize: true//!useCustomButtonImage || aspectRatio === 1
                    // onSourceChanged: updateSizeHints()
                    MouseArea
                    {
                        id: mouseArea
                        anchors.fill: buttonIcon
                        onClicked: {
                            root.toggle();
                        }
                    }
                }


                PlasmaCore.IconItem {
                    id: buttonIcon2
                    implicitHeight: myMenu.iSize
                    width:  implicitHeight
                    source: plasmoid.configuration.invertColors ? Qt.resolvedUrl("assets/desktop_black.svg") : Qt.resolvedUrl("assets/desktop.svg");
                    smooth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            showdesktop.showingDesktop = !showdesktop.showingDesktop
                            root.toggle();
                        }
                    }
                }

                PlasmaCore.IconItem {
                    id: buttonIcon3
                    implicitHeight: myMenu.iSize
                    width:  implicitHeight
                    source: plasmoid.configuration.invertColors ? Qt.resolvedUrl("assets/expose_black.svg") : Qt.resolvedUrl("assets/expose.svg");
                    smooth: true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            exposeDesktop()
                            root.toggle();
                        }
                    }
                }
            }
        }
    }
    function exposeDesktop() {
        console.log(root.columns)
        executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Expose"')
    }
}
