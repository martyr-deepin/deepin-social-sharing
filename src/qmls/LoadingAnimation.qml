import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
	width: border.implicitWidth
	height: border.implicitHeight

	Item {
		id: water
		clip: true
		width: mask.width
		height: mask.height

		Image {
			id: water_back
			y: 12
			source: "../../images/water_back.png"
		}

		Image {
			id: water_front
			y: 15
			mirror: true
			source: "../../images/water_front.png"
		}
	}

	Image {
		id: mask
		source: "../../images/mask.png"
	}

	ThresholdMask {
        anchors.fill: water
        threshold: 0.1
        source: ShaderEffectSource { sourceItem: water; hideSource: true }
        maskSource: mask
    }

	Image {
		id: border
		source: "../../images/line.png"
	}

	NumberAnimation {
		id: back_animation
		target: water_back
		property: "x"
		duration: 3000
		from: 0
		to: -(water_back.width - water.width)
		loops: Animation.Infinite
	}

	NumberAnimation {
		id: front_animation
		target: water_front
		property: "x"
		duration: 3000
		from: 0
		to: -(water_front.width - water.width)
		loops: Animation.Infinite
	}

	function show() { back_animation.restart(); front_animation.restart() }
	function hide() { back_animation.stop(); front_animation.stop() }

	Component.onCompleted: show()
}