//
//  PlaygroundSetup.swift
//  Charts
//

import UIKit
import PlaygroundSupport

class ChartViewController: UIViewController {
    
    override func loadView() {
        self.view = Chart.shared.chartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let chartView = view as? ChartView {
//            chartView.safeAreaLayoutGuide = liveViewSafeAreaGuide
//        }
    }
    
}

public func _setup() {
    PlaygroundPage.current.liveView = ChartViewController()
}
