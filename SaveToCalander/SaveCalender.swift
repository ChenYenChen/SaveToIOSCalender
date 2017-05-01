//
//  SaveCalender.swift
//  新增行程至IOS行事曆
//
//  Created by Ray on 2016/11/28.
//  Copyright © 2016年 RayMini. All rights reserved.
//

import EventKit

//儲存狀態
enum SaveCalenderState {
    case agree
    case disagree
    case finished
    case creash
}

//週期性
enum CalendarCycle {
    case weekly //每週
    case biweekly //雙週
    case monthly //每月
    case bimonthly //雙月
    case notRepeat //不重複
}

class SaveCalender: NSObject {
    
    private let eventStore = EKEventStore()
    var saveState: SaveCalenderState = .agree
    private var alarmTime:TimeInterval = 0
    private var cycleState: CalendarCycle = .notRepeat
    private var cycleEnd: Date?
    
    override init() {
        super.init()
        self.initializa()
    }
    /**
     移除行事曆已存在的活動
     - Parameter name: 儲存至行事曆的群組名稱
     - Parameter starTime: 活動開始時間
     - Parameter endTime: 活動結束時間
    */
    func removeCalendar(eventName name: String, startTime start: Date, endTime end: Date) {
        guard self.saveState == .agree else {
            print("未授權使用行事曆")
            return
        }
        
        guard let calendersName = self.getCalendarName(store: self.eventStore, eventName: name) else {
            print("沒有此群組的活動")
            return
        }
        
        let predicate = self.eventStore.predicateForEvents(withStart: start, end: end, calendars: [calendersName])
        let activity = self.eventStore.events(matching: predicate)
        for event in activity {
            do {
                try self.eventStore.remove(event, span: .thisEvent, commit: true)
            } catch {
                print("移除活動錯誤:\(error.localizedDescription)")
            }
        }
    }
    /**
     儲存活動至行事曆
     - Parameter name: 儲存至行事曆的群組名稱
     - Parameter title: 活動標題
     - Parameter starTime: 活動開始時間
     - Parameter endTime: 活動結束時間
     - Parameter calendarCycle: 活動週期
     - Parameter cycleEndDate: 週期結束日期
     */
    func save(eventName name: String, eventTitle title: String, starTime star: Date, endTime end: Date, calendarCycle cycle: CalendarCycle = .notRepeat, cycleEndDate cycleEnd: Date = Date()) {
        self.cycleState = cycle
        self.cycleEnd = cycleEnd
        if self.saveState == .agree {
            self.calenderName(store: self.eventStore, eventName: name, eventTitle: title, starTime: star, endTime: end, eventLocal: "")
        }
    }
    /**
     儲存活動至行事曆
     - Parameter name: 儲存至行事曆的群組名稱
     - Parameter title: 活動標題
     - Parameter starTime: 活動開始時間
     - Parameter endTime: 活動結束時間
     - Parameter eventLocal: 活動地點
     - Parameter calendarCycle: 活動週期
     - Parameter cycleEndDate: 週期結束日期
     */
    func save(eventName name: String, eventTitle title: String, starTime star: Date, endTime end: Date, eventLocal local: String, calendarCycle cycle: CalendarCycle = .notRepeat, cycleEndDate cycleEnd: Date = Date()) {
        self.cycleState = cycle
        self.cycleEnd = cycleEnd
        if self.saveState == .agree {
            self.calenderName(store: self.eventStore, eventName: name, eventTitle: title, starTime: star, endTime: end, eventLocal: local)
        }
    }
    /**
     儲存活動至行事曆
     - Parameter name: 儲存至行事曆的群組名稱
     - Parameter title: 活動標題
     - Parameter starTime: 活動開始時間
     - Parameter endTime: 活動結束時間
     - Parameter alarmTime: 活動提醒時間
     - Parameter calendarCycle: 活動週期
     - Parameter cycleEndDate: 週期結束日期
     */
    func save(eventName name: String, eventTitle title: String, starTime star: Date, endTime end: Date, alarmTime: TimeInterval, calendarCycle cycle: CalendarCycle = .notRepeat, cycleEndDate cycleEnd: Date = Date()) {
        self.cycleState = cycle
        self.cycleEnd = cycleEnd
        if self.saveState == .agree {
            self.alarmTime = alarmTime
            self.calenderName(store: self.eventStore, eventName: name, eventTitle: title, starTime: star, endTime: end, eventLocal: "")
        }
    }
    /**
     儲存活動至行事曆
     - Parameter name: 儲存至行事曆的群組名稱
     - Parameter title: 活動標題
     - Parameter starTime: 活動開始時間
     - Parameter endTime: 活動結束時間
     - Parameter eventLocal: 活動地點
     - Parameter alarmTime: 活動提醒時間
     - Parameter calendarCycle: 活動週期
     - Parameter cycleEndDate: 週期結束日期
     */
    func save(eventName name: String, eventTitle title: String, starTime star: Date, endTime end: Date, eventLocal local: String, alarmTime: TimeInterval, calendarCycle cycle: CalendarCycle = .notRepeat, cycleEndDate cycleEnd: Date = Date()) {
        self.cycleState = cycle
        self.cycleEnd = cycleEnd
        if self.saveState == .agree {
            self.alarmTime = alarmTime
            self.calenderName(store: self.eventStore, eventName: name, eventTitle: title, starTime: star, endTime: end, eventLocal: local)
        }
    }
    
    //初始化
    private func initializa() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            //print("authorized")
            self.saveState = .agree
            break
        case .denied:
            //print("denied")
            self.saveState = .disagree
            break
        case .notDetermined:
            //print("notDetermined")
            self.eventStore.requestAccess(to: .event, completion: { (open, error) in
                if open {
                    self.saveState = .agree
                } else {
                    self.saveState = .disagree
                }
            })
            break
        default:
            print("Case Default")
        }
    }
    
    //根據群組新增活動
    private func calenderName(store: EKEventStore, eventName name: String, eventTitle title: String, starTime star: Date, endTime end: Date, eventLocal local: String) {
        
        guard self.saveState == .agree else {
            print("未授權")
            return
        }
        
        if let calendersName = self.getCalendarName(store: store, eventName: name) {
            // 根據標題及時間判斷此活動是否已存在過
            guard !self.checkActivity(store: store, calender: calendersName, eventTitle: title, starTime: star, endTime: end) else {
                print("已有此活動")
                return
            }
            // 新增活動
            self.addEvent(store: store,calender: calendersName, eventTitle: title, starTime: star, endTime: end, eventLocal: local)
        } else {
            // 建立新的群組
            self.creatNewCalendarName(store: store, eventName: name)
            // 建立完成後再新增
            self.calenderName(store: store, eventName: name, eventTitle: title, starTime: star, endTime: end, eventLocal: local)
        }
    }
    
    // 判斷是否已有此群組名稱
    private func checkCalender(store: EKEventStore, eventName name: String) -> Bool {
        guard self.saveState == .agree else {
            print("未授權")
            return false
        }
        let calenders = store.calendars(for: .event)
        var isHaveEventName = true
        // 判斷是否已有此群組名稱 及 此群組位於的位置
        for i in 0..<calenders.count {
            if calenders[i].title == name {
                isHaveEventName = true
                break
            } else {
                isHaveEventName = false
            }
        }
        
        return isHaveEventName
    }
    // 取得群組名稱
    private func getCalendarName(store: EKEventStore, eventName name: String) -> EKCalendar? {
        guard self.saveState == .agree else {
            return nil
        }
        let calenders = store.calendars(for: .event)
        for i in 0..<calenders.count {
            if calenders[i].title == name {
                return calenders[i]
            }
        }
        return nil
    }
    
    // 建立新的群組
    private func creatNewCalendarName(store: EKEventStore, eventName name: String) {
        let newCalender = EKCalendar(for: .event, eventStore: store)
        
        newCalender.title = name
        
        let sourceInEventStore = eventStore.sources
        
        newCalender.source = sourceInEventStore.filter({ (soure) -> Bool in
            soure.sourceType.rawValue == EKSourceType.local.rawValue
        }).first!
        do {
            try store.saveCalendar(newCalender, commit: true)
        } catch {
            print("新增群組錯啥: \(error.localizedDescription)")
        }
    }
    
    // 檢查是否有重複的活動名稱
    private func checkActivity(store: EKEventStore, calender: EKCalendar, eventTitle title: String, starTime star: Date, endTime end: Date) -> Bool {
        let get = store.events(matching: store.predicateForEvents(withStart: star, end: end, calendars: [calender]))
        for name in get {
            if name.title == title {
                return true
            }
        }
        return false
    }
    
    //添加行程
    private func addEvent(store: EKEventStore, calender: EKCalendar, eventTitle title: String, starTime star: Date, endTime end: Date, eventLocal local: String) {
        let event = EKEvent(eventStore: store)
        
        guard title != "" else {
            print("沒有標題")
            return
        }
        event.title = title
        event.startDate = star
        event.endDate = end
        event.calendar = calender
        
        if self.alarmTime != 0 {
            let alarm = EKAlarm(relativeOffset: self.alarmTime)
            event.addAlarm(alarm)
        }
        
        if local != "" {
            event.location = local
        }
        
        if self.cycleState != .notRepeat {
            var recurrence:EKRecurrenceRule = EKRecurrenceRule()
            switch self.cycleState {
            case .weekly:
                recurrence = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: EKRecurrenceEnd(end: self.cycleEnd!))
                break
            case .biweekly:
                recurrence = EKRecurrenceRule(recurrenceWith: .weekly, interval: 2, end: EKRecurrenceEnd(end: self.cycleEnd!))
                break
            case .monthly:
                recurrence = EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: EKRecurrenceEnd(end: self.cycleEnd!))
                break
            default:
                recurrence = EKRecurrenceRule(recurrenceWith: .monthly, interval: 2, end: EKRecurrenceEnd(end: self.cycleEnd!))
                break
            }
            event.recurrenceRules?.append(recurrence)
        }
        
        do {
            try store.save(event, span: EKSpan.thisEvent)
            self.saveState = .finished
        } catch {
            print("新增活動錯誤: \(error.localizedDescription)")
            self.saveState = .creash
        }
    }
}
