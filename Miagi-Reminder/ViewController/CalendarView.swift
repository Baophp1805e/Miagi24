//
//  CalendarView.swift
//  Miagi-Reminder
//
//  Created by apple on 8/13/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var firstDayOfTheMonth: Date! {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
    }
}

protocol CalendarViewDataSource {
    func showDotForDate(_ date: Date) -> Bool
}

protocol CalendarViewDelegate {
    func canSelectDate(_ date: Date) -> Bool
    func didSelectDate(_ date: Date)
    
}

class CalendarCellView: UIView {
    var date: Date! {
        didSet {
            self.textLabel.text = "\(Calendar.current.dateComponents([.day], from: self.date).day!)"
        }
    }
    
    let textLabel: UILabel!
    let detailLabel: UILabel!
    
    var selected = false {
        didSet {
            self.backgroundColor = self.selected ? UIColor.init(white: 0.95, alpha: 1.0) : .white
        }
    }
    
//    var eventCalendar = false {
//        didSet {
//            self.backgroundColor = self.eventCalendar ? UIColor.init(white: 0.95, alpha: 1.0) : .white
//        }
//    }
    
    static var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    init() {
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.adjustsFontSizeToFitWidth = true
        self.textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        self.textLabel.textAlignment = .center
        
        self.detailLabel = UILabel(frame: CGRect.zero)
        self.detailLabel.adjustsFontSizeToFitWidth = true
        self.detailLabel.font = UIFont.boldSystemFont(ofSize: 10)
        self.detailLabel.textAlignment = .center
        
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.textLabel)
        self.addSubview(self.detailLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel.frame = self.bounds
        
        self.detailLabel.frame = CGRect(x: 0, y: self.bounds.size.height/2, width: self.bounds.size.width, height: self.bounds.size.height/2)
    }
}

class CalendarView : UIView {
    var dataSource: CalendarViewDataSource?
    var delegate: CalendarViewDelegate?
    var time: String?{
        didSet {
            parentView?.dateLabel.text = time
        }}
    var parentView: ViewController?
    var event: Event!
    var currentDate: Date! {
        didSet {
            for cell in cells {
                cell.selected = false
            }
        }
    }
    
    var selectedDate: Date? {
        didSet {
            guard let sd = self.selectedDate else {
                for cell in cells {
                    cell.selected = false
                }
                return
            }
            
            for cell in cells {
                cell.selected = Calendar.current.compare(sd, to: cell.date, toGranularity: .day) == .orderedSame
            }
            
            delegate?.didSelectDate(sd)
        }
    }
    
    var cells: [CalendarCellView]!
    var monthLabel: UILabel!
    var weekdayLabels: [UILabel]!
    var dotColor: UIColor = .red

    var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM/YYYY"
        return f
    }
    
    var weekdayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f
    }
    
    override func awakeFromNib() {
        
        monthLabel = UILabel(frame: CGRect.zero)
        monthLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        monthLabel.adjustsFontSizeToFitWidth = true
        monthLabel.textAlignment = .center
        self.addSubview(monthLabel)
        
        // We always show Sunday to Saturday left to right
        
        weekdayLabels = [UILabel]()
        for _ in 0..<7 {
            let lbl = UILabel(frame: CGRect.zero)
            lbl.font = UIFont.systemFont(ofSize: 10)
            lbl.adjustsFontSizeToFitWidth = true
            lbl.textAlignment = .center
            lbl.textColor = .lightGray
            self.addSubview(lbl)
            weekdayLabels.append(lbl)
        }
        
        // We always show 6 weeks as some months will require it.
        
        cells = [CalendarCellView]()
        for i in 0..<42 {
            let cell = CalendarCellView()
            cell.tag = i
            
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            tapGR.numberOfTapsRequired = 1
            tapGR.numberOfTouchesRequired = 1
            cell.addGestureRecognizer(tapGR)
            
            cells.append(cell)
            self.addSubview(cell)
        }
        currentToday()
        
    }
    
    //MARK: btnToday
    @objc func currentToday() {
        let today = Date()
        currentDate = today
        layoutIfNeeded()
        selectedDate = today
        setNeedsLayout()
    }
    
    //MARK: Click Back
    @objc func advanceOneMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
        setNeedsLayout()
    }
    //MARK: Click Next
    @objc func rewindOneMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)
        setNeedsLayout()
    }
    
    @objc func didTap(_ recognizer: UITapGestureRecognizer) {
        guard let cellView = recognizer.view as? CalendarCellView else { return }
        
        let date = cellView.date!
        
        if delegate?.canSelectDate(date) ?? true {
            selectedDate = date
        }
    }
    
    override func layoutSubviews() {
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy HH:mm"
//        let minDate:Date! = formatter.date(from: data.timeFrom!)
//        guard let min = minDate else {
//            return
//        }
        
        super.layoutSubviews()
        
        time =  monthFormatter.string(from: currentDate)
        
        let firstWeekday = currentDate.firstDayOfTheMonth.weekday
        var cellDate = Calendar.current.date(byAdding: .day, value: -firstWeekday + 1, to: currentDate.firstDayOfTheMonth)!
        for i in 0..<7 {
            let weekdayDate = Calendar.current.date(byAdding: .day, value: i, to: cellDate)!
            let lbl = weekdayLabels[i]
            lbl.text = weekdayFormatter.string(from: weekdayDate)
        }
        
        let monthNameHeight: CGFloat = 30
        let weekdayHeight: CGFloat = 10
        let headerHeight: CGFloat = monthNameHeight + weekdayHeight
        let columnCount: CGFloat = 7
        let rowCount: CGFloat = 6
        let cellWidth = round(self.bounds.size.width / columnCount)
        let cellHeight = round((self.bounds.size.height - headerHeight) / rowCount)
        var left: CGFloat = 0
        var top: CGFloat = headerHeight
        
        for i in 0..<Int(columnCount) {
            let lbl = weekdayLabels[i]
            lbl.frame = CGRect(x: left, y: monthNameHeight, width: cellWidth, height: weekdayHeight)
            left += cellWidth
        }
        
        left = 0
        var index = 0
       
        
        for _ in 0..<Int(rowCount) {
            for _ in 0..<Int(columnCount) {
               
                let cell = cells[index]
                
                cell.date = cellDate
                
                cell.frame = CGRect(x: left, y: top, width: cellWidth, height: cellHeight)
                left += cellWidth
                
                if Calendar.current.isDate(cellDate, equalTo: currentDate, toGranularity: .month) {
                    cell.textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
                    cell.textLabel.textColor = .black
                } else {
                    cell.textLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
                    cell.textLabel.textColor = .lightGray
                }
                cell.detailLabel.textColor = dotColor
                cell.detailLabel.text = (dataSource?.showDotForDate(cellDate) ?? false) ? "•" : nil
                
                index += 1
                
                cellDate = Calendar.current.date(byAdding: .day, value: 1, to: cellDate)!
            }
            
            left = 0
            top += cellHeight
        }
    }
}
