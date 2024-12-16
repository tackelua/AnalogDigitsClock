import QtQuick 2.15

Item {
    id: clockHand
    property alias color: text.color
    property alias content: text.text
    property alias angle: clockHand.rotation

    rotation: angle

    Item {
        id: clockHandItem
        property bool flip: angle > 90 && angle < 270

        width: handRow.contentWidth
        height: text.contentHeight
        anchors.centerIn: parent
        anchors.verticalCenterOffset: clockHandItem.flip ? text.contentHeight : 0
        anchors.horizontalCenterOffset: clockHandItem.flip ? text.contentWidth : 0

        Row {
            id: handRow
            anchors.centerIn: parent
            Text {
                id: text
                font.pixelSize: clockDefinition.fontSize
                font.bold: true
                transform: Scale {
                    xScale: clockHandItem.flip ? -1 : 1
                    yScale: clockHandItem.flip ? -1 : 1
                }
            }
            Item {
                width: text.contentWidth
                height: text.contentHeight
            }
        }
    }
}
