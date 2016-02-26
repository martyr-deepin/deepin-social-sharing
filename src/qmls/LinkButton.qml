/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
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