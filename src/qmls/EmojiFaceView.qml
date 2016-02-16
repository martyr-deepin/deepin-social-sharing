/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.1
import Deepin.Widgets 1.0

Rectangle {
    id: emojiFace
    width: parent.width
    height: parent.height

    color: "transparent"
    visible: false
    property var share_platform
    property var emojiImage: _utils.emojiFaceInfoList(share_platform.emojiFaceDir)

    signal emojiFaceClicked(string imgText)

    function addquto(str) {
        var reg = /\.png$/
        reg = str.replace(reg,'')
        var showstr = _utils.facegetValue(reg)
        return "["+showstr+"]"
    }
    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.rightMargin: 12
        anchors.topMargin: 16
        color: "transparent"

        Component {
            id: appDelegate

            Item {
                width: 22
                height: 22

                Image {
                    id: myIcon
                    anchors.top: parent.top
                    anchors.left: parent.left
                    source: "../../images/selected_emoji/%1".arg(icon)


                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            var imgText = emojiFace.addquto(icon)
                            emojiFace.emojiFaceClicked(imgText)
                        }
                    }
                }
            }
        }


        GridView {
            id: gridView
            anchors.fill: parent
            anchors.topMargin: 3
            cellWidth: 22
            cellHeight: 22
            model: ListModel {}
            delegate: appDelegate
            boundsBehavior: Flickable.StopAtBounds
            Component.onCompleted: {
                for (var i=0; i<emojiImage.length; i++) {
                    model.append({"icon" : emojiImage[i] })
                }
            }
            DScrollBar {
               anchors.right: parent.right
               anchors.rightMargin: -6
               flickable: gridView
               inactiveColor: "grey"
            }
        }
    }
}
