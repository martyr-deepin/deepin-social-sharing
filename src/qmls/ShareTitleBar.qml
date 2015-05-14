import QtQuick 2.2
import Deepin.Widgets 1.0

Item {
	id: root
	width: 300
	height: 30

	property bool canGoBack: true

	signal backButtonClicked()

	DImageButton {
	    id: back_button
	    visible: root.canGoBack
	    normal_image: "../../images/back_normal.png"
	    hover_image: "../../images/back_hover.png"
	    press_image: "../../images/back_press.png"

	    anchors.top: parent.top
	    anchors.left: parent.left

	    onClicked: root.backButtonClicked()
	}
}