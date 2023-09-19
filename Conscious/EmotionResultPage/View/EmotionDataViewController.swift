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
import Combine

class EmotionDataViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var emotionData: [EmotionRecord] = []

    private var canAddNewRecord: Bool?

    lazy var viewModel = EmotionDataViewModel()

    private var cancellables = Set<AnyCancellable>()

    @IBAction func createButtonTapped(_ sender: UIButton) {
        if let canAddNewRecord = canAddNewRecord, canAddNewRecord == false {
            showOverrideAlert()
        }
    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.canAddNewEmotionRecord()

        viewModel.fetchEmotionRecords()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }, receiveValue: { data in
                    self.emotionData = data
                    print(data)
                }
            ).store(in: &cancellables)

        viewModel.$canAddNewRecord
            .sink { canAddNewRecord in
                self.canAddNewRecord = canAddNewRecord
            }
            .store(in: &cancellables)

        viewModel.$currentViewingMonth
            .sink { newMonth in
                print("---")
                print(newMonth)
                self.dateLabel.text = String(describing: newMonth)
            }
            .store(in: &cancellables)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = EmotionLineChartView(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: swiftUIView)

        self.addChild(hostingController)

        //        hostingController.view.frame = self.view.bounds
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])

        hostingController.didMove(toParent: self)

        self.view.bringSubviewToFront(createButton)
        self.view.bringSubviewToFront(dateLabel)
    }

    func showOverrideAlert() {
        let alert = UIAlertController(title: "本週已有資料存在", message: "確定要覆蓋本週資料嗎？", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            self.viewModel.deleteCurrentWeekEmotionRecord()
            self.performSegue(withIdentifier: "showSurveySegue", sender: self)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

}

struct EmotionLineChartView: View {

    @ObservedObject var viewModel: EmotionDataViewModel

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.currentMonthRecords) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Score", item.emotionScore))
                }
            }
            .frame(height: 300)
        }
        .gesture(
            DragGesture()
                .onEnded { value in // 判斷位移量
                    let horizontalValue = value.translation.width
                    let verticalValue = value.translation.height

                    if abs(horizontalValue) > abs(verticalValue) {
                        if horizontalValue > 0 {
                            viewModel.switchToPreviousMonth()
                        } else {
                            viewModel.switchToNextMonth()
                        }
                    }
                }
        )
    }
}
