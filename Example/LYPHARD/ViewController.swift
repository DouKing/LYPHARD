//
//  ViewController.swift
//  LYPHARD
//
//  Created by douking on 08/24/2019.
//  Copyright (c) 2019 douking. All rights reserved.
//

import UIKit
import LYPHARD
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LaunchActivityRequest().start { (succeed: Bool, error: RequestError?, json: Any?, model: LaunchActivityModel?, response: DataResponse<Any>) in
            guard succeed else {
                debugPrint(error ?? "")
                return
            }
            debugPrint("-----")
            if let json = json {
                debugPrint(json)
            }
            if let model = model {
                debugPrint(model.imgUrl)
                debugPrint(model.redirectUrl)
            }

            debugPrint(response.response?.statusCode ?? -1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

