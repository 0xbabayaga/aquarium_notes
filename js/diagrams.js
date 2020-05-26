var gridColor     = "#40000000"
var axisFontColor = "#000000"
var axisFont      = "16px sans-serif"
var axisTypeFont  = "24px sans-serif"

function DiagramView(ctx, width, height)
{
    this.ctx = ctx
    this.width = width
    this.height = height

    this.xMin = 0
    this.xMax = 0
    this.yMin = 0
    this.yMax = 0

    this.leftMargin = 16
    this.rightMargin = 16
    this.bottomMargin = 16
    this.topMargin = 16

    this.stepX = 0
}

DiagramView.prototype.printDate = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var month = "0" + date.getMonth()
    var year = "0" + date.getYear()

    var formattedDate = day.substr(-2) + '/' + month.substr(-2)

    return formattedDate
}

DiagramView.prototype.setLimits = function(xMin, xMax, yMin, yMax)
{
    this.xMin = xMin
    this.xMax = xMax
    this.yMin = yMin
    this.yMax = yMax
}

DiagramView.prototype.draw = function()
{
    this.drawGrid();
}

DiagramView.prototype.drawGrid = function()
{
    this.ctx.clearRect(0, 0, this.width, this.height);

    this.ctx.beginPath();

    this.ctx.stroke()

    this.ctx.beginPath()

    this.ctx.strokeStyle = gridColor
    this.ctx.lineWidth   = 1

    this.ctx.moveTo(this.leftMargin, this.height - this.bottomMargin)
    this.ctx.lineTo(this.width - this.rightMargin, this.height - this.bottomMargin)
    this.ctx.lineTo(this.width - this.rightMargin, this.topMargin)
    this.ctx.lineTo(this.leftMargin, this.topMargin)
    this.ctx.lineTo(this.leftMargin, this.height - this.bottomMargin)
    this.ctx.stroke()

    this.stepX = (this.xMax - this.xMin) / (this.width - this.rightMargin - this.leftMargin)

    this.ctx.fillText(printDate(this.xMin), this.leftMargin, this.height - this.bottomMargin)
    this.ctx.fillText(printDate(this.xMax), this.width - this.rightMargin, this.height - this.bottomMargin)

    this.ctx.stroke()
}

DiagramView.prototype.drawCurve = function(points)
{
    var curveStart = 1

    this.ctx.beginPath()

    this.ctx.strokeStyle = "#00ADbC"
    this.ctx.lineWidth   = 2

    for (var pt in points)
    {
        if (curveStart === 1)
        {
            this.ctx.moveTo(this.leftMargin + (parseInt(pt) - this.xMin) / this.stepX, this.height - this.bottomMargin - parseFloat(points[pt]) * 10)
            curveStart = 0
        }
        else
            this.ctx.lineTo(this.leftMargin + (parseInt(pt) - this.xMin) / this.stepX, this.height - this.bottomMargin - parseFloat(points[pt]) * 10)

        console.log("PT x = ", this.leftMargin + (parseInt(pt) - this.xMin) / this.stepX , parseFloat(points[pt]))
    }

    this.ctx.stroke()
}

