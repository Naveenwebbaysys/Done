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

let SERVERURL = "https://d1g0ba8hbbwly8.cloudfront.net"

let BASEURL = "https://www.drrecommendations.com/"
let LOGINURL = "api/user/login.php"
let GETREELSURL = "api/posts/post.php"
let CREATEPOSTURL = "api/posts/post.php"
let GETTAGUSERS = "api/posts/employee.php"
