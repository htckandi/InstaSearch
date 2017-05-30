//
//  ISListViewController.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

private let userHeaderViewReuseIdentifier = "ISListViewHeader"
private let infoHeaderViewReuseIdentifier = "ISListViewHeaderInfo"
private let infoFooterViewReuseIdentifier = "ISListViewFooter"
private let infoHeaderViewNibName = "ISListViewHeaderInfo"
private let authViewControllerSegueIdentifier = "PresentISAuthViewController"


class ISListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем обозреватели уведомлений
        NotificationCenter.default.addObserver(self, selector: #selector(userSelfDidLoad(notification:)), name: ISAssist.Notifications.userSelfDidLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaDidLoad(notification:)), name: ISAssist.Notifications.mediaDidLoad, object: nil)
        
        // Готовим refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateUserSelf), for: .valueChanged)
        
        // Добавляем функцию refresh control
        collectionView?.refreshControl = refreshControl
        
        // Регистрируем header при отсутствии данных пользователя
        collectionView?.register(UINib(nibName: infoHeaderViewNibName, bundle: nil),
                                 forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                 withReuseIdentifier: infoHeaderViewReuseIdentifier)
        
        // Проверяем наличие access token
        if ISAssist.shared.accessToken == nil {
            
            // Открываем контроллер авторизации
            performSegue(withIdentifier: authViewControllerSegueIdentifier, sender: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
    
    /// Обрабатывает уведомление о завершении загрузки медиа объектов
    func mediaDidLoad (notification: NSNotification) {
        
        // Проверяем получение новых объектов
        if let oldCount = ISAssist.shared.userSelf?.userMediaImagesOldCount,
            let newCount = ISAssist.shared.userSelf?.userMediaImagesNewCount, oldCount < newCount {
            
            // Получаем расхождение между старым массивом медиа объектов и новым
            let variance = newCount - oldCount
            
            var indexPaths = [IndexPath]()
            
            for i in 1...variance {
                
                let indexPath = IndexPath(item: oldCount - 1 + i, section: 0)
                indexPaths.append(indexPath)
            }
            
            // Вставляем новые элементы коллекции
            collectionView?.insertItems(at: indexPaths)
        }
    }
    
    /// Принудительное обновление данных пользователя
    func updateUserSelf() {
        
        // Добавляем в параллельный поток операцию обновления данных пользователя
        ISAssist.shared.apiQueue.addOperation(ISUserSelfOperation())
    }
    
    /// Обработка уведомления о завершении загрузки данных пользователя
    func userSelfDidLoad (notification: Notification) {

        collectionView?.refreshControl?.endRefreshing()
        collectionView?.reloadData()
    }
    
    /// Обрабатываем вращение девайса
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
        
            // Аннулируем расположение объектов коллекции
            self.collectionView?.collectionViewLayout.invalidateLayout()
        
        }, completion: nil)
    }

    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = view.frame.width
        let viewHeight = view.frame.height
        
        let isSlim = viewWidth < viewHeight
        
        let xRation = CGFloat(isSlim ? 1 : 0.5)
        let yRation = CGFloat(isSlim ? 0.5 : 0.75)
        
        return CGSize(width: viewWidth * xRation, height: viewHeight * yRation)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            if ISAssist.shared.userSelf == nil {
                
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                       withReuseIdentifier: "ISListViewHeaderInfo",
                                                                       for: indexPath) as! ISListViewHeaderInfo
                reusableView.configureView()
                return reusableView
                
            } else {
                
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                       withReuseIdentifier: "ISListViewHeader",
                                                                       for: indexPath) as! ISListViewHeader
                reusableView.configureView()
                return reusableView
            }
            
        } else {
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: "ISListViewFooter",
                                                                   for: indexPath)
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ISAssist.shared.userSelf?.userMediaImages?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ISListViewCell", for: indexPath) as! ISListViewCell
        cell.mediaObject = ISAssist.shared.userSelf!.userMediaImages![indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // На случай, если во время загрузки изображений передача данных прерывалась
        // Подгружаем недостающие картинки
        if (cell as! ISListViewCell).mediaImage.image == nil {
            ISMediaImageOperation.startOperation(object: (cell as! ISListViewCell).mediaObject)
        }
        
        // Проверяем, является ли отображаемый объект последним
        if (indexPath.item + 1) == ISAssist.shared.userSelf?.userMediaImages?.count {
            
            // Подгружаем новые объекты медиа
            ISUserSelfMediaRecentOperation.startOperation()
        }
    }
}
