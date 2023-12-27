//
//  PunchRecordViewController.swift
//  Conscious
//
//  Created by jeff on 2023/9/19.
//

import Combine
import EventsCalendar
import Foundation
import UIKit

class PunchRecordViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    lazy var newCalenderButton = {
        let button = UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(showCodeCalendar))
        return button
    }()

    lazy var monthCalendarView = {
        let view = MonthCalendarView(
            startDate: Date(fromFormattedString: "2023 01 01")!,
            endDate: Date(fromFormattedString: "2050 12 01")!
        )
        view.allowsDateSelection = true // default value: true
        view.selectedDate = Date()

        view.isPagingEnabled = true // default value: true
        view.scrollDirection = .horizontal // default value: .horizontal
        if let lightColor = UIColor.B3,
           let darkColor = UIColor.B2
        {
            view.viewConfiguration = CalendarConfig(selectionColor: lightColor,
                                                    dotColor: darkColor,
                                                    selectedDotColor: darkColor,
                                                    weekdayTitleColor: darkColor)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            view.scroll(to: Date(fromFormattedString: "2023 09 19")!, animated: false)
        }
        return view
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var viewModel = {
        let viewModel = PunchRecordViewModel()
//        viewModel.$punchRecord
//            .sink { [weak self] record in
//                // 只要最後一筆資料即可
//                if let consecutiveDays = record.last?.consecutiveDays {
//                    self?.currentStreakLabel.text = "\(consecutiveDays)"
//                }
//            }.store(in: &cancellables)
        return viewModel
    }()

    lazy var currentStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = .white
        return label
    }()

    lazy var highestStreakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 50)
        label.textColor = .white
        return label
    }()

    override func viewWillAppear(_: Bool) {
        viewModel.fetchPunchRecord()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        print("Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] record in
                    if let consecutiveDays = record.last?.consecutiveDays,
                       let highestDay = record.last?.highestDay
                    {
                        self?.currentStreakLabel.text = "\(consecutiveDays)"
                        self?.highestStreakLabel.text = "\(highestDay)"
                    }
                }
            )
            .store(in: &cancellables)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = newCalenderButton

        view.addSubview(monthCalendarView)

        monthCalendarView.delegate = self

        let texts = ["Current Streak", "Highest Streak"]
        let labels = [currentStreakLabel, highestStreakLabel]

        for index in 0 ..< 2 {
            let view = UIView()
            view.backgroundColor = .B3
            view.csBornerRadius = 15

            let titleLabel = UILabel()
            titleLabel.text = texts[index]
            titleLabel.textColor = .white
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let numberLabel = labels[index]
            numberLabel.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(titleLabel)
            view.addSubview(numberLabel)

            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),

                numberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                numberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16),
            ])

            stackView.addArrangedSubview(view)
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            monthCalendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            monthCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthCalendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300),

            stackView.topAnchor.constraint(equalTo: monthCalendarView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
        ])
    }
}

extension PunchRecordViewController: CalendarViewDelegate {
    func calendarView(_: EventsCalendar.CalendarProtocol, didChangeSelectionDateTo _: Date, at _: IndexPath) {
        print("selected")
        // TODO: 顯示當天日記
    }

    func calendarView(_: CalendarProtocol,
                      eventDaysForCalendar _: CalendarViewType,
                      with _: CalendarInfo,
                      and referenceDate: Date,
                      completion: @escaping (Result<Set<Int>, Error>) -> Void)
    {
        FirebaseManager.shared.fetchPunchRecord { records, error in
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

    @objc func showCodeCalendar() {
        let codeCalendarVC = CodeCalendarViewController()
        navigationController?.pushViewController(codeCalendarVC, animated: false)
    }
}
