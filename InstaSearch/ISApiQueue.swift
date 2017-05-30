//
//  ISApiQueue.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 29.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISApiQueue: OperationQueue {
    
    override init() {
        super.init()
        
        // Ограничиваем количество одновременно выполняемых операций для экономии ресурсов
        // Уменьшив этот параметр до 1 можно наглядно проследить lazy load
        maxConcurrentOperationCount = 4
    }
    
    /// Проверяет наличие в потоке операции с указанным именем
    func containsOperation (forName: String?) -> Bool {
        
        guard let operationName = forName else { return false }
        
        // Получаем имена всех операций в потоке
        let operationsNames = operations.flatMap{ $0.name }
        
        // Проверяем наличие операции в потоке
        return operationsNames.contains(operationName)
    }
}
