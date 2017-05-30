//
//  ISUserSelfProfileImageOperation.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

private let userSelfProfileImageOperationName = "ISUserSelfProfileImageOperation"

class ISUserSelfProfileImageOperation: Operation {
    
    /// Глобальная функция запуска операции загрузки изображения профиля
    class func startOperation () {
        ISAssist.shared.apiQueue.addOperation(ISUserSelfProfileImageOperation())
    }

    override init() {
        super.init()
        name = userSelfProfileImageOperationName
    }
    
    override func main() {
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Публикуем уведомление о завершении загрузки данных пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.profilePictureWillLoad, object: nil)
            
            // Отображаем индикатор активности сети
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        // Временное изображение
        var image: UIImage? = nil
        
        if isCancelled { return }
        
        // Получаем изображение
        if let imageLink = ISAssist.shared.userSelf?.userProfilePicture,
           let imageUrl = URL(string: imageLink),
           let imageData = try? Data(contentsOf: imageUrl) {
            
            image = UIImage(data: imageData)
        }
        
        if isCancelled { return }
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Отображаем индикатор активности сети
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // Сохраняем изображение профиля
            ISAssist.shared.userSelf?.userProfileImage = image
            
            // Публикуем уведомление о завершении загрузки изображения профиля
            NotificationCenter.default.post(name: ISAssist.Notifications.profilePictureDidLoad, object: nil)
        }
    }
}
