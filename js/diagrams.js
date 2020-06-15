var gridColor       = "#20000000"
var textColor       = "#50000000"
var blueColor       = "#00ADBC"
var orangeColor     = "#EE6000"
var greenColor      = "#00BB20"
var rBlueColor      = "#4000EE"
var yellowColor     = "#AAAA00"
var semiBlueColor   = "#2000ADBC"
var semiBlue2Color  = "#6000ADBC"
var axisFontColor   = "#000000"
var axisFont        = "10px Arial"
var axisSelFont     = "12px Arial"
var labelFont       = "20px Arial"
var lineWidth       = 2
var ptNormalSize    = 2
var ptSelectedSize  = 5
var appScale        = 1

var gradientColors = [blueColor, orangeColor, greenColor, rBlueColor, yellowColor]

function DiagramView(scale, oneDiagHeight)
{
    this.ctx = 0
    this.width = 0
    this.height = 0

    appScale = scale

    this.leftMargin = 32 * appScale
    this.rightMargin = 32 * appScale
    this.bottomMargin = 16 * appScale
    this.topMargin = 16 * appScale
    this.oneDiagHeight = oneDiagHeight
    this.drawWidth = 0
    this.drawHeight = 0

    axisFont = parseInt(10 * appScale) + "px sans-serif"
    axisSelFont = parseInt(14 * appScale) + "px sans-serif"
    labelFont = parseInt(20 * appScale) + "px sans-serif"
    ptNormalSize = 1 * appScale
    ptSelectedSize = 5 * appScale
    lineWidth = 2 * appScale

    this.curvesCnt = 0
    this.xMin = []
    this.xMax = []
    this.yMin = []
    this.yMax = []
    this.lMin = []
    this.lMax = []
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
    this.drawHeight = this.oneDiagHeight - this.bottomMargin - this.topMargin

    this.stepX = (this.xMax[0] - this.xMin[0]) / this.drawWidth
}

DiagramView.prototype.reset = function()
{
    this.curvesCnt = 0
    this.points = []
}

DiagramView.prototype.setCurrentPoint = function(currentPoint)
{
    this.currPt = currentPoint
}

DiagramView.prototype.addCurve = function(name, unit, color, xMin, xMax, yMin, yMax, lMin, lMax, points)
{
    this.xMin[this.curvesCnt] = xMin
    this.xMax[this.curvesCnt] = xMax
    this.yMin[this.curvesCnt] = yMin
    this.yMax[this.curvesCnt] = yMax
    this.lMin[this.curvesCnt] = lMin
    this.lMax[this.curvesCnt] = lMax
    this.name[this.curvesCnt] = name
    this.unit[this.curvesCnt] = unit
    this.color[this.curvesCnt] = color
    this.points.push(points)
    this.curvesCnt++
}

DiagramView.prototype.drawGrid = function(num)
{
    var pt1 = 0, pt2 = 0, ptc = 0
    var text = ""
    var x = this.leftMargin
    var i = 0

    this.ctx.beginPath()
    this.ctx.strokeStyle = gridColor
    this.ctx.lineWidth   = 0.5 * appScale

    for (i = 0; i < 5; i++)
    {
        this.ctx.moveTo(this.width - this.rightMargin, this.oneDiagHeight * num + this.drawHeight/4 * i)
        this.ctx.lineTo(this.leftMargin, this.oneDiagHeight * num + this.drawHeight/4 * i)
    }


    while (x < (this.width - this.rightMargin))
    {
        this.ctx.moveTo(x, this.oneDiagHeight * num + this.drawHeight)
        this.ctx.lineTo(x, this.oneDiagHeight * num)
        x += 2*86400/this.stepX
    }

    this.ctx.moveTo(x, this.oneDiagHeight * num + this.drawHeight)
    this.ctx.lineTo(x, this.oneDiagHeight * num)

    this.ctx.stroke()
    this.ctx.closePath()

    this.ctx.font = labelFont
    this.ctx.fillStyle = this.getCurveColor(num)
    text = this.name[num]

    i = 0

    for (var pt in this.points[num])
    {
        if (pt1 === 0)
            pt1 = pt

        if (i === this.currPt)
            ptc = pt

        pt2 = pt

        i++
    }

    this.ctx.fillStyle = semiBlueColor
    this.ctx.fillRect(this.width/2 - 40 * appScale, this.drawHeight + 1 * appScale + this.oneDiagHeight * num, 80 * appScale, 24 * appScale)


    text = this.printVal(this.points[num][ptc]) + " " + this.unit[num]
    this.ctx.fillStyle = blueColor
    this.ctx.font = axisSelFont
    this.ctx.fillText(text,
                      this.width/2 - this.getTextWidth(text)/2,
                      this.drawHeight + this.oneDiagHeight * num + 18 * appScale)

    this.ctx.font = axisFont
    this.ctx.fillStyle = textColor

    text = this.printDate(parseInt(pt1))
    this.ctx.fillText(text,
                      this.leftMargin,
                      this.oneDiagHeight * num + this.drawHeight + 10 * appScale)

    text = this.printDate(parseInt(pt2))
    this.ctx.fillText(text,
                      this.width - this.rightMargin - this.getTextWidth(text),
                      this.oneDiagHeight * num + this.drawHeight + 10 * appScale)

    this.ctx.font = labelFont
    this.ctx.fillStyle = semiBlue2Color
    text = this.name[num]
    this.ctx.fillText(text,
                      this.width - this.rightMargin - this.getTextWidth(text) - 5 * appScale,
                      this.topMargin + this.oneDiagHeight * num + 5 * appScale)
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
    var text = ""

    yScale = this.drawHeight / (maxY - minY)

    if (this.lMin[num] > 0 && this.lMin[num] > minY)
    {
        this.ctx.beginPath()
        this.ctx.lineWidth   = 1 * appScale
        this.ctx.setLineDash([4,4])

        this.ctx.strokeStyle = blueColor
        y = this.oneDiagHeight * num + this.drawHeight - parseFloat(this.lMin[num] - minY) * yScale
        this.ctx.moveTo(this.leftMargin, y)
        this.ctx.lineTo(this.leftMargin + this.drawWidth, y)

        this.ctx.stroke()
        this.ctx.closePath()
    }

    if (this.lMax[num] < maxY)
    {
        this.ctx.beginPath()
        this.ctx.lineWidth   = 1 * appScale
        this.ctx.setLineDash([4,4])

        this.ctx.strokeStyle = orangeColor
        y = this.oneDiagHeight * num + this.drawHeight - parseFloat(this.lMax[num] - minY) * yScale
        this.ctx.moveTo(this.leftMargin, y)
        this.ctx.lineTo(this.leftMargin + this.drawWidth, y)

        this.ctx.stroke()
        this.ctx.closePath()
    }

    this.ctx.font = axisFont
    this.ctx.fillStyle = textColor

    text = this.printVal(maxY)
    this.ctx.fillText(text, this.leftMargin - this.getTextWidth(text) - 4 * appScale,
                            this.oneDiagHeight * num + 8 * app.scale)

    text = this.printVal((maxY + minY)/2)
    this.ctx.fillText(text, this.leftMargin - this.getTextWidth(text) - 4 * appScale,
                            this.oneDiagHeight * num + this.drawHeight/2 + 8 * appScale/2)

    text = this.printVal(minY)
    this.ctx.fillText(text, this.leftMargin - this.getTextWidth(text) - 4 * appScale,
                            this.oneDiagHeight * num + this.drawHeight + 8 * appScale/2)

    var grd = this.ctx.createLinearGradient(0, this.drawHeight, 0, 0)
    //grd.addColorStop(0, "#00000000")
    grd.addColorStop(1, this.getCurveGradientColor(num))
    grd.addColorStop(1, this.getCurveGradientColor(num))

    /*
    this.ctx.beginPath()
    this.ctx.fillStyle = grd
    this.ctx.strokeStyle = "#00000000"
    this.ctx.lineWidth   = 1 * appScale

    this.ctx.moveTo(this.leftMargin, this.oneDiagHeight * num + this.drawHeight)

    for (pt in this.points[num])
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin[num]) / this.stepX
        y = this.oneDiagHeight * num + this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

        this.ctx.lineTo(x, y)
    }

    this.ctx.lineTo(this.width - this.rightMargin, this.oneDiagHeight * num + this.drawHeight)
    this.ctx.closePath()
    this.ctx.fill()
    */

    this.ctx.beginPath()
    this.ctx.strokeStyle = this.getCurveColor(num)
    this.ctx.fillStyle = textColor
    this.ctx.lineWidth   = 2 * appScale
    this.ctx.setLineDash([1000])

    for (pt in this.points[num])
    {
        x = this.leftMargin + (parseInt(pt) - this.xMin[num]) / this.stepX
        y = this.oneDiagHeight * num + this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

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
        y = this.oneDiagHeight * num + this.drawHeight - parseFloat(this.points[num][pt] - minY) * yScale

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
    this.ctx.clearRect(0, 0, this.width, this.height)

    for (var i = 0; i < this.curvesCnt; i++)
    {
        this.drawGrid(i)
        this.drawCurve(i)
    }
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
        val = Math.round(val * 10)/10
    else if (val > 0.1)
        val = Math.round(val * 100)/100

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
        val = this.getScaleMin(val) + 1/10
    else if (val > 0.1)
        val = this.getScaleMin(val) + 1/100

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
        color = "#F0" + blueColor.substr(-6)

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
