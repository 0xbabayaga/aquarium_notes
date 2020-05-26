var gridColor     = "#40000000"
var axisFontColor = "#000000"
var axisFont      = "16px sans-serif"
var axisTypeFont  = "24px sans-serif"

function DiagramView(ctx, width, height)
{
    this.ctx = ctx
    this.width = width
    this.height = height

    this.leftMargin = 16
    this.rightMargin = 16
    this.bottomMargin = 16
    this.topMargin = 16
}

DiagramView.prototype.draw = function()
{
    this.drawGrid();
}

DiagramView.prototype.drawGrid = function()
{
    this.ctx.beginPath();

    //this.ctx.fillStyle = '#FFFFFF';
    //this.ctx.fillRect(0, 0, this.width, this.height);

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

    /*
    step = (this.height - this.topMargin - this.bottomMargin) / 5;
    stepYValue = (this.maxScale - this.minScale) / 5;

    for(y = 0; y <= 5; y++)
    {
        this.ctx.beginPath();

        this.ctx.lineWidth = 0.3;
        this.ctx.fillStyle = gridColor;
        this.ctx.font      = axisFont;

        this.ctx.moveTo(this.leftMargin-4, this.topMargin + step*y);
        this.ctx.lineTo(this.leftMargin+4, this.topMargin + step*y);

        // grid
        if(y < 5)
        {
            this.ctx.moveTo(this.leftMargin+4, this.topMargin + step*y);
            this.ctx.lineTo(this.width - this.rightMargin, this.topMargin + step*y)
        }

        text = parseInt((this.minScale) + y * stepYValue);
        wText = this.ctx.measureText(text).width;
        this.ctx.fillText(text, this.leftMargin - 10 - wText,
        this.height - this.bottomMargin - step * y);

        this.ctx.stroke();
    }
    */
}
