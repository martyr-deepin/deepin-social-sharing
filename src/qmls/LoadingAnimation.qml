/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
	id: root
	width: border.implicitWidth
	height: border.implicitHeight

	property int imageCounts: 100

	Item {
		id: water
		clip: true
		width: mask.width
		height: mask.height

		Image {
			id: water_back
			width: implicitWidth * root.imageCounts
			y: 12
			source: "../../images/water_back.png"
			fillMode: Image.TileHorizontally
			verticalAlignment: Image.AlignLeft
		}

		Image {
			id: water_front
			width: implicitWidth * root.imageCounts
			y: 15
			source: "../../images/water_front.png"
			fillMode: Image.TileHorizontally
			verticalAlignment: Image.AlignLeft
		}
	}

	Image {
		id: mask
		smooth: true
		antialiasing: false
		source: "../../images/mask.png"
	}

	ThresholdMask {
        anchors.fill: water
        threshold: 0.12
        source: ShaderEffectSource { sourceItem: water; hideSource: true }
        maskSource: mask
    }

	Image {
		id: border
		source: "../../images/line.png"
	}

	NumberAnimation {
		id: back_animation
		running: true
		target: water_back
		property: "x"
		duration: 3000 * root.imageCounts
		from: -(water_back.width - water.width)
		to: 0
		loops: Animation.Infinite
	}

	NumberAnimation {
		id: front_animation
		running: true
		target: water_front
		property: "x"
		duration: 3000 * root.imageCounts
		from: -(water_front.width - water.width) - 15
		to: 0
		loops: Animation.Infinite
	}
}