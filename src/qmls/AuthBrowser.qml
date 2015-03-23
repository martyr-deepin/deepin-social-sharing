import QtQuick 2.2
import QtWebKit 3.0
import Deepin.Widgets 1.0
import QtGraphicalEffects 1.0

SlideInOutItem {
    id: root
    width: 300
    height: 300

    property alias radius: browser_area.radius
    property alias window: titlebar.window
    property var currentBrowser: browser_one

    property bool canSkip: false

    signal backButtonClicked()
    signal closeButtonClicked()
    signal skipped(string accountType)
    signal urlChanged(string accountType, string url)

    function next() {
        if (root.currentBrowser == browser_one) {
            root.currentBrowser = browser_two
            browser_one.leftOut()
            browser_two.rightIn()
        } else if (root.currentBrowser == browser_two) {
            root.currentBrowser = browser_one
            browser_two.leftOut()
            browser_one.rightIn()
        }
    }

    function setAccountType(accountType) {
        root.currentBrowser.accountType = accountType
    }

    // pass a empty string to setUrl means that the manager can't get
    // an authorizing url for the browser, in other words it's a error.
    function setUrl(url) {
        fake_reload_timer.stop()

        if (url) {
            root.currentBrowser.url = url
            error_warning.visible = false
        } else {
            error_warning.visible = true
        }
    }

    function reset() {
        root.currentBrowser = browser_one
        browser_one.x =  0
        browser_one.visible = true
        browser_one.url = "about:blank"
        browser_one.accountType = ""
        browser_two.visible = false
        browser_two.url = "about:blank"
        browser_two.accountType = ""
    }

    Rectangle {
        id: browser_area
        color: "white"
        anchors.fill: parent

        SlideInOutItem {
            id: browser_one
            width: parent.width
            height: parent.height

            property alias url: webview_one.url
            property string accountType: ""

            WebView {
                id: webview_one
                anchors.fill: parent

                onNavigationRequested: root.urlChanged(browser_one.accountType, request.url)

                Rectangle {
                    width: Math.max(20, parent.width * webview_one.loadProgress / 100)
                    height: 2
                    color: "#00A2FF"
                    visible: webview_one.loadProgress != 100

                    anchors.bottom: parent.bottom
                }
            }

            WhiteButton {
                label: dsTr("Skip")
                visible: root.canSkip
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 10

                onClicked: root.skipped(browser_one.accountType)
            }
        }

        SlideInOutItem {
            id: browser_two
            visible: false
            width: parent.width
            height: parent.height

            property alias url: webview_two.url
            property string accountType: ""

            WebView {
                id: webview_two
                anchors.fill: parent

                onNavigationRequested: root.urlChanged(browser_two.accountType, request.url)

                Rectangle {
                    width: Math.max(20, parent.width * webview_two.loadProgress / 100)
                    height: 2
                    color: "#00A2FF"
                    visible: webview_two.loadProgress != 100

                    anchors.bottom: parent.bottom
                }
            }

            WhiteButton {
                label: dsTr("Skip")
                visible: root.canSkip
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 10

                onClicked: root.skipped(browser_two.accountType)
            }
        }

        DDragableArea {
            id: titlebar
            width: root.width
            height: close_button.height

            Text {
                id: titlebar_title
                color: "white"
                font.pixelSize: 10
                width: Math.min(parent.width - 40, implicitWidth)
                anchors.verticalCenter: close_button.verticalCenter
                anchors.horizontalCenter: titlebar.horizontalCenter
            }

            DImageButton {
                id: close_button
                normal_image: "../../images/window_close_normal.png"
                hover_image: "../../images/window_close_hover.png"
                press_image: "../../images/window_close_press.png"
                anchors.top: parent.top
                anchors.right: parent.right

                onClicked: root.closeButtonClicked()
            }
        }
    }

    Rectangle {
        id: mask
        radius: root.radius
        anchors.fill: browser_area
    }

    OpacityMask {
        anchors.fill: browser_area
        source: ShaderEffectSource { sourceItem: browser_area; hideSource: true }
        maskSource: mask
    }

    DImageButton {
        id: back_button
        drawBackground: true
        lightVersion: true
        normal_image: "../../images/light_back_normal.png"
        hover_image: "../../images/light_back_hover.png"
        press_image: "../../images/light_back_press.png"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.leftMargin: 5

        onClicked: root.backButtonClicked()
    }

    Timer {
        id: fake_reload_timer
        interval: 500
        onTriggered: {
            error_warning.visible = true
            loading.visible = Qt.binding(function() {
                return (webview_one.loading || webview_two.loading) && !(error_warning.visible)
            })
        }
    }

    Column {
        id: error_warning
        width: 100
        visible: false
        anchors.centerIn: parent

        Image {
            source: "../../images/unable_to_load.png"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item { width: 1; height: 20 }

        Text {
            text: dsTr("Unable to connect to %1").arg(root.currentBrowser.accountType)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        LinkButton {
            label: dsTr("Reload")
            onClicked: {
                // the unable to load page errors are most likely caused by
                // the fact that no url is set to the webview, and  it's
                // non-sense to reload the page, so I just faked the reload effect.
                error_warning.visible = false
                loading.visible = true
                fake_reload_timer.start()
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    LoadingAnimation {
        id: loading
        visible: (webview_one.loading || webview_two.loading) && !(error_warning.visible)
        anchors.centerIn: parent
    }
}
