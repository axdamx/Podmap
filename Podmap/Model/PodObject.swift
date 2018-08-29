//
//  PodObject.swift
//  Podmap
//
//  Created by Mohd Adam on 23/08/2018.
//  Copyright © 2018 Mohd Adam. All rights reserved.
//

import Foundation

typealias PodObject = [PodElement]

struct PodElement: Codable {
    let plnAreaN, geojson: String
    
    enum CodingKeys: String, CodingKey {
        case plnAreaN = "pln_area_n"
        case geojson
    }
}
