//
//  PhysicsCatagory.swift
//
//  Copyright (c) 2016 Apple Inc. All Rights Reserved.
//

import Foundation

enum PhysicsCategory {
    static let None     : UInt32 = 0
    static let Wall     : UInt32 = 0b001
    static let Ball     : UInt32 = 0b010
    static let Brick    : UInt32 = 0b011
    static let Paddle   : UInt32 = 0b100
}
