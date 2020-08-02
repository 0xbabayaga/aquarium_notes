var months = [
            qsTr("January"),
            qsTr("February"),
            qsTr("March"),
            qsTr("April"),
            qsTr("May"),
            qsTr("June"),
            qsTr("July"),
            qsTr("August"),
            qsTr("September"),
            qsTr("October"),
            qsTr("November"),
            qsTr("December")
        ]
var weekNames = [
            qsTr("Sunday"),
            qsTr("Monday"),
            qsTr("Tuesday"),
            qsTr("Wednesday"),
            qsTr("Thursday"),
            qsTr("Friday"),
            qsTr("Saturday")
        ]

function DateTimeUtil(tm)
{
    this.tm = tm
}

DateTimeUtil.prototype.printDate = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var month = "0" + date.getMonth()

    var formattedDate = day.substr(-2) + '/' + month.substr(-2)

    return formattedDate
}

DateTimeUtil.prototype.printFullDate = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()

    var formattedDate = day.substr(-2) + ' ' + months[date.getMonth()] + ' ' + date.getFullYear()

    return formattedDate
}

DateTimeUtil.prototype.printDateEx = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var formattedDate = day.substr(-2) + ' ' + months[date.getMonth()].slice(0,3).toUpperCase()

    return formattedDate
}

DateTimeUtil.prototype.getMonthString = function(mm)
{
    mm %= 12
    return months[mm]
}

