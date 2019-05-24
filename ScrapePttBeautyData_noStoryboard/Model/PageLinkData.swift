//
//  PageLinkData.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by marcus fu on 2019/5/23.
//  Copyright © 2019 Marcus.Fu. All rights reserved.
//

import Foundation

class PageLinkData {
    var title: String
    var url: String
    init(_ title: String = "", url: String = "") {
        self.title = title
        self.url = url
    }
}
