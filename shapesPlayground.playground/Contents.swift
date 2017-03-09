//: Playground - noun: a place where people can play
//#-code-completion(module, hide, Swift)
//#-code-completion(identifier, hide, _setup())
//#-code-completion(identifier, hide, AbstractDrawable)
//#-code-completion(identifier, hide, _ColorLiteralType)
//#-hidden-code
_setup()
//#-end-hidden-code
//#-editable-code Tap to enter code
// create a line.
let line = Line(start: Point(x: -10, y: 0), end: Point(x: 10, y: 0))
line.color = .blue
line.center.y += 6

// create a Text object that, when tapped, will kick off the clockwise rotation animation.
let rotateClockwiseText = Text(string: "Rotate Line Clockwise", fontSize: 21.0)
rotateClockwiseText.color = .blue
rotateClockwiseText.center.y -= 7

// create a Text object that, when tapped, will kick off the counter-clockwise rotation animation.
let rotateCounterClockwiseText = Text(string: "Rotate Line Counter Clockwise", fontSize: 21.0)
rotateCounterClockwiseText.color = .blue
rotateCounterClockwiseText.center.y -= 12

// roate the line clockwise with animation when the "Rotate Line Clockwise" text is tapped.
rotateClockwiseText.onTouchUp {
    animate {
        line.rotation += 3.14159/4
    }
}

// roate the line counter clockwise with animation when the "Rotate Line Counter Clockwise" text is tapped.
rotateCounterClockwiseText.onTouchUp {
    animate {
        line.rotation -= 3.14159/4
    }
}

//#-end-editable-code
//#-end-hidden-code
//#-editable-code Tap to enter code
let circle = Circle()
circle.draggable = true

//#-end-editable-code

//#-end-hidden-code
//#-editable-code Tap to enter code
// 1. Create a circle
let Secondcircle = Circle(radius: 3)
Secondcircle.center.y += 28

// 2. Create a rectangle
let rectangle = Rectangle(width: 10, height: 5, cornerRadius: 0.75)
rectangle.color = .purple
rectangle.center.y += 18

// 3. Create a line
let Secondline = Line(start: Point(x: -10, y: 9), end: Point(x: 10, y: 9), thickness: 0.5)
Secondline.center.y -= 2
Secondline.rotation = 170 * (3.14159/180)
Secondline.color = .yellow

// 4. Create text
let text = Text(string: "Hello world!", fontSize: 32.0, fontName: "Futura", color: .red)
text.center.y -= 2

// 5. Create an image
let image = Image(name: "SwiftBird", tint: .green)
image.size.width *= 0.5
image.size.height *= 0.5
image.center.y -= 11

// 6. Create a pattern with rectangles
let numRectangles = 4
var xOffset = Double((numRectangles/2) * (-1))
var yOffset = -26.0
let saturationEnd = 0.911
let saturationStart = 0.1
let saturationStride = (saturationEnd - saturationStart)/Double(numRectangles)

for i in 0...numRectangles {
    
    let rectangle = Rectangle(width: 10, height: 5, cornerRadius: 0.75)
    
    // set the color.
    let saturation = saturationEnd - (Double(numRectangles - i) * saturationStride)
    rectangle.color = Color(hue: 0.079, saturation: saturation, brightness: 0.934)
    
    // calculate the offset.
    rectangle.center = Point(x: xOffset, y: yOffset)
    xOffset += 1
    yOffset += 1
}

//#-end-editable-code
//#-end-hidden-code
//#-editable-code Tap to enter code
// create a circle and make it draggable.
let Thirdcircle = Circle(radius: 7.0)
Thirdcircle.color = Color.purple
Thirdcircle.draggable = true

// when the circle is touched, make it darker and give it a shadow.
Thirdcircle.onTouchDown {
    Thirdcircle.color = circle.color.darker()
    Thirdcircle.dropShadow = Shadow()
}

// when the touch ends on the circle, change its color to a random color.
Thirdcircle.onTouchUp {
    Thirdcircle.color = Color.random()
    Thirdcircle.dropShadow = nil
}

// jump the circle to the the point on the canvas that was touched.
Canvas.shared.onTouchUp {
    Thirdcircle.center = Canvas.shared.currentTouchPoints.first!
    Thirdcircle.dropShadow = Shadow()
}

//#-end-editable-code


