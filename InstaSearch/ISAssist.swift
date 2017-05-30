//
//  ISAssist.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISAssist: NSObject {

    /// Методы Instagram API
    struct Rest {
        
        static let host = "api.instagram.com"
        static let authPath = "/oauth/authorize/"
        static let usersSelfPath = "/v1/users/self/"
        static let userSelfMediaRecentPath = "/v1/users/self/media/recent/"
    }
    
    /// Данные авторизации
    struct Auth {
        
        static let clientId = "3c8db7904d964b1785c614b3fb2e849f"
        static let redirectUri = "http://testUserMoscow.wordpress.com"
    }
    
    /// Имена уведомлений
    struct Notifications {
        
        static let userSelfWillLoad = Notification.Name("ISUserSelfWillLoadNotification")
        static let userSelfDidLoad = Notification.Name("ISUserSelfDidLoadNotification")
        static let profilePictureWillLoad = Notification.Name("ISProfilePictureWillLoadNotification")
        static let profilePictureDidLoad = Notification.Name("ISProfilePictureDidLoadNotification")
        static let mediaWillLoad = Notification.Name("ISMediaOperationWillLoadNotification")
        static let mediaDidLoad = Notification.Name("ISMediaOperationDidLoadNotification")
        static let mediaImageWillLoad = Notification.Name("ISMediaImageOperationWillLoadNotification")
        static let mediaImageDidLoad = Notification.Name("ISMediaImageOperationDidLoadNotification")
    }
    
    /// Перечень http методов
    enum HttpMethod: String {
        case Get = "GET", Post = "POST"
    }
    
    /// Instagram API assist singleton
    static let shared = ISAssist()
       
    /// Instagram API queue
    let apiQueue = ISApiQueue()
    
    /// Instagram API acess token
    var accessToken: String? {
        didSet {
            ISUserSelfOperation.startOperation()
        }
    }
    
    // Объект авторизованного пользователя
    var userSelf: ISUserSelf? {
        didSet {
            if userSelf != nil {
                ISUserSelfProfileImageOperation.startOperation()
                ISUserSelfMediaRecentOperation.startOperation()
            }
        }
    }
    
    
    /// Instagram API authorization url request
    func authorizationUrlRequest() -> URLRequest? {
        
        let urlRequestParameters = ["client_id": ISAssist.Auth.clientId,
                                    "redirect_uri": ISAssist.Auth.redirectUri,
                                    "response_type": "token"]
        
        return ISAssist.shared.urlRequest(host: ISAssist.Rest.host,
                                        path: ISAssist.Rest.authPath,
                                        parameters: urlRequestParameters,
                                        httpMethod: nil)
    }
    
    func urlRequest(host: String, path: String, parameters: [String: String]?, httpMethod: ISAssist.HttpMethod?) -> URLRequest? {
        
        var requestUrlComponents = URLComponents()
        requestUrlComponents.scheme = "https"
        requestUrlComponents.host = host
        requestUrlComponents.path = path
        
        if let objects = parameters {
            
            var requestQueryItems = [URLQueryItem]()
            
            for (parameterName, parameterValue) in objects {
                
                let requestQueryItem = URLQueryItem(name: parameterName, value: parameterValue)
                requestQueryItems.append(requestQueryItem)
            }
            
            requestUrlComponents.queryItems = requestQueryItems
        }
        
        guard let requestUrl = requestUrlComponents.url else { return nil }
        
        var request = URLRequest(url: requestUrl)
        
        if let object = httpMethod {
            request.httpMethod = object.rawValue
        }
        
        return request
    }
    
    func dataTask (request: URLRequest, handler: (([String: AnyObject]?) -> Void)?) -> URLSessionDataTask {
        
        // Переходим в главный поток
        DispatchQueue.main.async {
            
            // Отображаем индикатор активности сети
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        return URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            // Переходим в главный поток
            DispatchQueue.main.async {
                
                // Скрываем индикатор активности сети
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            var json: [String: AnyObject]? = nil
            
            if let dataObject = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: dataObject),
                let dictObject = jsonObject as? [String: AnyObject] {
                
                json = dictObject
            }
            
            handler?(json)
        })
    }
}
