//
//  DataModel.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import Foundation

struct DataModel: Codable{
    let status: String?
    let images : [ImageDataModel]?
}

struct ImageDataModel: Codable{
    let id : String?
    let xt_image : String?
}
