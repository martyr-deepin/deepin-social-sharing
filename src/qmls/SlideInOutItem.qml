/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.1

Item {
    id: rect
    width: 400
    height: 300

    signal beforeInAnimation()
    signal afterOutAnimation()

    NumberAnimation {
        id: in_animation
        property: "x"
        target: rect
        duration: 300
        easing.type: Easing.OutCubic
        onStarted: {
            rect.beforeInAnimation()
            rect.visible = true
        }
    }

    NumberAnimation {
        id: out_animation
        property: "x"
        target: rect
        duration: 300
        easing.type: Easing.OutCubic
        onStopped: {
            rect.visible = false
            rect.afterOutAnimation()
        }
    }

    function leftIn() {
        rect.x = -width
        in_animation.to = 0
        in_animation.start()
    }

    function leftOut() {
        rect.x = 0
        out_animation.to = -width
        out_animation.start()
    }

    function rightIn() {
        rect.x = width
        in_animation.to = 0
        in_animation.start()
    }

    function rightOut() {
        rect.x = 0
        out_animation.to = width
        out_animation.start()
    }
}