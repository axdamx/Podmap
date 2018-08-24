//
//  ParseJson.swift
//  Podmap
//
//  Created by Mohd Adam on 23/08/2018.
//  Copyright © 2018 Mohd Adam. All rights reserved.
//

import Foundation
import UIKit

class ParseJson {
    
    let urlComponents = URLComponents(string: "https://developers.onemap.sg/privateapi/popapi/getAllPlanningarea?token=eyJ0eXAi")!
    
    let defaultSession = URLSession(configuration: .default)
    
    func getDetails(withCompletion completion: @escaping ([PodObject]?) -> Void) {
        let detailURLComponents = urlComponents
        let detailURL = detailURLComponents.url!
        
        var request = URLRequest(url: detailURL)
        request.httpMethod = "GET"
        
        let dataTask = defaultSession.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let areaDetail = try decoder.decode(Array<PodObject>.self, from: data)
                let geoJson = areaDetail
                //print(geoJson)
                completion(geoJson)
            }
            catch let error {
                print(error)
            }
        })
        
        dataTask.resume()
    }
}

