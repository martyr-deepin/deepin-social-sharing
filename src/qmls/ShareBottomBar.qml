import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: root
    width: 300
    height: 36
    state: "first_time"

    property alias wordsLeft: word_number_label.text

    property bool shareEnabled: true

    signal accountSelected(string accountType)
    signal accountDeselected(string accountType)
    signal nextButtonClicked()
    signal shareButtonClicked()
    signal okButtonClicked()
    signal backButtonClicked()

    states: [
        State {
            name: "first_time"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: true }
            PropertyChanges { target: next_button; visible: true }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: back_button; visible: false }
        },
        State {
            name: "accounts_list"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: back_button; visible: true }
        },
        State {
            name: "share"

            PropertyChanges { target: row; visible: true }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: true }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
            PropertyChanges { target: back_button; visible: false }
        },
        State {
            name: "accounts_manage"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: accounts_management_label; visible: true }
            PropertyChanges { target: word_number_label; visibleFlag: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: true }
            PropertyChanges { target: back_button; visible: false }
        }
    ]

    function anyPlatform() {
        return (sinaweibo_checkbox.visible && sinaweibo_checkbox.checked)
               || (twitter_checkbox.visible && twitter_checkbox.checked)
    }

    function lightUpIcons(filterMap) {
        sinaweibo_checkbox.visible = filterMap.indexOf("sinaweibo") != -1
        sinaweibo_checkbox.checked = filterMap.indexOf("sinaweibo") != -1
        twitter_checkbox.visible = filterMap.indexOf("twitter") != -1
        twitter_checkbox.checked = filterMap.indexOf("twitter") != -1
    }

    function warnWordsCount() {
        word_number_overflow_label.visible = true
    }

    function showWordsCount() {
        word_number_overflow_label.visible = false
    }

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

        DImageCheckBox {
            id: sinaweibo_checkbox
            visible: false
            imageSource :"../../images/sinaweibo_small.png"

            anchors.verticalCenter: parent.verticalCenter

            onClicked: checked ? root.accountSelected("sinaweibo") : root.accountDeselected("sinaweibo")
        }

        DImageCheckBox {
            id: twitter_checkbox
            visible: false
            imageSource :"../../images/twitter_small.png"

            anchors.verticalCenter: parent.verticalCenter

            onClicked: checked ? root.accountSelected("twitter") : root.accountDeselected("twitter")
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
        visible: !word_number_overflow_label.visible && root.shareEnabled && visibleFlag
        color: "#FDA825"
        font.pixelSize: 11

        property bool visibleFlag: true

        anchors.right: next_button.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: word_number_overflow_label
        visible: false
        text: dsTr("The input content is more than maximum words.")
        color: word_number_label.color
        font.pixelSize: word_number_label.font.pixelSize

        anchors.right: next_button.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    DImageButton {
        id: back_button
        drawBackground: true
        normal_image: "../../images/back_normal.png"
        hover_image: "../../images/back_hover.png"
        press_image: "../../images/back_press.png"

        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        onClicked: root.backButtonClicked()
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