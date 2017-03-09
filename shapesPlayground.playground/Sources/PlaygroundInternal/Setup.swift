import UIKit
import PlaygroundSupport

public func _setup() {
    let viewController = UIViewController()
    viewController.view = Canvas.shared.backingView
    PlaygroundPage.current.liveView = viewController
}
