import QtQuick 2.2

MouseArea {
	width: txt.width
	height: txt.height

	property alias label: txt.text
	property alias font: txt.font

	Text {
		id: txt
		color: "#0090ff"
	}
}