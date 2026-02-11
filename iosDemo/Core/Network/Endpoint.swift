//
//  Endpoint.swift
//  iosDemo
//
//  API端点定义 - 集中管理所有API路径
//  Android类比: 类似Retrofit的接口定义中的@GET、@POST等注解
//

import Foundation

// MARK: - API端点枚举
// Android类比: 类似Retrofit接口中的方法定义
enum Endpoint {
    // 帖子相关端点
    case posts
    case post(id: Int)
    case postComments(postId: Int)

    // 用户相关端点
    case users
    case user(id: Int)

    // 待办事项端点 (JSONPlaceholder支持)
    case todos
    case todo(id: Int)

    // 基础配置
    static let baseURL = "https://jsonplaceholder.typicode.com"

    // 构建完整URL
    // Android类比: 类似Retrofit的@GET注解配合路径参数
    var url: URL {
        switch self {
        case .posts:
            return URL(string: "\(Endpoint.baseURL)/posts")!
        case .post(let id):
            return URL(string: "\(Endpoint.baseURL)/posts/\(id)")!
        case .postComments(let postId):
            return URL(string: "\(Endpoint.baseURL)/posts/\(postId)/comments")!
        case .users:
            return URL(string: "\(Endpoint.baseURL)/users")!
        case .user(let id):
            return URL(string: "\(Endpoint.baseURL)/users/\(id)")!
        case .todos:
            return URL(string: "\(Endpoint.baseURL)/todos")!
        case .todo(let id):
            return URL(string: "\(Endpoint.baseURL)/todos/\(id)")!
        }
    }

    // 路径描述（用于调试）
    var path: String {
        switch self {
        case .posts:
            return "/posts"
        case .post(let id):
            return "/posts/\(id)"
        case .postComments(let postId):
            return "/posts/\(postId)/comments"
        case .users:
            return "/users"
        case .user(let id):
            return "/users/\(id)"
        case .todos:
            return "/todos"
        case .todo(let id):
            return "/todos/\(id)"
        }
    }
}

// MARK: - HTTP方法枚举
// Android类比: 类似Retrofit的@GET、@POST、@PUT、@DELETE注解
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - API请求构建器
// Android类比: 类似OkHttp的Request.Builder
struct APIRequest {
    let url: URL
    let method: HTTPMethod
    var headers: [String: String] = [:]
    var body: Data?

    // 创建请求构建器
    // Android类比: 类似OkHttp的Request.Builder()
    static func build(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body

        // 设置默认Content-Type
        if body != nil && headers["Content-Type"] == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
