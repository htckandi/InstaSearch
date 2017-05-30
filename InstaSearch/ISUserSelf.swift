//
//  ISUserSelf.swift
//  InstaSearch
//
//  Created by Сергей Табунщиков on 28.05.17.
//  Copyright © 2017 Sergey Tabunshikov. All rights reserved.
//

import UIKit

class ISUserSelf: NSObject {

    var userId: String?
    var userName: String?
    var userFullName: String?
    
    var userProfilePicture: String?
    
    var userBio: String?
    var userWebSite: String?
    var userCountsMedia: Int?
    var userCountsFollows: Int?
    var userCountsFollowedBy: Int?
    var userProfileImage: UIImage?
    
    var userMediaImages: [ISMediaImage]? {
        didSet {
            userMediaImagesOldCount = oldValue?.count ?? 0
            userMediaImagesNewCount = userMediaImages?.count ?? 0
            userLastMediaId = userMediaImages?.last?.mediaId
        }
    }
    
    var userMediaImagesOldCount = 0
    var userMediaImagesNewCount = 0
    var userLastMediaId: String?
    
    
    init?(json: [String: AnyObject]?) {
        
        guard let userIdObject = json?["id"] as? String else { return nil }
        
        userId = userIdObject
        userName = json?["username"] as? String
        userFullName = json?["full_name"] as? String
        userProfilePicture = json?["profile_picture"] as? String
        userBio = json?["bio"] as? String
        userWebSite = json?["website"] as? String
        userCountsMedia = json?["counts"]?["media"] as? Int
        userCountsFollows = json?["counts"]?["follows"] as? Int
        userCountsFollowedBy = json?["counts"]?["followed_by"] as? Int
    }
}
