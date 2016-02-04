/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.2
import Deepin.Widgets 1.0

Item {
    id: root
    width: 300
    height: 30

    property bool canGoBack: true
    property var shareSideBar
    signal backButtonClicked()

    DImageButton {
        id: back_button
        visible: root.canGoBack
        normal_image: "../../images/back_normal.png"
        hover_image: "../../images/back_hover.png"
        press_image: "../../images/back_press.png"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: shareSideBar.visible ? shareSideBar.width: 12

        onClicked: root.backButtonClicked()
    }
}
