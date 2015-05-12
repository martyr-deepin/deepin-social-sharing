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

    Rectangle {
        id: rect
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        color: "transparent"

        Component {
            id: appDelegate

            Item {
                width: 24
                height: 24

                Image {
                    id: myIcon
                    anchors.centerIn: parent
                    anchors.margins: 2
                    source: "../../images/selected_emoji/%1".arg(icon)


                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            var imgText = "<img src='" + myIcon.source + "' />"
                            emojiFace.emojiFaceClicked(imgText)
                        }
                    }
                }
            }
        }


        GridView {
            id: gridView
            width: parent.width
            height: parent.height
            anchors.fill: parent
            cellWidth: 24
            cellHeight: 24
            model: ListModel {}
            delegate: appDelegate
            boundsBehavior: Flickable.StopAtBounds
            Component.onCompleted: {
                for (var i=0; i<emojiImage.length; i++) {
                    model.append({"icon" : emojiImage[i] })
                }
            }
            DScrollBar {
               flickable: gridView
               inactiveColor: "grey"
            }
        }
    }
}
