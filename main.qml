import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 400
    height: 400
    title: "Analog Digits Clock"

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
                    var angle = (index * 30 - 60) * (Math.PI / 180) % 360;  // Convert degrees to radians
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

        ClockHand {
            id: hourHandLoader
            anchors.centerIn: parent
            color: clockDefinition.color_hour_hand
            fontSize: clockDefinition.fontSize
            angle: clock.hourAngle
            content: clock.hourHandContent
        }

        ClockHand {
            id: minuteHandLoader
            anchors.centerIn: parent
            color: clockDefinition.color_minute_hand
            fontSize: clockDefinition.fontSize
            angle: clock.minuteAngle
            content: clock.minuteHandContent
        }

        ClockHand {
            id: secondHandLoader
            anchors.centerIn: parent
            color: clockDefinition.color_second_hand
            fontSize: clockDefinition.fontSize
            angle: clock.secondAngle
            content: clock.secondHandContent
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

    Text {
        id: textTime
        text: clock.timeString
        color: clockDefinition.color_text_time
        font.pixelSize: clockDefinition.fontSize
        anchors.horizontalCenter: textDate.horizontalCenter
        anchors.top: textDate.bottom
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
        property string timeString: ""

        function updateTime() {
            const date = new Date()

            function pad(value) {
                return value < 10 ? "0" + value : value.toString();
            }

            hour = (date.getHours() + clockDefinition.timezone) % 24
            minute = date.getMinutes()
            second = date.getSeconds()

            const hourStr = pad(hour)
            const minuteStr = pad(minute)
            const secondStr = pad(second)

            hourHandContent = hourStr.repeat(3)
            minuteHandContent = minuteStr.repeat(5)
            secondHandContent = secondStr.repeat(5)

            // Calculate the angles for the hands
            hourAngle = (30 * hour + 0.5 * minute + 90) % 360
            minuteAngle = (6 * minute + 0.1 * second + 90) % 360
            secondAngle = (6 * second + 90) % 360

            const day = pad(date.getDate())
            const month = pad(date.getMonth() + 1)
            const year = date.getFullYear();

            dateString = day + "/" + month + "/" + year;
            timeString = hourStr + ":" + minuteStr + ":" + secondStr

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
        property color color_text_date: "cyan"
        property color color_text_time: "yellow"
        property color color_text_circle: "silver"
    }
}
