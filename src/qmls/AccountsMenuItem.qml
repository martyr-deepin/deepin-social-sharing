import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: wrapper
    width: wrapper.ListView.view.width; height: 26

    signal clear()
    signal selectAction(int index)

    property alias text: label.text
    property bool canDelete: true
    property bool itemOnHover: false    //use wrapper.ListView.view.currentIndex to record index may cause crash,like deepin-movie font-list

    Rectangle {
        color: itemOnHover ? "#141414" : "#232323"
        anchors.fill: parent
    }

    DssH2 {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        text: "text " + index
        color: itemOnHover ? DConstants.activeColor : DConstants.fgColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered:{
            itemOnHover = true
        }
        onExited: {
            itemOnHover = false
        }
        onClicked: selectAction(index)
    }

    DImageButton {
        visible: wrapper.canDelete
        normal_image: "../../images/clear_content_normal.png"
        hover_image: "../../images/clear_content_hover.png"
        press_image: "../../images/clear_content_press.png"

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        onClicked: wrapper.clear()
    }
}

