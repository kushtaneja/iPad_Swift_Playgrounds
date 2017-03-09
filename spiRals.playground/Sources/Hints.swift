//
//  Hints.swift
//
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import Foundation

public enum Hints {
    /// These hints apply to every page in the playground
    public static let negativeValueHint = NSLocalizedString("Using negative values makes your circles and your spoke draw themselves in the opposite direction they otherwise would, which can create some confusing images. Try using positive values everywhere.", comment: "Hint for using a negative value for a radius")
    public static let similarRadiiHint = NSLocalizedString("When you choose a similar value for both `wheelRadius` and `trackRadius`, the wheel moves very slowly within the track, and the path is hard to see. If you choose the same radius for both, the wheel can't move at all.", comment: "Hint for setting wheelRadius as 99% or greater of trackRadius")
    public static let straightLineHint = NSLocalizedString("Were you expecting a straight line? When you set `wheelRadius` to exactly half of `trackRadius` with a cycloid-type object, the spoke always remains in the middle of the track.", comment: "Hint for drawing straight line")
    public static let zeroHint = NSLocalizedString("It looks like you've entered `0` for one of your values. A circle with radius `0`, or a line with length `0`, isn't visible. Try using values from `1.0` to `10.0`.", comment: "Hint for zero values")
    public static let disparateValuesHint = NSLocalizedString("When you choose radius values that are far apart from one another, some of the elements can be difficult to see. Try using values that are closer together.", comment: "Hint for disparate values")
    public static let edgeCaseSuccess = NSLocalizedString("Interesting! Trying unusual values can sometimes lead to unexpected results, and that's a really important part of software testing. You're a natural 😊. Ready for the [next page](@next)?", comment: "Success message for using an edge case")
}
