# SaveToIOSCalender
儲存活動至IOS行事曆

- 至info.plist 新增授權
```
  <key>NSCalendarsUsageDescription</key>
	<string>行事曆授權</string>
```

- 新增活動至IOS行事曆
```
let save = SaveCalender()
// 新增活動
save.save(eventName: "群組名稱", eventTitle: "活動名稱", starTime: Date(), endTime: Date())
```
- 移除已新增至IOS行事曆的活動
```
let save = SaveCalender()
// 新增活動
save.removeCalendar(eventName: "群組名稱", startTime: Date(), endTime: Date())
```
