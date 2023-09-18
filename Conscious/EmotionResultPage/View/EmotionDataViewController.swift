//
//  EmotionResultViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/18.
//

import Foundation
import UIKit
import SwiftUI
import Charts

class EmotionDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = EmotionLineChartView()

        let hostingController = UIHostingController(rootView: swiftUIView)

        self.addChild(hostingController)

        hostingController.view.frame = self.view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

struct EmotionLineChartView: View {
    let emotionRecord = [EmotionRecord(emotionRecordID: UUID().uuidString, emotionScore: 32, date: Date()),
                         EmotionRecord(emotionRecordID: UUID().uuidString, emotionScore: 21, date: Date())]

    var body: some View {
        VStack {
            Chart {
                ForEach(emotionRecord) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.emotionScore))
                }
            }
            .frame(height: 300)
        }
    }
}
