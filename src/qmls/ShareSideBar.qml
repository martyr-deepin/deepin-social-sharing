import QtQuick 2.1
import QtQuick.Layouts 1.1
import Deepin.Widgets 1.0

Rectangle {
    id: share_platform_em
    width: 150
    height: 300
    state: "first time"
    color: "transparent"

    property var column: column
    property var emojiLook: emojiLook
    property var emojiFaceText: emojiLook.imageText
    property url emojiFaceDir: "../../images/emoji/*.png"
    property bool shareEnabled: true
    property bool sinaweiboCheckBoxVisible: false
    property bool twitterCheckBoxVisible: false
    property bool sinaweiboCheckBoxChecked: false
    property bool twitterCheckBoxChecked: false

    signal accountSelected(string accountType)
    signal accountDeselected(string accountType)
    signal accountManageButtonClicked()
    signal emojiFaceAdd(string imgText)

    states: [
        State {
            name: "first_time"
            PropertyChanges { target: column; visible: false }
            PropertyChanges { target: account_manage_button; visible: false }
            PropertyChanges { target: emojiLook; visible: false }
        },
        State {
            name: "accounts_list"
            PropertyChanges { target: column; visible: false }
            PropertyChanges { target: account_manage_button; visible: false }
            PropertyChanges { target: emojiLook; visible: false }
        },

        State {
            name: "share_face"
            PropertyChanges { target: column; visible: false }
            PropertyChanges { target: account_manage_button; visible: false }
            PropertyChanges { target: emojiLook; visible: true }
        },
        State {
            name: "share"
            PropertyChanges { target: column; visible: true }
            PropertyChanges { target: account_manage_button; visible: true }
            PropertyChanges { target: emojiLook; visible: false }
        },
        State {
            name: "accounts_manage"
            PropertyChanges { target: column; visible: false }
            PropertyChanges { target: account_manage_button; visible: false }
            PropertyChanges { target: emojiLook; visible: false }
        }
    ]

    function anyPlatform() {
        return (sinaweiboCheckBoxVisible && sinaweibo_checkbox.checked)
               || (twitterCheckBoxVisible && twitterCheckBoxChecked)
    }

    function lightUpIcons(filterMap) {
        sinaweiboCheckBoxVisible = filterMap.indexOf("sinaweibo") != -1
        sinaweibo_checkbox.checked = filterMap.indexOf("sinaweibo") != -1
        twitterCheckBoxVisible = filterMap.indexOf("twitter") != -1
        twitterCheckBoxChecked = filterMap.indexOf("twitter") != -1
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.top: parent.top
        anchors.topMargin: 40
        visible: false
        spacing: 5

        DImageCheckBox {
            id: sinaweibo_checkbox
            visible: column.visible && sinaweiboCheckBoxVisible
            imageSource :"../../images/sinaweibo_small.png"

            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: checked ? share_platform_em.accountSelected("sinaweibo") : share_platform_em.accountDeselected("sinaweibo")
        }

        DImageCheckBox {
            id: twitter_checkbox
            visible: column.visible && twitterCheckBoxVisible
            imageSource :"../../images/twitter_small.png"

            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: checked ? share_platform_em.accountSelected("twitter") : share_platform_em.accountDeselected("twitter")
        }
    }
    LinkButton {
        id: account_manage_button
        label: dsTr("Account management")
        font.pixelSize: 11
        visible: column.visible
        anchors.top: column.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter

        onClicked: share_platform_em.accountManageButtonClicked()
    }

    EmojiFaceView {
        id: emojiLook
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 20
        width: parent.width - 6
        visible: false
        share_platform: share_platform_em
        onEmojiFaceClicked: {
            share_platform_em.emojiFaceAdd(imgText)
        }
    }
    DSeparatorVertical {
        id: separatorLine
        anchors.right: parent.right
        anchors.rightMargin: 5
        height: parent.height + 40
        visible: share_platform_em.visible
    }
}

