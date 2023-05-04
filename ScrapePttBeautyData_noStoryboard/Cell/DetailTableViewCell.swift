//
//  DetailTableViewCell.swift
//  ScrapePttBeautyData_noStoryboard
//
//  Created by Marcus.Fu on 2018/2/14.
//  Copyright © 2018年 Marcus.Fu. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import AVFoundation

class DetailTableViewCell: UITableViewCell {
    
    let picImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        else if imageUrl.hasSuffix("mp4") {
            guard let videoUrl = URL(string: imageUrl) else {return}
            let player = AVPlayer(url: videoUrl)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = picImageView.bounds
            contentView.layer.addSublayer(playerLayer)
            player.play()
            loopVideo(videoPlayer: player)
        }
        else {
            picImageView.sd_setImage(with: URL(string: imageUrl))
        }
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
    }
    
    func setConstraints() {
        NSLayoutConstraint(item: picImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: picImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
    }

}
