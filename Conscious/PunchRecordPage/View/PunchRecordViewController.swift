//
//  PunchRecordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/19.
//

import Foundation
import UIKit
import EventsCalendar

class PunchRecordViewController: UIViewController {

    lazy var monthCalendarView = {
        let view = MonthCalendarView(
            startDate: Date(fromFormattedString: "2023 01 01")!,
            endDate: Date(fromFormattedString: "2050 12 01")!
        )
        view.allowsDateSelection = true // default value: true
        view.selectedDate = Date()

        view.isPagingEnabled = true // default value: true
        view.scrollDirection = .horizontal // default value: .horizontal
        view.viewConfiguration = CalendarConfig() // default valut: .default
        view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
               view.scroll(to: Date(fromFormattedString: "2023 09 19")!, animated: false)
           }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(monthCalendarView)

        monthCalendarView.delegate = self

        NSLayoutConstraint.activate([
            monthCalendarView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            monthCalendarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            monthCalendarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            monthCalendarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -300)
        ])
    }
}

extension PunchRecordViewController: CalendarViewDelegate {

    func calendarView(_ calendarView: EventsCalendar.CalendarProtocol, didChangeSelectionDateTo date: Date, at indexPath: IndexPath) {
        print("selected")
        // TODO: 顯示當天日記
    }

    func calendarView(_ calendarView: CalendarProtocol,
                      eventDaysForCalendar type: CalendarViewType,
                      with calendarInfo: CalendarInfo,
                      and referenceDate: Date,
                      completion: @escaping (Result<Set<Int>, Error>) -> ()) {

        FirebaseManager.shared.fetchPunchRecord() { records, error in
            if let error = error {
                print("Error when fetch punch dates: \(error)")
                completion(.failure(error))
                return
            }

            guard let records = records else { return }

            let calendar = Calendar.current
            let punchDaysInMonth = records.compactMap { records -> Int? in
                let date = records.punchDate
                if calendar.isDate(date, equalTo: referenceDate, toGranularity: .month) {
                    return calendar.component(.day, from: date)
                }
                return nil
            }

            DispatchQueue.main.async {
                completion(.success(Set(punchDaysInMonth)))
            }

        }
    }
}
