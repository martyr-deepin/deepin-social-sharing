import QtQuick 2.1
import Deepin.Widgets 1.0

Item {
    id: root
    width: 300
    height: 36
    state: "first_time"

    property alias wordsLeft: word_number_label.text

    signal accountSelected(string accountType)
    signal accountDeselected(string accountType)
    signal nextButtonClicked()
    signal shareButtonClicked()
    signal okButtonClicked()

    states: [
        State {
            name: "first_time"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: plz_choose_sns_label; visible: false }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: true }
            PropertyChanges { target: next_button; visible: true }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: false }
        },
        State {
            name: "accounts_list"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: plz_choose_sns_label; visible: true }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
        },
        State {
            name: "share"

            PropertyChanges { target: row; visible: true }
            PropertyChanges { target: plz_choose_sns_label; visible: false }
            PropertyChanges { target: accounts_management_label; visible: false }
            PropertyChanges { target: word_number_label; visibleFlag: true }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: true }
            PropertyChanges { target: ok_button; visible: false }
        },
        State {
            name: "accounts_manage"

            PropertyChanges { target: row; visible: false }
            PropertyChanges { target: plz_choose_sns_label; visible: false }
            PropertyChanges { target: accounts_management_label; visible: true }
            PropertyChanges { target: word_number_label; visibleFlag: false }
            PropertyChanges { target: next_button; visible: false }
            PropertyChanges { target: share_button; visible: false }
            PropertyChanges { target: ok_button; visible: true }
        }
    ]

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
        anchors.leftMargin: 5

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
        id: plz_choose_sns_label
        text: dsTr("Please choose platforms")
        color: "#b4b4b4"
        font.pixelSize: 11
        visible: false

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: accounts_management_label
        text: dsTr("Accounts management")
        color: "#b4b4b4"
        font.pixelSize: 11
        visible: false

        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: word_number_label
        visible: !word_number_overflow_label.visible
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
        text: dsTr("Words limit has been exceeded.")
        color: word_number_label.color
        font.pixelSize: word_number_label.font.pixelSize

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