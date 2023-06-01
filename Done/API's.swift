//
//  API's.swift
//  Done
//
//  Created by Mac on 31/05/23.
//

import Foundation


let k_token = ""
let k_signUptoken = ""

var headers  = ["Accept": "application/json", "Authorization": "Bearer " + k_token]
let BASEURL = "https://www.drrecommendations.com/"
let LOGINURL = "api/user/login.php"
let GETREELSURL = "api/posts/post.php"
