//
//  YARequestManager.swift
//
//  Created by Yash Agarwal on 22/05/2020.
//  Copyright © 2020 Yash Agarwal. All rights reserved.
//

import UIKit
import Alamofire

class YARequestManager: NSObject {

    /**
     POST => https://api.taanni.com/v1/user/addgps

     Post Params => lat : your_lat
     lng : your_lng

     Headers Parans => drifely-secure-header : 135ce88cc3b3b5db0dfbce5924c67e135cb09994
     */
    
	//Shared Instance
	static let shared = YARequestManager()
	
  /**
	Make a HTTP POST request and returns with either response or failure
	- Parameter url: Request URL
	- Parameter parameters: Request Parameters
	- Parameter finished: Json response get from server
	- Parameter failed: Error from server
   */
  func requestHTTPPOST(url:String, parameters:Dictionary<String,Any>, finished:@escaping (Dictionary<String, Any>)->Void, failed:@escaping (String)->Void) {
    // HTTP POST request
    print(parameters)

		//IndecatorView.show()
		if NetworkReachabilityManager()!.isReachable {
			
			Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: getHeader()).responseJSON { (response) in
				
				print(url)
        switch(response.result) {
        case .success(_):
					if let data = response.value {
            DispatchQueue.main.async {
              print(data)
              finished(data as! Dictionary<String, Any>)
            }
          }
          break
          
        case .failure(_):
          if let error = response.error {
            failed(error.localizedDescription)
          }
          break
        }
			}
		} else {
			
		}
  }
    
    /**
     Get the header with security key
     
     - Returns: Alamofire.HTTPHeaders
     */
    func getHeader() -> Alamofire.HTTPHeaders {
      var headers: Alamofire.HTTPHeaders = [:]
      headers["drifely-secure-header"]    = "135ce88cc3b3b5db0dfbce5924c67e135cb09994"
      return headers
    }
}

