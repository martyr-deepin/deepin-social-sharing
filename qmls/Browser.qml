import QtQuick 2.2
import QtWebKit 3.0
import QtQuick.Window 2.1
import QtWebKit.experimental 1.0

Window {
    id: root
    width: 800
    height: 500

    signal urlChanged(string url)

    function setUrl(url) { webview.url = url }

    WebView {
        id: webview
        experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
        anchors.fill: parent

        onLoadingChanged: root.urlChanged(loadRequest.url)
    }
}