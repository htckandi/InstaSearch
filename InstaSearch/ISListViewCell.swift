//
//  ISListViewCell.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISListViewCell: UICollectionViewCell {
    
    var mediaObject: ISMediaImage! {
        didSet {
        
            
            mediaUserNameLabel.text = mediaObject.mediaCaptionFromUserName
            
            if let time = mediaObject.mediaCaptionCreatedTime, let seconds = Int(time) {
                
                let interval = TimeInterval(seconds)
                let date = Date(timeIntervalSince1970: interval)
                
                let dateformatter = DateFormatter()
                dateformatter.doesRelativeDateFormatting = true
                dateformatter.dateStyle = .medium
                dateformatter.timeStyle = .short
                
                mediaDateLabel.text = dateformatter.string(from: date)
                
                
            }
            
            mediaTextLabel.text = mediaObject.mediaCaptionText
            
            mediaCommentsCountLabel.text = "Comments: \(mediaObject.mediaCommentsCount ?? 0)"
            
            mediaImage.image = mediaObject.mediaStandartResolutionImage
        }
    }
    
    @IBOutlet weak var mediaImage: UIImageView! {
        didSet {
            mediaImage.layer.backgroundColor = UIColor(red: 0.92, green: 0.94, blue: 0.94, alpha: 1).cgColor
        }
    }
    @IBOutlet weak var mediaUserNameLabel: UILabel!
    @IBOutlet weak var mediaDateLabel: UILabel!
    @IBOutlet weak var mediaTextLabel: UILabel!
    @IBOutlet weak var mediaCommentsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Добавляем обозреватели уведомлений
        NotificationCenter.default.addObserver(self, selector: #selector(mediaImageDidLoad(notification:)), name: ISAssist.Notifications.mediaImageDidLoad, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func mediaImageDidLoad (notification: Notification) {
        
        if let dict = notification.userInfo?["objectId"] as? String, dict == mediaObject.mediaId {
            mediaImage.image = mediaObject.mediaStandartResolutionImage
        }
    }
}
