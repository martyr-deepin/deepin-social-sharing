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

    signal urlChanged(string url)

    function next() {
        if (root.currentBrowser == browser_one) {
            browser_one.leftOut()
            browser_two.rightIn()
            root.currentBrowser = browser_two
        } else if (root.currentBrowser == browser_two) {
            browser_two.leftOut()
            browser_one.rightIn()
            root.currentBrowser = browser_one
        }
    }

    function setUrl(url) {
        browser_one.url = url
        browser_two.url = url
    }

    Rectangle {
        id: browser_area
        color: "white"
        anchors.fill: parent

        SlideInOutItem {
            id: browser_one
            visible: true

            property alias url: webview_one.url

            anchors.fill: parent

            WebView {
                id: webview_one
                experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
                anchors.fill: parent

                onLoadingChanged: root.urlChanged(loadRequest.url)
            }
        }

        SlideInOutItem {
            id: browser_two
            visible: false
            property alias url: webview_two.url

            anchors.fill: parent

            WebView {
                id: webview_two
                experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
                anchors.fill: parent

                onLoadingChanged: root.urlChanged(loadRequest.url)
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
