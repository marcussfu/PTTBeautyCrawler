//
//  DetailTableViewCell.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by Marcus.Fu on 2018/2/14.
//  Copyright © 2018年 Marcus.Fu. All rights reserved.
//

import UIKit
import SDWebImage

class DetailTableViewCell: UITableViewCell {
    
    let picImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .black
        selectionStyle = .none
        
        picImageView.tag = 1
        picImageView.contentMode = .scaleAspectFit
        picImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(picImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
    }
    
    func configure(_ imageUrl: String) {
        picImageView.image = nil
        if imageUrl.hasSuffix("gif") {
            picImageView.loadGif(url: imageUrl)
        }
        else {
            picImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint(item: picImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
    }

}
