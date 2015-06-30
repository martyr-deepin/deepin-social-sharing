import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DComboBox {
    id: root
    signal newAccount()
    signal removeAccount(int index)

    itemDelegate: Item {
        id: wrapper

        height: 26
        layer.enabled: true

        // Properties that DComboBox.itemDelegate should provide.
        property int index
        property var value
        property bool itemOnHover

        property bool canDelete: wrapper.index != root.labels.length - 1

        Rectangle {
            color: wrapper.itemOnHover ? DPalette.popupMenuObj.hoverBgColor
                                       : DPalette.popupMenuObj.normalBgColor
            anchors.fill: parent
        }

        DssH2 {
            id: label
            text: wrapper.value
            color: wrapper.itemOnHover ? DPalette.activeColor
                                       : DPalette.fgColor

            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
        }

        DImageButton {
            visible: wrapper.canDelete
            normal_image: "../../images/clear_content_normal.png"
            hover_image: "../../images/clear_content_hover.png"
            press_image: "../../images/clear_content_press.png"

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            onEntered: wrapper.itemOnHover = true
            onExited: wrapper.itemOnHover = false

            onClicked: {
                root.hideMenu()
                root.removeAccount(index)
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: wrapper.index == root.labels.length - 1

            onClicked: {
                root.hideMenu()
                root.newAccount()
            }
        }
    }
}