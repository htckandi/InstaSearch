//
//  ISListViewHeader.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISListViewHeader: UICollectionReusableView {
    
    @IBOutlet weak var userProfileImage: UIImageView! {
        didSet {
            userProfileImage.layer.cornerRadius = userProfileImage.bounds.width * 0.5
            userProfileImage.layer.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1).cgColor
        }
    }
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userMediaCountLabel: UILabel!
    @IBOutlet weak var userFollowsCountLabel: UILabel!
    @IBOutlet weak var userFollowedCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Добавляем обозреватели уведомлений
        NotificationCenter.default.addObserver(self, selector: #selector(profilePicturedidLoad(notification:)), name: ISAssist.Notifications.profilePictureDidLoad, object: nil)
    }
    
    deinit {
        
        // Удаляем обозреватели уведомлений
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Заполняет текстовые данные
    func configureView () {
        
        let userSelf = ISAssist.shared.userSelf
        
        userFullNameLabel.text = userSelf?.userFullName
        userNameLabel.text = userSelf?.userName
        userMediaCountLabel.text = "\(userSelf?.userCountsMedia ?? 0)"
        userFollowsCountLabel.text = "\(userSelf?.userCountsFollows ?? 0)"
        userFollowedCountLabel.text = "\(userSelf?.userCountsFollowedBy ?? 0)"
        userProfileImage.image = userSelf?.userProfileImage
        
        setProfileImage()
    }
    
    /// Обработка уведомления о завершении загрузки изображения профиля
    func profilePicturedidLoad (notification: Notification) {
        setProfileImage()
    }
    
    func setProfileImage () {
        userProfileImage.image = ISAssist.shared.userSelf?.userProfileImage
    }
}
