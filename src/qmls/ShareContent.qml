/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.1
import QtQuick.Controls 1.2
import Deepin.Widgets 1.0
import QtGraphicalEffects 1.0

SlideInOutItem {
    id: root

    property alias wordCount: input_text.length
    property alias text: input_text.text
    property alias input_text: input_text
    property alias label_text: label.text
    property string screenshot

    property int inputLeftRightPadding: 24
    property var imageAreawidth
    property var imageAreaheight

    signal textOverflow()
    signal textInBounds()
    signal deleteOneEmojiFace()
    function setText(text) { input_text.text = text }

    function setScreenshot(source) { screenshot = source }
    function setImageSize(wid, het) {
        imageAreawidth = wid
        imageAreaheight = het
    }

    Rectangle {
        id: image_area
        width: imageAreawidth + 10
        height: imageAreaheight + 10

        anchors.top: parent.top
        anchors.topMargin: 20 + Math.max((root.height - input_area.height - imageAreaheight - 30) / 2 - 20, 0)
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Image {
            id: image
            source: root.screenshot
            fillMode: Image.PreserveAspectFit
            anchors.fill: image_frame
        }
        Rectangle {
            id: image_mask
            radius: image_frame.radius
            anchors.fill: image
        }
        OpacityMask {
            anchors.fill: image
            source: image
            maskSource: image_mask
        }

        Rectangle {
            id: image_frame
            width: parent.width - 10
            height: parent.height - 10
            color: "transparent"
            radius: 3
            border.width: 2
            border.color: Qt.rgba(1, 1, 1, 0.3)

            anchors.centerIn: parent
        }
    }

    DropShadow {
        anchors.fill: image_area
        horizontalOffset: 0
        verticalOffset: 1
        radius: 5
        samples: 16
        color: Qt.rgba(0, 0, 0, 0.5)
        source: image_area
    }

    Item {
        id: input_area
        width: root.width - root.inputLeftRightPadding * 2
        height: 70
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked:  {
                input_text.focus = true
                if (mouse.button == Qt.RightButton) {
                    input_text.paste()
                }
            }
        }

        TextEdit {
            id: input_text
            width: parent.width

            color: "#686868"
            font.pixelSize: 12
            wrapMode:TextEdit.Wrap
            selectByMouse: true
            selectionColor: "#276ea7"
            horizontalAlignment: TextEdit.AlignHCenter

            anchors.verticalCenter: parent.verticalCenter
            property string beforeChangedText: input_text.text
            property string changedText: ""
            onTextChanged: {
                changedText = input_text.text

                if (input_text.length > 140) {
                    input_text.remove(140, 141)
                    root.textOverflow()
                } else {
                    root.textInBounds()
                }
            }
            onFocusChanged: {
               label.text = ""
            }
        }

        Label {
            id: label
            visible: !input_text.focus
            text: dsTr("Input what you want to say")
            color: "#686868"
            font.pixelSize: input_text.font.pixelSize
            anchors.centerIn: parent
        }
    }
}
