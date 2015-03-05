import QtQuick 2.1
import QtQuick.Controls 1.2
import Deepin.Widgets 1.0
import QtGraphicalEffects 1.0

SlideInOutItem {
    id: root

    property alias wordCount: input_text.length
    property alias text: input_text.text
    property string screenshot

    property int inputLeftRightPadding: 24

    signal textOverflow()
    signal textInBounds()

    function setText(text) {
        input_text.text = text
    }

    function setScreenshot(source) {
        screenshot = source
    }

    TextEdit {
        id: input_text

        height: 70
        color: "#686868"
        font.pixelSize: 12
        wrapMode:TextEdit.Wrap
        selectByMouse: true
        selectionColor: "#276ea7"
        horizontalAlignment: TextEdit.AlignHCenter
        verticalAlignment: TextEdit.AlignVCenter

        anchors.left: parent.left
        anchors.leftMargin: root.inputLeftRightPadding
        anchors.right: parent.right
        anchors.rightMargin: root.inputLeftRightPadding

        onTextChanged: {
            if (input_text.length > 140) {
                input_text.remove(140, 141)
                root.textOverflow()
            } else {
                root.textInBounds()
            }
        }

        Label {
            id: label
            visible: !input_text.focus && !input_text.text
            text: "在此输入想说的话"
            color: "#686868"
            font.pixelSize: input_text.font.pixelSize
            anchors.centerIn: parent
        }
    }

    DSeparatorHorizontal {
        id: separate_line
        width: parent.width - root.inputLeftRightPadding * 2
        anchors.top: input_text.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
        id: image_area
        width: 110
        height: 110

        anchors.top: separate_line.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: image
            source: root.screenshot
            fillMode: Image.PreserveAspectCrop
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
            width: 100
            height: 100
            color: "transparent"
            radius: 3
            border.width:2
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
}
