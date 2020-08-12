.import AppDefs 1.0 as AppDefs

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

    if (app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_MM_DD_YYYY || app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_YYYY_MM_DD)
        formattedDate = month.substr(-2) + '/' + day.substr(-2)
    else if (app.global_DATEFORMAT === 1)
        formattedDate = day.substr(-2) + '/' + month.substr(-2)

    return formattedDate
}

DateTimeUtil.prototype.printFullDate = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var formattedDate = ""

    if (app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_MM_DD_YYYY)
        formattedDate = months[date.getMonth()] + ' ' + day.substr(-2) + ' ' + date.getFullYear()
    else if (app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_DD_MM_YYYY)
        formattedDate = day.substr(-2) + ' ' + months[date.getMonth()] + ' ' + date.getFullYear()
    else
        formattedDate = date.getFullYear() + ' ' + months[date.getMonth()] + ' ' + day.substr(-2)

    return formattedDate
}

DateTimeUtil.prototype.printDateEx = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var formattedDate = day.substr(-2) + ' ' + months[date.getMonth()].slice(0,3).toUpperCase()

    if (app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_MM_DD_YYYY || app.global_DATEFORMAT === AppDefs.AppDefs.DateFormat_YYYY_MM_DD)
        formattedDate = months[date.getMonth()].slice(0,3).toUpperCase() + ' ' + day.substr(-2)
    else if (app.global_DATEFORMAT === 1)
        formattedDate = day.substr(-2) + ' ' + months[date.getMonth()].slice(0,3).toUpperCase()

    return formattedDate
}

DateTimeUtil.prototype.getMonthString = function(mm)
{
    mm %= 12
    return months[mm]
}

