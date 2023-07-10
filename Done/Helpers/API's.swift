//
//  API's.swift
//  Done
//
//  Created by Mac on 31/05/23.
//

import Foundation


let k_token = ""
let k_signUptoken = ""
let k_userID = ""
var headers  = ["Accept": "application/json", "Authorization": "Bearer " + k_token]

let SERVERURL = "https://d1g0ba8hbbwly8.cloudfront.net"

let BASEURL = "https://www.drrecommendations.com/"
let LOGINURL = "api/user/login.php"
let PROFILE = "api/user/profile.php"
let GETREELSURL = "api/posts/post.php?status="
let CREATEPOSTURL = "api/posts/post.php"
let GETTAGUSERS = "api/posts/employee.php"
let VIEWSTATUS = "api/posts/post-assignees-by-status.php?post_id="
let GETCOMMENTSAPI = "api/posts/comment.php?assignee_employee_id="
let CREATEPOSTAPI = "api/posts/comment.php"
let COMMISSIONAPI   = "api/posts/assignee-commission-made.php?employee_id="
let UPDATEPOSTAPI = "api/posts/post.php"
let UPDATEPOSTASDONE = "api/posts/mark-post-as-done.php"
let READLASTMSGAPI = "api/posts/comment.php?"
let GROUPSAPI = "api/posts/groups.php"

//
//let READLASTMSGAPI =  "task_created_by=task_created_by&employee_id=employee_id&assignee_employee_id=assignee_employee_id"
let CATEGORY_PROJECTTYPE = "api/posts/categories.php"

let TOTALCOMMENTCOUNT = "api/posts/comment.php?assignee_id="


//https://picsum.photos/v2/list?page={page}&limit={limit}
