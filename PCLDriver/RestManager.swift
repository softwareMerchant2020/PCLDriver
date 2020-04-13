//
//  RestManager.swift
//  PCLDriver
//
//  Created by Rutul Desai on 4/13/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation

class RestManager{
    
    enum HttpMethod: String {
           case get
           case post
           case put
           case patch
           case delete
    }
    
    class func APIData(url:String, httpMethod:String, body:Data?, completion: @escaping ((_ data:Any?,_ error:Error?) -> Void)){
        
        DispatchQueue.global(qos: .userInitiated).async {
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = httpMethod
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) {
                (data,response,error) in
                
                guard let responseReceived = response as? HTTPURLResponse else {return}
                if((200...300) ~= responseReceived.statusCode)
                {
                    completion(data, nil)
                }
                else
                {
                    completion(nil,error)
                }
            }
            task.resume()
        }
    }
}
