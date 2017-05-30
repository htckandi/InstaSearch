//
//  ISListViewHeaderInfo.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISListViewHeaderInfo: UICollectionReusableView {

    @IBOutlet weak var infoLabel: UILabel!

    /// Обработка уведомления о завершении загрузки данных пользователя
    func configureView () {
        if ISAssist.shared.accessToken != nil {
            infoLabel.text = "User data not available\nPull down to refresh"
        }
    }
}
