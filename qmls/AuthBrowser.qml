import QtQuick 2.2
import QtWebKit 3.0
import QtGraphicalEffects 1.0
import QtWebKit.experimental 1.0

SlideInOutItem {
    id: root
    width: 300
    height: 300

    property alias radius: browser_area.radius
    property var currentBrowser: browser_one

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

    function setUrl(url) {
        root.currentBrowser.url = url
    }

    function reset() {
        webview_one.stop()
        webview_two.stop()

        root.currentBrowser = browser_one
        browser_one.x =  0
        browser_one.visible = true
        browser_one.url = ""
        browser_one.accountType = ""
        browser_two.visible = false
        browser_two.url = ""
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
            property string accountType

            WebView {
                id: webview_one
                experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
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
                label: "Skip"
                visible: webview_one.loadProgress == 100
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
            property string accountType

            WebView {
                id: webview_two
                experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
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
                label: "Skip"
                visible: webview_two.loadProgress == 100
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 10

                onClicked: root.skipped(browser_two.accountType)
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
}
