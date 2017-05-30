//
//  ISMediaImage.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 29.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISMediaImage: NSObject {

    var mediaId: String!
    var mediaType: String?
    var mediaCaptionFromUserName: String?
    var mediaCaptionCreatedTime: String?
    var mediaCaptionText: String?
    var mediaCommentsCount: Int?
    var mediaImageStandartResolution: String?
    var mediaStandartResolutionImage: UIImage?
    
    init?(json: [String: AnyObject]?) {
        
        guard let userIdObject = json?["id"] as? String else { return nil }
        
        mediaId = userIdObject
        mediaType = json?["type"] as? String
        
        let mediaCaption = json?["caption"] as? [String: AnyObject]
        mediaCaptionFromUserName = mediaCaption?["from"]?["username"] as? String
        mediaCaptionCreatedTime = json?["caption"]?["created_time"] as? String
        mediaCaptionText = json?["caption"]?["text"] as? String
        mediaCommentsCount = json?["comments"]?["count"] as? Int
        
        let mediaStandartResolution = json?["images"]?["standard_resolution"] as? [String: AnyObject]
        mediaImageStandartResolution = mediaStandartResolution?["url"] as? String
    }
}
