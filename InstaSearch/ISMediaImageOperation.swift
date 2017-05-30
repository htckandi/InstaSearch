//
//  ISMediaImageOperation.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 29.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

private let mediaImageOperationName = "ISMediaImageOperation"

class ISMediaImageOperation: Operation {
    
    /// Глобальная функция запуска операции загрузки изображения объекта медиа
    class func startOperation (object: ISMediaImage) {
        
        // Проверяем отсутствие подобной операции в потоке
        if !ISAssist.shared.apiQueue.containsOperation(forName: mediaImageOperationName + object.mediaId) {
            
            // Добавляем в поток новую операцию
            ISAssist.shared.apiQueue.addOperation(ISMediaImageOperation(object: object))
        }
    }
    
    /// Объект медиа, для которого загружается изображение
    var mediaImage: ISMediaImage

    init(object: ISMediaImage) {
        
        // Сохраняем объект медиа
        mediaImage = object
        
        super.init()
        
        // Задаем уникальное имя операции
        name = mediaImageOperationName + mediaImage.mediaId
    }
    
    override func main() {

        if isCancelled { return }
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Публикуем уведомление о завершении загрузки данных пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.mediaImageWillLoad, object: nil)
            
            // Отображаем индикатор активности сети
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        // Временное изображение
        var image: UIImage? = nil
        
        if isCancelled { return }
        
        // Получаем изображение
        if let objectLink = mediaImage.mediaImageStandartResolution,
            let objectUrl = URL(string: objectLink),
            let objectData = try? Data(contentsOf: objectUrl) {
            
            image = UIImage(data: objectData)
        }
        
        if isCancelled { return }
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Отображаем индикатор активности сети
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            // Сохраняем изображение профиля
            self.mediaImage.mediaStandartResolutionImage = image
            
            // Публикуем уведомление о завершении загрузки изображения медиа объекта
            NotificationCenter.default.post(name: ISAssist.Notifications.mediaImageDidLoad, object: nil, userInfo: ["objectId": self.mediaImage.mediaId])
        }
    }
}
