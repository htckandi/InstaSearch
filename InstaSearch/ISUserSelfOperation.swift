//
//  ISUserSelfOperation.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

private let userSelfOperationName = "ISUserSelfOperation"

class ISUserSelfOperation: Operation {
    
    /// Глобальная функция запуска операции загрузки данных пользователя
    class func startOperation () {
        
        // Останавливаем все операции
        ISAssist.shared.apiQueue.cancelAllOperations()
        
        // Запускаем операцию загрузки данных пользователя
        ISAssist.shared.apiQueue.addOperation(ISUserSelfOperation())
    }

    override init() {
        super.init()
        
        name = userSelfOperationName
    }
    
    override func main() {
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Публикуем уведомление о начале загрузки данных пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.userSelfWillLoad, object: nil)
        }
        
        if isCancelled { return }
        
        // Готовим запрос к серверу
        if let urlRequest = ISAssist.shared.urlRequest(host: ISAssist.Rest.host,
                                                       path: ISAssist.Rest.usersSelfPath,
                                                       parameters: ["access_token": ISAssist.shared.accessToken!],
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
        
        // Получаем объект данных пользователя
        let userSelf = ISUserSelf(json: jsonData?["data"] as? [String: AnyObject])
        
        if isCancelled { return }
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Сохраняем объект данных пользователя
            ISAssist.shared.userSelf = userSelf
            
            // Публикуем уведомление о завершении загрузки данных пользователя
            NotificationCenter.default.post(name: ISAssist.Notifications.userSelfDidLoad, object: nil)
        }
    }
}
