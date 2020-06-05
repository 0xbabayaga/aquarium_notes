var gridColor       = "#40000000"
var textColor       = "#70000000"
var blueColor       = "#00ADBC"
var orangeColor     = "#EE6000"
var greenColor      = "#00BB20"
var rBlueColor      = "#4000EE"
var yellowColor     = "#AAAA00"
var semiBlueColor   = "#2000ADBC"
var axisFontColor   = "#000000"
var axisFont        = "10px Arial"
var axisSelFont     = "12px Arial"
var labelFont       = "14px Arial"
var lineWidth       = 2
var ptNormalSize    = 2
var ptSelectedSize  = 5
var appScale        = 1

var gradientColors = [blueColor, orangeColor, greenColor, rBlueColor, yellowColor]

function DiagramView(scale)
{
    this.ctx = 0
    this.width = 0
    this.height = 0

    appScale = scale

    this.leftMargin = 32 * appScale
    this.rightMargin = 32 * appScale
    this.bottomMargin = 32 * appScale
    this.topMargin = 16 * appScale

    axisFont = parseInt(10 * appScale) + "px sans-serif"
    axisSelFont = parseInt(14 * appScale) + "px sans-serif"
    labelFont = parseInt(14 * appScale) + "px sans-serif"
    ptNormalSize = 1 * appScale
    ptSelectedSize = 5 * appScale
    lineWidth = 2 * appScale

    this.drawWidth = 0
    this.drawHeight = 0

    this.xMin = []
    this.xMax = []
    this.yMin = []
    this.yMax = []
    this.stepX = 0
    this.name = []
    this.unit = []
    this.color = []
    this.points = []
    this.currPt = 0
}

DiagramView.prototype.init = function(ctx, width, height)
{
    this.ctx = ctx
    this.width = width
    this.height = height

    this.drawWidth = this.width - this.leftMargin - this.rightMargin
    this.drawHeight = this.height - this.bottomMargin - this.topMargin

    this.stepX = (this.xMax[0] - this.xMin[0]) / this.drawWidth
}


DiagramView.prototype.setCurrentPoint = function(currentPoint)
{
    this.currPt = currentPoint
}

DiagramView.prototype.setCurve = function(num, name, unit, color, xMin, xMax, yMin, yMax, points)
{
    this.xMin[num] = xMin
    this.xMax[num] = xMax
    this.yMin[num] = yMin
    this.yMax[num] = yMax
    this.name[num] = name
    this.unit[num] = unit
    this.color[num] = color
    this.points.push(points)
}

DiagramView.prototype.drawGrid = function()
{
    var yShift = 0
    var pt1 = 0, pt2 = 0, ptc = 0

    console.log("drawGrid")

    this.ctx.clearRect(0, 0, this.width, this.height)

    yShift += this.drawHeight

    this.ctx.beginPath()
    this.ctx.strokeStyle = gridColor
    this.ctx.lineWidth   = 0.5 * appScale
    this.ctx.moveTo(this.width - this.rightMargin, yShift)
    this.ctx.lineTo(this.leftMargin, yShift)
    this.ctx.moveTo(this.width - this.rightMargin, yShift/2)
    this.ctx.lineTo(this.leftMargin, yShift/2)
    this.ctx.moveTo(this.width - this.rightMargin, 0)
    this.ctx.lineTo(this.leftMargin, 0)
    this.ctx.stroke()
    this.ctx.closePath()

    this.ctx.font = labelFont
    this.ctx.fillStyle = this.getCurveColor(0)
    this.ctx.fillText(this.name, this.width - this.rightMargin - this.getTextWidth(this.name), this.topMargin)

    var i = 0

    for (var pt in this.points[0])
    {
        if (pt1 === 0)
            pt1 = pt

        if (i === this.currPt)
            ptc = pt

        pt2 = pt

        i++
    }

    this.ctx.fillText(this.printVal(this.points[0][pt]) + this.unit[0], this.leftMargin, this.topMargin)

    this.ctx.font = axisFont
    this.ctx.fillStyle = gridColor
    this.ctx.fillText(this.printDate(parseInt(pt1)), this.leftMargin, this.drawHeight + 10 * appScale)
    this.ctx.fillText(this.printDate(parseInt(pt2)), this.width - this.rightMargin - this.getTextWidth(this.printDate(parseInt(pt2))), this.drawHeight + 10 * appScale)

    this.ctx.font = axisSelFont
    this.ctx.fillStyle = this.getCurveColor(0)
    this.ctx.fillText(this.printDate(parseInt(ptc)), this.leftMargin + this.drawWidth/2 - this.getTextWidth(this.printDate(ptc)), this.drawHeight + 14 * appScale)
}

DiagramView.prototype.drawCurve = function(num)
{
    var curveStart = 1
    var x = 0
    var y = 0
    var i = 0
    var yScale = 1
    var pt
    var minY = this.getScaleMin(this.yMin[num])
    var maxY = this.getScaleMax(this.yMax[num])

    yScale = this.drawHeight / (maxY - minY)

    this.ctx.font = axisFont
    this.ctx.fillStyle = gridColor
    this.ctx.fillText(this.printVal(minY), this.leftMargin - 20 * appScale, this.drawHeight)
    this.ctx.fillText(this.printVal((maxY + minY)/2), this.leftMargin - 20 * appScale, this.drawHeight/2)
    this.ctx.fillText(this.printVal(maxY), this.leftMargin - 20 * appScale, 8)

    var grd = this.ctx.createLinearGradient(0, this.drawHeight, 0, 0)
    //grd.addColorStop(0, "#00000000")
    grd.addColorStop(1, this.getCurveGradientColor(num))
    grd.addColorStop(1, this.getCurveGradientColor(num))

    this.ctx.beginPath()
    this.ctx.fillStyle = grd
    this.ctx.strokeStyle = "#00000000"
    this.ctx.lineWidth   = 1 * appScale

    this.ctx.moveTo(this.leftMargin, this.drawHeight)

    for (pt in this.points[num])
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin[num]) / this.stepX
        y = this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

        this.ctx.lineTo(x, y)
    }

    this.ctx.lineTo(this.width - this.rightMargin, this.drawHeight)
    this.ctx.closePath()
    this.ctx.fill()


    this.ctx.beginPath()
    this.ctx.strokeStyle = this.getCurveColor(num)
    this.ctx.fillStyle = textColor
    this.ctx.lineWidth   = 2 * appScale

    for (pt in this.points[num])
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin[num]) / this.stepX
        y = this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

        if (curveStart === 1)
        {
            this.ctx.moveTo(x, y)
            curveStart = 0
        }
        else
            this.ctx.lineTo(x, y)
    }

    this.ctx.stroke()

    for (pt in this.points[num])
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin[num]) / this.stepX
        y = this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

        this.ctx.beginPath()

        if (i === this.currPt)
            this.ctx.arc(x, y, ptSelectedSize, 0, 360, 0)
        else
            this.ctx.arc(x, y, ptNormalSize, 0, 360, 0)

        this.ctx.fillStyle = this.getCurveColor(num)
        this.ctx.fill()
        this.ctx.lineWidth = 2 * appScale
        this.ctx.strokeStyle = this.getCurveColor(num)
        this.ctx.stroke()

        i++
    }

}

DiagramView.prototype.draw = function()
{
    this.drawGrid()

    for (var i = 0; i < this.xMin.length; i++)
        this.drawCurve(i)
}

DiagramView.prototype.getScaleMin = function(val)
{
    var input = val

    if (val > 1000)
        val = val - val % 100
    else if (val > 100)
        val = val - val % 10
    else if (val > 10)
        val = val - val % 1
    else if (val > 1)
        val = val - ((val * 1) % 1)/1
    else if (val > 0.1)
        val = val - ((val * 10) % 1)/10

    return val
}

DiagramView.prototype.getScaleMax = function(val)
{
    var input = val

    if (val > 1000)
        val = this.getScaleMin(val) + 100
    else if (val > 100)
        val = this.getScaleMin(val) + 10
    else if (val > 10)
        val = this.getScaleMin(val) + 1
    else if (val > 1)
        val = this.getScaleMin(val) + 0.1
    else if (val > 0.1)
        val = this.getScaleMin(val) + 0.01

    return val
}

DiagramView.prototype.printVal = function(val)
{
    if (val >= 100)
        return parseInt(val)
    else if (val >= 10)
        return Math.round(10 * val) / 10
    else
        return Math.round(100 * val) / 100
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

DiagramView.prototype.printDay = function(tm)
{
    var date = new Date(tm * 1000)
    var day = "0" + date.getDate()
    var month = "0" + date.getMonth()
    var year = "0" + date.getYear()

    var formattedDate = day.substr(-2)

    return formattedDate
}

DiagramView.prototype.getCurveColor = function(num)
{
    var color

    //if (this.color[num].length > 0)
    //    color = "#A0" + this.color[num].substr(-6)
    //else
        color = "#A0" + blueColor.substr(-6)

    return  color
}

DiagramView.prototype.getCurveGradientColor = function(num)
{
    var color

    //if (this.color[num].length > 0)
    //    color = "#40" + this.color[num].substr(-6)
    //else
        color = "#40" + blueColor.substr(-6)

    return  color
}

DiagramView.prototype.getTextWidth = function(text)
{
    return this.ctx.measureText(text).width
}
