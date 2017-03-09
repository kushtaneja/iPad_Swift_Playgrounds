//: Playground - noun: a place where people can play

import PlaygroundSupport

let page = PlaygroundPage.current

page.liveView = SpiralViewController(initialRoulette: Roulette.hypocycloid())
