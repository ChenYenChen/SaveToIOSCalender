//
//  ViewController.swift
//  SaveToCalander
//
//  Created by 陳彥辰 on 2017/5/1.
//  Copyright © 2017年 Ray. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let save = SaveCalender()
        // 新增活動
        save.save(eventName: "群組名稱", eventTitle: "活動名稱", starTime: Date(), endTime: Date())
        // 移除活動
        save.removeCalendar(eventName: "群組名稱", startTime: Date(), endTime: Date())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

