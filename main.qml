import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 400
    height: 400
    title: "Analog Clock"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.updateTime()
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: clockArea
        anchors.centerIn: parent
        width: 300
        height: 300
        radius: 150
        color: "black"
        border.color: "white"
        border.width: 2

        // Clock face (Repeater for numbers around the circle)
        Repeater {
            model: 12
            delegate: Item {
                id: clockNumberDelegate
                width: 30
                height: 30

                // Position the numbers correctly in a circle
                Component.onCompleted: {
                    var angle = (index * 30 - 60) * (Math.PI / 180);  // Convert degrees to radians
                    var radius = 125;  // Radius of the clock face

                    // Calculate the X and Y offset for positioning the numbers around the circle
                    var xOffset = Math.cos(angle) * radius;  // X position along the circle
                    var yOffset = Math.sin(angle) * radius;  // Y position along the circle

                    // Move the item to the calculated position
                    clockNumberDelegate.x = 150 + xOffset - width / 2;  // Center it properly (subtract half the width)
                    clockNumberDelegate.y = 150 + yOffset - height / 2;  // Center it properly (subtract half the height)
                }

                // Number text
                Text {
                    text: (index + 1).toString()  // Show numbers 1 to 12
                    anchors.centerIn: parent
                    font.pixelSize: clockDefinition.fontSize
                    font.bold: true
                    color: clockDefinition.color_text_circle
                }
            }
        }

        // Hour hand (Loader to dynamically create the hand)
        Loader {
            id: hourHandLoader
            anchors.centerIn: parent
            sourceComponent: clockHandComponent
            onLoaded: {
                var hand = hourHandLoader.item
                hand.color = clockDefinition.color_hour_hand
                hand.angle = clock.hourAngle
                hand.content = clock.hourHandContent
                clock.timeUpdated.connect(function() {
                    hand.angle = clock.hourAngle
                    hand.content = clock.hourHandContent
                })
            }
        }

        // Minute hand (Loader to dynamically create the hand)
        Loader {
            id: minuteHandLoader
            anchors.centerIn: parent
            sourceComponent: clockHandComponent
            onLoaded: {
                var hand = minuteHandLoader.item
                hand.color = clockDefinition.color_minute_hand
                hand.angle = clock.minuteAngle
                hand.content = clock.minuteHandContent
                clock.timeUpdated.connect(function() {
                    hand.angle = clock.minuteAngle
                    hand.content = clock.minuteHandContent
                })
            }
        }

        // Second hand (Loader to dynamically create the hand)
        Loader {
            id: secondHandLoader
            anchors.centerIn: parent
            sourceComponent: clockHandComponent
            onLoaded: {
                var hand = secondHandLoader.item
                hand.color = clockDefinition.color_second_hand
                hand.angle = clock.secondAngle
                hand.content = clock.secondHandContent
                clock.timeUpdated.connect(function() {
                    hand.angle = clock.secondAngle
                    hand.content = clock.secondHandContent
                })
            }
        }
    }

    // Reusable clock hand component
    Component {
        id: clockHandComponent

        Item {
            id: clockItem
            property alias length: rect.height
            property alias color: text.color
            property alias content: text.text
            property alias angle: clockItem.rotation
            property bool flip: angle > 90 && angle < 270

            rotation: angle

            Item {
                id: rect
                width: handRow.contentWidth
                height: text.contentHeight
                anchors.centerIn: parent
                anchors.verticalCenterOffset: flip ? text.contentHeight : 0
                anchors.horizontalCenterOffset: flip ? text.contentWidth : 0

                Row {
                    id: handRow
                    anchors.centerIn: parent
                    Text {
                        id: text
                        font.pixelSize: clockDefinition.fontSize
                        font.bold: true
                        transform: Scale {
                            xScale: flip ? -1 : 1
                            yScale: flip ? -1 : 1
                        }
                    }
                    Item {
                        width: text.contentWidth
                        height: text.contentHeight
                    }
                }
            }
        }
    }

    Text {
        id: textDate
        text: clock.dateString
        color: clockDefinition.color_text_date
        font.pixelSize: clockDefinition.fontSize
        anchors.centerIn: parent
        anchors.verticalCenterOffset: clockArea.height / 6
    }

    // Clock object for calculating and updating time
    QtObject {
        id: clock

        signal timeUpdated()

        property int hour: 0
        property int minute: 0
        property int second: 0

        // These will be regular properties that you can update directly
        property real hourAngle: 0
        property real minuteAngle: 0
        property real secondAngle: 0

        property string hourHandContent: ""
        property string minuteHandContent: ""
        property string secondHandContent: ""

        property string dateString: ""

        function updateTime() {
            var date = new Date()

            hour = date.getHours() % 24 + clockDefinition.timezone
            minute = date.getMinutes()
            second = date.getSeconds()

            function padAndRepeat(value, repeat) {
                return (value < 10 ? "0" + value : value.toString()).repeat(repeat);
            }
            hourHandContent = padAndRepeat(hour, 3)
            minuteHandContent = padAndRepeat(minute, 5)
            secondHandContent = padAndRepeat(second, 5)

            // Calculate the angles for the hands
            hourAngle = 30 * hour + 0.5 * minute + 90
            minuteAngle = 6 * minute + 0.1 * second + 90
            secondAngle = 6 * second + 90

            var dateOptions = { year: 'numeric', month: 'short', day: 'numeric' };
            dateString = date.toLocaleDateString('vi-VN', dateOptions);

            timeUpdated()
        }
    }

    QtObject {
        id: clockDefinition

        property int fontSize: 16
        property int timezone: 7
        property color color_hour_hand: "red"
        property color color_minute_hand: "blue"
        property color color_second_hand: "green"
        property color color_text_date: "yellow"
        property color color_text_circle: "silver"
    }
}
