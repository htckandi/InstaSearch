//
//  ISUserSelfMediaRecentOperation.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 29.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

private let userSelfMediaRecentOperationName = "ISUserSelfMediaRecentOperation"

class ISUserSelfMediaRecentOperation: Operation {
    
    /// Глобальная функция запуска операции загрузки изображений пользователя
    class func startOperation () {
        
        // Проверяем отсутствие подобной операции в потоке
        if !ISAssist.shared.apiQueue.containsOperation(forName: userSelfMediaRecentOperationName) {
            
            // Добавляем в поток новую операцию
            ISAssist.shared.apiQueue.addOperation(ISUserSelfMediaRecentOperation())
        }
    }
    
    override init() {
        super.init()
        
        name = userSelfMediaRecentOperationName
    }
    
    override func main() {
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Публикуем уведомление о начале заггрузки изображений пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.mediaWillLoad, object: nil)
        }
        
        if isCancelled { return }
        
        // Готовим параметры запроса
        // Количество загружаемых изображений устанавливаем 4 с целью lazy load
        var urlRequestParametres = ["access_token": ISAssist.shared.accessToken!, "count": "4"]
        
        // Определяем следующий массив изображений
        if let maxId = ISAssist.shared.userSelf?.userLastMediaId {
            urlRequestParametres["max_id"] = maxId
        }
        
        // Готовим запрос к серверу
        if let urlRequest = ISAssist.shared.urlRequest(host: ISAssist.Rest.host,
                                                       path: ISAssist.Rest.userSelfMediaRecentPath,
                                                       parameters: urlRequestParametres,
                                                       httpMethod: nil) {
            
            if isCancelled { return }
            
            
            
            // Осуществляем запрос к серверу
            ISAssist.shared.dataTask(request: urlRequest, handler: completionHandler).resume()
            
        } else {
            
            // Завершаем операцию
            completionHandler(jsonData: nil)
        }
    }
    
    /// Обрабатывает полученный json
    func completionHandler (jsonData: [String: AnyObject]?) {
        
        if isCancelled { return }
        
        // Создаем массив новых объектов
        var newMediaImages = [ISMediaImage]()
        
        // Проверяем наличие новых объектов
        if let objects = jsonData?["data"] as? [[String: AnyObject]] {
            
            for object in objects {
                
                // Получаем новый объект медиа
                if let newMediaImage = ISMediaImage(json: object) {
                    
                    // Добавляем новый объект медиа к массиву
                    newMediaImages.append(newMediaImage)
                    
                    // Запускаем операцию загрузки изображения
                    // ISMediaImageOperation.startOperation(object: newMediaImage)
                    
                    // Переходим в главный поток
                    DispatchQueue.main.async {
                        
                        // Подгружаем картинку медиа объекта
                        ISMediaImageOperation.startOperation(object: newMediaImage)
                    }
                }
            }
            
            // Сортируем массив новых объектов
            newMediaImages = newMediaImages.sorted{ $0.mediaId! > $1.mediaId! }
        }
        
        if isCancelled { return }
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            if ISAssist.shared.userSelf?.userMediaImages != nil {
                
                ISAssist.shared.userSelf!.userMediaImages!.append(contentsOf: newMediaImages)
                
            } else {
                
                ISAssist.shared.userSelf!.userMediaImages = newMediaImages
            }
            
            // Публикуем уведомление о завершении загрузки данных пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.mediaDidLoad, object: nil)
        }
    }
}
