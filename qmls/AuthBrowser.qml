import QtQuick 2.2
import QtWebKit 3.0
import QtWebKit.experimental 1.0

SlideInOutItem {
	id: root

	signal urlChanged(string url)

	function setUrl(url) { webview.url = url }

	Rectangle {
		color: "white"
		anchors.fill: parent
	}

	WebView {
	    id: webview
	    experimental.userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
	    anchors.fill: parent

	    onLoadingChanged: root.urlChanged(loadRequest.url)
	}
}