import QtQuick 2.1
import QtQuick.Window 2.1
import Deepin.Widgets 1.0

DPopupWindow {
    id: menuPopupWindow
    property int frameEdge: menuFrame.shadowRadius + menuFrame.frameRadius
    property int minWidth: 30
    property real posX: 0
    property real posY: 0

    x: posX - 28
    y: posY - 12

    width: minWidth + 24
    height: completeViewBox.height + 32

    property int maxHeight: -1

    property alias currentIndex: completeView.currentIndex
    property var labels
    visible: false

    signal reset()
    signal menuSelect(int index)
    signal removeAccount(int index)
    signal newAccount()

    onLabelsChanged: {
        completeView.model.clear()
        for (var i = 0; i < labels.length; i++) {
            completeView.model.append({ "itemLabel": labels[i] })
        }
        completeView.model.append({ "itemLabel": dsTr("New account") })
    }

    DWindowFrame {
        id: menuFrame
        anchors.fill: parent

        Item {
            id: completeViewBox
            anchors.centerIn: parent
            width: parent.width - 6
            height: childrenRect.height

            ListView {
                id: completeView
                width: parent.width
                height: maxHeight != -1 ? Math.min(childrenHeight, maxHeight) : childrenHeight
                property int childrenHeight: childrenRect.height
                maximumFlickVelocity: 1000
                model: ListModel {}
                delegate: AccountsMenuItem {
                    text: itemLabel
                    canDelete: index != completeView.count - 1

                    onSelectAction:{
                        menuPopupWindow.visible = false
                        if (index == completeView.count - 1) {
                            menuPopupWindow.newAccount()
                        } else {
                            menuPopupWindow.menuSelect(index)
                        }
                    }
                    onClear: {
                        menuPopupWindow.removeAccount(index)
                        if (index>=0) {
                            completeView.model.remove(index, 1)
                        }
                        if (completeView.count != 1) {
                            menuPopupWindow.menuSelect(0)
                        } else {
                            menuPopupWindow.reset()
                        }
                    }
                }
                clip: true
            }
        }

    }

}
