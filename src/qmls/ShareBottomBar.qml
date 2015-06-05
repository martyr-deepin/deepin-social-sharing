import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: root
    width: 300
    height: 36
    state: "first_time"

    property alias wordsLeft: word_number_label.text
    property bool shareEnabled: true
    property alias sharePlatFormButton: share_paltform
    property alias shareFaceButton: share_face
    signal nextButtonClicked()
    signal shareButtonClicked()
    signal okButtonClicked()
    signal emojiFaceAdd()
    signal sharePlatFormSelected()
    signal shareEmojiFaceSelected()
    states: [
        State {
            name: "first_time"

            PropertyChanges { target: word_number_label; visible: true }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: next_button; visible: true }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: share_paltform; visible: false}
            PropertyChanges { target: share_face; visible: true}
        },
        State {
            name: "accounts_list"

            PropertyChanges { target: word_number_label; visible: false }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: share_paltform; visible: false}
            PropertyChanges { target: share_face; visible: false }
        },
        State {
            name: "share"

            PropertyChanges { target: word_number_label; visible: true }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: share_paltform; visible: true}
            PropertyChanges { target: share_face; visible: true }
        },
        State {
            name: "accounts_manage"

            PropertyChanges { target: word_number_label; visible: false }
            PropertyChanges { target: accounts_management_label; visible: true }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: true }
            PropertyChanges { target: share_paltform; visible: false}
            PropertyChanges { target: share_face; visible: false}
        }
    ]


    DSeparatorHorizontal {
        width: parent.width - 5 * 2

        anchors.top: parent.top
        anchors.topMargin: -5
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        id: row
        height: parent.height
        spacing: 10

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        function checkState(id) {
            for (var i=0;i<row.children.length;i++) {
                var childButton = row.children[i]
                if (childButton.imageName!=id.imageName) {
                    childButton.state = "off"
                }
            }
        }
        ToolButton {
            id: share_paltform
            imageName: "share"
            group: row
            onClicked: {
                root.sharePlatFormSelected()
            }
        }
        ToolButton {
            id: share_face
            imageName: "share_face"
            group: row
            onClicked: {
                root.shareEmojiFaceSelected()
            }
        }

    }


    Text {
        id: accounts_management_label
        text: dsTr("Account management")
        color: "#b4b4b4"
        font.pixelSize: 11
        visible: false

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: word_number_label
        color: "#FDA825"
        font.pixelSize: 11

        anchors.right: next_button.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    DTextButton {
        id: next_button
        text: dsTr("Next")
        visible: false

        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        onClicked: root.nextButtonClicked()
    }

    DTextButton {
        id: share_button
        text: dsTr("Share")
        enabled: root.shareEnabled
        opacity: enabled ? 1.0 : 0.5

        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        onClicked: root.shareButtonClicked()
    }

    DTextButton {
        id: ok_button
        text: dsTr("OK")
        visible: false

        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        onClicked: root.okButtonClicked()
    }
}
