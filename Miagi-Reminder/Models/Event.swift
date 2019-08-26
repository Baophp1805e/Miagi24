//
//  Event.swift
//  Miagi-Reminder
//
//  Created by apple on 8/16/19.
//  Copyright © 2019 apple. All rights reserved.
//

import Foundation

struct Event {
    var id: Int?
    var title:String?
    var describe:String?
    var city: String?
    var timeFrom:String?
    var timeTo:String?
    
    init(id: Int, title:String, describe:String, city:String, timeFrom: String, timeTo: String) {
        self.id = id
        self.title = title
        self.describe = describe
        self.city = city
        self.timeFrom = timeFrom
        self.timeTo = timeTo
    }
    
    //    override static func primaryKey() -> String? {
    //        return "id"
    //    }
    
    func toRealm() -> RealmEvent {
        let realmEvent = RealmEvent(id: self.id!, title: self.title!, describe: self.describe!, timeFrom: self.timeFrom!, timeTo: self.timeTo!, city: self.city!)
        return realmEvent
    }
}
