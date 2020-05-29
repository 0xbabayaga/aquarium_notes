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
    this.stepX = 0
    this.name = ""

    this.leftMargin = 16
    this.rightMargin = 16
    this.bottomMargin = 16
    this.topMargin = 16

    this.drawWidth = 0
    this.drawHeight = 0
}

DiagramView.prototype.init = function()
{
    this.drawWidth = this.width - this.leftMargin - this.rightMargin
    this.drawHeight = this.height - this.bottomMargin - this.topMargin
}

DiagramView.prototype.setDiagramParams = function(xMin, xMax)
{
    this.init()

    this.xMin = xMin
    this.xMax = xMax
    this.stepX = (this.xMax - this.xMin) / this.drawWidth

    this.ctx.clearRect(0, 0, this.width, this.height);
}

DiagramView.prototype.drawGrid = function()
{
    var yShift = 0

    this.ctx.fillStyle = "#2000ADbC"
    this.ctx.fillRect(this.leftMargin, yShift, this.drawWidth, this.drawHeight);

    yShift += this.drawHeight

    this.ctx.beginPath()

    this.ctx.strokeStyle = gridColor
    this.ctx.lineWidth   = 1

    this.ctx.moveTo(this.leftMargin, yShift)
    this.ctx.lineTo(this.width - this.rightMargin, yShift)
    this.ctx.stroke()

    this.ctx.fillStyle = "#80000000"
    this.ctx.fillText(printDate(this.xMin), this.leftMargin, yShift)
    this.ctx.fillText(printDate(this.xMax), this.width - this.rightMargin, yShift)

    this.ctx.stroke()
}

DiagramView.prototype.drawCurve = function(name, xMin, xMax, yMin, yMax, points)
{
    var curveStart = 1
    var x = 0
    var y = 0
    var yScale = 1

    this.setDiagramParams(xMin, xMax)

    this.drawGrid()

    yScale = this.drawHeight / (yMax - yMin)

    this.ctx.beginPath()

    this.ctx.strokeStyle = "#00ADbC"
    this.ctx.lineWidth   = 1

    for (var pt in points)
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin) / this.stepX
        y = this.drawHeight - parseFloat(points[pt]) * yScale

        console.log("CURVE #", this.curveCnt, x, y)

        if (curveStart === 1)
        {
            this.ctx.moveTo(x, y)
            curveStart = 0
        }
        else
        {
            //this.ctx.arc(this.leftMargin + (parseInt(pt) - this.xMin) / this.stepX, this.height - this.bottomMargin - parseFloat(points[pt]) * 10, 3, 0, 360, 0);



            this.ctx.lineTo(x, y)
        }
    }

    this.ctx.stroke()

    this.curveCnt++
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
