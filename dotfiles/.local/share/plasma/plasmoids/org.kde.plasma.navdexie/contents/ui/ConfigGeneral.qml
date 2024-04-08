/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
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
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.draganddrop 2.0 as DragDrop

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property bool isDash: (plasmoid.pluginName == "org.kde.plasma.kickerdash")

    property string cfg_icon: plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: plasmoid.configuration.customButtonImage

    property alias cfg_appNameFormat: appNameFormat.currentIndex
    property alias cfg_limitDepth: limitDepth.checked
    property alias cfg_alphaSort: alphaSort.checked

    property alias cfg_recentOrdering: recentOrdering.currentIndex
    property alias cfg_showRecentApps: showRecentApps.checked
    property alias cfg_showRecentDocs: showRecentDocs.checked
    property alias cfg_showRecentContacts: showRecentContacts.checked

    property alias cfg_useExtraRunners: useExtraRunners.checked
    property alias cfg_alignResultsToBottom: alignResultsToBottom.checked

    property alias  cfg_invertColors: invertColors.checked
    property alias  cfg_backgroundColorCheckBox: backgroundColorCheckBox.checked
    property string cfg_backgroundColor: colorRect.color// "black"

    property alias  cfg_overlayColorCheckBox: overlayColorCheckBox.checked
    property string cfg_overlayColor: colorRectPanel.color// "black"

    property alias  cfg_backgroundImageCheckBox: backgroundImageCheckBox.checked
    property string cfg_backgroundImage: backgroundImage.text
    property alias  cfg_backgroundPanelCheckBox: backgroundPanelCheckBox.checked
    property alias  cfg_iconsDarkThemeCheckBox: iconsDarkThemeCheckBox.checked

    property alias  cfg_showAllButtonsCheckBox: showAllButtonsCheckBox.checked



    ColumnLayout {
        anchors.left: parent.left

        RowLayout {
            spacing: units.smallSpacing

            Label {
                text: i18n("Icon:")
            }

            Button {
                id: iconButton
                Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
                Layout.maximumWidth: Layout.minimumWidth
                Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
                Layout.maximumHeight: Layout.minimumWidth

                DragDrop.DropArea {
                    id: dropArea

                    property bool containsAcceptableDrag: false

                    anchors.fill: parent

                    onDragEnter: {
                        // Cannot use string operations (e.g. indexOf()) on "url" basic type.
                        var urlString = event.mimeData.url.toString();

                        // This list is also hardcoded in KIconDialog.
                        var extensions = [".png", ".xpm", ".svg", ".svgz"];
                        containsAcceptableDrag = urlString.indexOf("file:///") === 0 && extensions.some(function (extension) {
                            return urlString.indexOf(extension) === urlString.length - extension.length; // "endsWith"
                        });

                        if (!containsAcceptableDrag) {
                            event.ignore();
                        }
                    }
                    onDragLeave: containsAcceptableDrag = false

                    onDrop: {
                        if (containsAcceptableDrag) {
                            // Strip file:// prefix, we already verified in onDragEnter that we have only local URLs.
                            iconDialog.setCustomButtonImage(event.mimeData.url.toString().substr("file://".length));
                        }
                        containsAcceptableDrag = false;
                    }
                }

                KQuickAddons.IconDialog {
                    id: iconDialog

                    function setCustomButtonImage(image) {
                        //cfg_customButtonImage = image || cfg_icon || "start-here-kde"
                        cfg_customButtonImage = image || Qt.resolvedUrl("assets/grid.svg")
                        cfg_useCustomButtonImage = true;
                    }

                    onIconNameChanged: setCustomButtonImage(iconName);
                }

                // just to provide some visual feedback, cannot have checked without checkable enabled
                checkable: true
                checked: dropArea.containsAcceptableDrag
                onClicked: {
                    checked = Qt.binding(function() { // never actually allow it being checked
                        return iconMenu.status === PlasmaComponents.DialogStatus.Open || dropArea.containsAcceptableDrag;
                    })

                    iconMenu.open(0, height)
                }

                PlasmaCore.FrameSvgItem {
                    id: previewFrame
                    anchors.centerIn: parent
                    imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
                               ? "widgets/panel-background" : "widgets/background"
                    width: units.iconSizes.large + fixedMargins.left + fixedMargins.right
                    height: units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                    PlasmaCore.IconItem {
                        anchors.centerIn: parent
                        width: units.iconSizes.large
                        height: width
                        //source: cfg_useCustomButtonImage ? cfg_customButtonImage : cfg_icon
                        source: cfg_useCustomButtonImage ? cfg_customButtonImage : Qt.resolvedUrl("assets/grid.svg")

                    }
                }
            }

            // QQC Menu can only be opened at cursor position, not a random one
            PlasmaComponents.ContextMenu {
                id: iconMenu
                visualParent: iconButton

                PlasmaComponents.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
                    icon: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                PlasmaComponents.MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                    icon: "edit-clear"
                    onClicked: {
                        cfg_useCustomButtonImage = false;
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")

            flat: true

            ColumnLayout {
                RowLayout {
                    Label {
                        text: i18n("Show applications as:")
                    }

                    ComboBox {
                        id: appNameFormat

                        Layout.fillWidth: true

                        model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
                    }
                }

                CheckBox {
                    id: limitDepth

                    visible: !isDash

                    text: i18n("Flatten menu to a single level")
                }

                CheckBox {
                    id: alphaSort

                    text: i18n("Sort alphabetically")
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Categories")

            flat: true

            ColumnLayout {
                RowLayout {
                    Label {
                        text: i18n("Show:")
                    }

                    ComboBox {
                        id: recentOrdering

                        Layout.fillWidth: true

                        model: [i18n("Recently used"), i18n("Often used")]
                    }
                }

                CheckBox {
                    id: showRecentApps

                    text: recentOrdering.currentIndex == 0
                          ? i18n("Show recent applications")
                          : i18n("Show often used applications")
                }

                CheckBox {
                    id: showRecentDocs

                    text: recentOrdering.currentIndex == 0
                          ? i18n("Show recent documents")
                          : i18n("Show often used documents")
                }

                CheckBox {
                    id: showRecentContacts

                    text: recentOrdering.currentIndex == 0
                          ? i18n("Show recent contacts")
                          : i18n("Show often used contacts")
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Search")

            flat: true

            ColumnLayout {
                CheckBox {
                    id: useExtraRunners

                    text: i18n("Expand search to bookmarks, files and emails")
                }

                CheckBox {
                    id: alignResultsToBottom

                    visible: !isDash

                    text: i18n("Align search results to bottom")
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Tweaks dashboard")

            flat: true

            ColumnLayout {
                Row{

                    spacing: units.smallSpacing
                    RadioButton {
                        id: backgroundColorCheckBox
                        text: i18n("Color background:")
                        checked: true//cfg_backgroundColor
                        onCheckedChanged: {
                            backgroundImageCheckBox.checked = !backgroundColorCheckBox.checked
                        }
                    }

                    Button {
                        id: colorButton
                        width:  24
                        height: 24
                        enabled:  backgroundColorCheckBox.checked
                        opacity: backgroundColorCheckBox.checked ? 1 : 0.5
                        text: i18n("    ")
                        Rectangle {
                            id: colorRect
                            anchors.fill: parent
                            border.color: "lightgray"
                            border.width: 1
                            radius: 4
                            color: cfg_backgroundColor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorDialog.open()
                        }
                    }

                    ColorDialog {
                        id: colorDialog
                        title: "Select Background Color"
                        currentColor: cfg_backgroundColor
                        onAccepted: {
                            cfg_backgroundColor = colorDialog.color
                        }
                    }
                }

                Row{
                    spacing: units.smallSpacing
                    RadioButton {
                        id: backgroundImageCheckBox
                        checked: !backgroundColorCheckBox.checked
                        text: i18n("Image background:")
                        onCheckedChanged: {
                            backgroundColorCheckBox.checked = !backgroundImageCheckBox.checked
                        }
                    }

                    TextField {
                        id: backgroundImage
                        placeholderText: "Select image"
                        text: cfg_backgroundImage
                        readOnly : true
                    }

                    Button {
                        id: imageButton
                        implicitWidth: height
                        PlasmaCore.IconItem {
                            anchors.fill: parent
                            source: "document-open-folder"
                            PlasmaCore.ToolTipArea {
                                anchors.fill: parent
                                subText: "Select image"
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {fileDialog.open() }
                        }
                    }
                    FileDialog {
                        id: fileDialog
                        selectMultiple : false
                        title: "Pick a image file"
                        nameFilters: [ "Image files (*.jpg *.png *.jpeg)", "All files (*)" ]
                        onAccepted: {
                            backgroundImage.text= fileDialog.fileUrls[0]
                            cfg_backgroundImage = backgroundImage.text
                        }
                    }
                }
                CheckBox {
                    id: invertColors
                    text: i18n("Dark labels")
                }
            }
        }
        GroupBox {
            Layout.fillWidth: true

            title: i18n("Tweaks panel")

            flat: true

            ColumnLayout {
                Row{
                    spacing: units.smallSpacing
                    RadioButton {
                        id: overlayColorCheckBox
                        text: i18n("Colorize icon app:")
                        checked: cfg_overlayColorCheckBox
                        onCheckedChanged: {
                            cfg_overlayColorCheckBox = overlayColorCheckBox.checked
                        }
                    }

                   Button {
                        id: colorButtonPanel
                        width:  24
                        height: 24
                        enabled: overlayColorCheckBox.checked
                        text: i18n("    ")
                        opacity: overlayColorCheckBox.checked ? 1 : 0.5

                        Rectangle {
                            id: colorRectPanel
                            anchors.fill: parent
                            border.color: "lightgray"
                            border.width: 1
                            radius: 4
                            color: cfg_overlayColor
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorOverlayDialog.open()
                        }
                    }

                    ColorDialog {
                        id: colorOverlayDialog
                        title: "Select Color"
                        currentColor: cfg_overlayColor
                        onAccepted: {
                            cfg_overlayColor = colorOverlayDialog.color
                        }
                    }
                }
                CheckBox {
                    id: showAllButtonsCheckBox
                    text: i18n("Show all buttons")
                }
                CheckBox {
                    id: backgroundPanelCheckBox
                    text: i18n("Transparent background")
                }
                CheckBox {
                    id: iconsDarkThemeCheckBox
                    text: i18n("Icons dark theme")
                }
            }
        }
    }
}
