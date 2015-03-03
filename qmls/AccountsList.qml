import QtQuick 2.1
import QtGraphicalEffects 1.0

SlideInOutItem {
    id: root

    signal accountSelected(string accountType)
    signal accountDeselected(string accountType)

    ListView {
        id: list_view
        width: parent.width
        height: parent.height

        highlight: Rectangle {
            clip: true

            RadialGradient {
                width: parent.width
                height: parent.height + 20
                verticalOffset: - height / 2

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.0) }
                }
            }
        }
        delegate: Item {
            id: delegate_item
            width: ListView.view.width
            height: banner.implicitHeight

            property bool itemSelected: false

            Image {
                id: check_mark
                visible: itemSelected
                source: "../images/account_select_flag.png"
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: banner
                source: imageSource
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent

                onEntered: delegate_item.ListView.view.currentIndex = index
                onExited: delegate_item.ListView.view.currentIndex = -1

                onClicked: {
                    if (itemSelected) {
                        root.accountDeselected(itemName)
                        itemSelected = false
                    } else {
                        root.accountSelected(itemName)
                        itemSelected = true
                    }
                }
            }
        }
        model: ListModel{
            ListElement {
                itemName: "sinaweibo"
                imageSource: "../images/account_banner_sinaweibo.png"
            }
            ListElement {
                itemName: "twitter"
                imageSource: "../images/account_banner_twitter.png"
            }
        }
    }
}