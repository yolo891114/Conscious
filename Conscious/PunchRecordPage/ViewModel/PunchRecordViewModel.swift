//
//  PunchRecordViewModel.swift
//  Conscious
//
//  Created by jeff on 2023/10/2.
//

import Foundation
import Combine

class PunchRecordViewModel {

    @Published var punchRecord: [PunchRecord] = []

    func fetchPunchRecord() -> Future<[PunchRecord],Error> {
        return Future { promise in
            FirebaseManager.shared.fetchPunchRecord { record, error in
                if let error = error {
                    print("Error when fecthing punch records")
                    promise(.failure(error))
                }

                if let record = record {
                    self.punchRecord = record
                    print("record:")
                    print(record)
                    promise(.success(record))
                }
            }
        }
    }
}
