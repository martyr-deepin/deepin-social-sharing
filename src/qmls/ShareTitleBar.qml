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
