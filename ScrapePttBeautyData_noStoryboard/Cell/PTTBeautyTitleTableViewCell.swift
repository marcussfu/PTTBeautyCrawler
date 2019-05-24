//
//  PTTBeautyTitleTableViewCell.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by marcus fu on 2019/5/22.
//  Copyright © 2019 Marcus.Fu. All rights reserved.
//


import UIKit

extension UITableViewCell {
    func configure(title: String) {
        textLabel?.text = title
        backgroundColor = .black
        textLabel?.textColor = .white
    }
}
