//
//  ISAuthViewController.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISAuthViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var infoView: UIView!
    
    /// Указатель видимости индикаторов активности
    var isActivityIndicatorsVisible = false {
        
        didSet {
            
            if isActivityIndicatorsVisible {
                
                // Отображаем индикатор активности сети в status bar
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                // Отображаем индикатор активности загрузки страницы авторизации
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
                activityIndicator.startAnimating()
                
            } else {
                
                // Скрываем индикатор активности сети в status bar
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Скрываем индикатор активности загрузки страницы авторизации
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем страницу авторизации
        loadAuthorizationUrlRequest()
    }
    
    /// Повторная загрузка страницы авторизации
    @IBAction func reloadAuthorizationUrlRequest(_ sender: UIButton) {
        
        // Скрываем информационное поле
        infoView.isHidden = true
        
        // Загружаем страницу авторизации
        loadAuthorizationUrlRequest()
    }
    
    /// Загружает страницу авторизации
    func loadAuthorizationUrlRequest () {
        
        // Загружаем страницу авторизации
        webView.loadRequest(ISAssist.shared.authorizationUrlRequest()!)
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // Проверяем факт переадресации на свой сайт
        guard let requestUrl = request.url,
            let requestUrlComponents = URLComponents(url: requestUrl, resolvingAgainstBaseURL: true),
            let requestUrlComponentHost = requestUrlComponents.host,
            let requestFragment = requestUrlComponents.fragment,
            requestUrlComponentHost == "testusermoscow.wordpress.com" else { return true }
        
        let requestFragmentComponents = requestFragment.components(separatedBy: "=")
        
        // Проверяем наличие access_token
        if requestFragmentComponents.contains("access_token"), let accessToken = requestFragmentComponents.last {
            
            // Сохраняем access_token
            ISAssist.shared.accessToken = accessToken
            
            // Скрываем контроллер авторизации
            navigationController?.dismiss(animated: true, completion: nil)
        }
        
        return false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        // Отображаем индикаторы активности загрузки страницы авторизации
        isActivityIndicatorsVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // Скрываем индикаторы активности загрузки страницы авторизации
        isActivityIndicatorsVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        // Отображаем индикаторы активности загрузки страницы авторизации
        isActivityIndicatorsVisible = false
        
        // Отображаем информационное поле
        infoView.isHidden = false
    }
}
