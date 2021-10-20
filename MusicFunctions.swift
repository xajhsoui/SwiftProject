//
//  MusicFunctions.swift
//  SouIMusicPlayer
//
//  Created by cao on 2018/05/21.
//  Copyright © 2018年 com.soui. All rights reserved.
//

import Foundation
import UIKit

class MusicFunctions: NSObject {
    //传入 秒  得到  xx分钟xx秒
//    func numberOfSections(in tableView: UITableView) -> Int {
    static func getMMSSFromSS(totalTime: Int) -> String {

        //format of minute
        var str_minute = String.localizedStringWithFormat("%d", totalTime/60)
        if (str_minute.count == 1) {
            str_minute.insert("0", at: str_minute.startIndex)
        }
        //format of second
        var str_second = String.localizedStringWithFormat("%d", totalTime%60)
        if (str_second.count == 1) {
            str_second.insert("0", at: str_second.startIndex)
        }
        //format of time
        let format_time = String.localizedStringWithFormat("%@:%@", str_minute, str_second)
        
//        print("format_time : \(format_time)")
        return format_time;
    }
}


