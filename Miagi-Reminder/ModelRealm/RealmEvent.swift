//
//  RealmEvent.swift
//  Miagi-Reminder
//
//  Created by apple on 8/21/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation
import RealmSwift


class RealmEvent: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var describe = ""
    @objc dynamic var timeFrom = ""
    @objc dynamic var timeTo = ""
    @objc dynamic var city = ""
    
    convenience init( id: Int, title: String, describe: String, timeFrom: String, timeTo: String, city: String) {
        self.init()
        self.id = id
        self.title = title
        self.describe = describe
        self.timeFrom = timeFrom
        self.timeTo = timeTo
        self.city = city
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    func toModel() -> Event {
        let event = Event(id: self.id, title: self.title, describe: self.describe, city: self.city, timeFrom: self.timeFrom, timeTo: self.timeTo)
        return event
    }
}
