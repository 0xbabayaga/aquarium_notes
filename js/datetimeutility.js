var months = [qsTr("January"), "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
var weekNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

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

