//: Playground - noun: a place where people can play
_setup()
//#-end-hidden-code
//#-editable-code Tap to enter code.
let line = LinePlot(yData: 0, 1, 4, 9, 16)
line.label = "Squares of Numbers"

//#-end-editable-code

//#-end-hidden-code
//#-editable-code Tap to enter code.
// 1. Create a line plot.
let Secondline = LinePlot(xyData: (1,1), (10,50))

// 2. Create a line plot from a data set.
let data = XYData()
for i in 1...10 {
    data.append(x: Double(i), y: Double(i * i))
}
let lineFromDataSet = LinePlot(xyData: data)
lineFromDataSet.color = #colorLiteral(red: 0.07005243003, green: 0.5545874834, blue: 0.1694306433, alpha: 1)

// 3. Create a line plot from a function.
let function = LinePlot { x in
    10 + x - x * x/2
}
function.color = #colorLiteral(red: 0.7086744905, green: 0.05744680017, blue: 0.5434997678, alpha: 1)
function.lineWidth = 3

//#-end-editable-code

//#-end-hidden-code
//#-editable-code Tap to enter code.
// 1. Create a scatter plot using symbols.
let symbolScatter = ScatterPlot(xyData: (1,3), (1.3,3.1), (1.7,3.4), (2,4.5), (2.25,4), (2.4,4.1), (2.5,3.85), (2.7,5.5), (3,6.25), (3.1,7.05), (3.5,7))
symbolScatter.color = #colorLiteral(red: 0, green: 0.1771291047, blue: 0.97898072, alpha: 1)

// 2. Create a scatter plot using images.
let imageScatter = ScatterPlot(xyData: (1.25,7.5), (1.35,7.1), (1.5,7.2), (1.55,6.9),(1.55,7.4))
imageScatter.symbol = Symbol(imageNamed: "SwiftBird", size: 24)

//#-end-editable-code

