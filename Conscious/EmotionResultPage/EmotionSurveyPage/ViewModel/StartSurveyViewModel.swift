//
//  StartSurveyViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/9/26.
//

import Combine
import Foundation
import UIKit

class StartSurveyViewModel: ObservableObject {
    @Published var startColor: UIColor = .red
    @Published var endColor: UIColor = .blue
}
