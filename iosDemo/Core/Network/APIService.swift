//
//  APIService.swift
//  iosDemo
//
//  网络服务基类 - 提供RESTful API调用功能
//  Android类比: 类似Retrofit的API接口实现
//

import Foundation

// MARK: - API服务协议 (Protocol-oriented programming)
// Android类比: 类似Retrofit的接口定义
protocol APIServiceProtocol {
    func fetchPosts() async throws -> [Post]
    func fetchUsers() async throws -> [User]
    func fetchUser(id: Int) async throws -> User
    func fetchComments(postId: Int) async throws -> [Comment]
    func searchPosts(query: String) async throws -> [Post]
}

// MARK: - API服务实现
// Android类比: 类似Retrofit的实现类，使用OkHttp进行网络请求
class APIService: APIServiceProtocol {

    // 单例模式 - 保证全局只有一个网络实例
    // Android类比: 类似Kotlin的object单例
    static let shared = APIService()

    // URLSession - iOS原生网络请求框架
    // Android类比: 类似OkHttpClient
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder

    // 私有初始化方法 - 确保单例模式
    private init(
        baseURL: String = "https://jsonplaceholder.typicode.com",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        // 配置JSON解码器
        // Android类比: 类似Moshi或Gson的配置
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase // 支持snake_case转camelCase
        self.decoder.dateDecodingStrategy = .iso8601 // ISO8601日期格式
    }

    // MARK: - 端点构建辅助方法
    // Android类比: 类似Retrofit的@GET、@POST等注解
    private func endpoint(path: String) -> URL {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            fatalError("Invalid URL: \(baseURL)\(path)")
        }
        return url
    }

    // MARK: - 通用网络请求方法
    // Android类比: 类似Retrofit的suspend函数
    private func request<T: Decodable>(
        _ url: URL,
        responseType: T.Type
    ) async throws -> T {
        // 使用async/await进行异步网络请求
        // Android类比: 类似Coroutines的suspend函数
        let (data, response) = try await session.data(from: url)

        // 验证HTTP响应状态
        // Android类比: 类似Retrofit的Response.isSuccessful()
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        // 解码JSON数据
        // Android类比: 类似Moshi/Gson的fromJson
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    // MARK: - API接口实现

    /// 获取帖子列表
    /// Android类比: @GET("posts") suspend fun getPosts(): List<Post>
    func fetchPosts() async throws -> [Post] {
        let url = endpoint(path: "/posts")
        return try await request(url, responseType: [Post].self)
    }

    /// 获取用户列表
    /// Android类比: @GET("users") suspend fun getUsers(): List<User>
    func fetchUsers() async throws -> [User] {
        let url = endpoint(path: "/users")
        return try await request(url, responseType: [User].self)
    }

    /// 获取单个用户详情
    /// Android类比: @GET("users/{id}") suspend fun getUser(@Path("id") id: Int): User
    func fetchUser(id: Int) async throws -> User {
        let url = endpoint(path: "/users/\(id)")
        return try await request(url, responseType: User.self)
    }

    /// 获取帖子的评论列表
    /// Android类比: @GET("posts/{postId}/comments") suspend fun getComments(@Path("postId") postId: Int): List<Comment>
    func fetchComments(postId: Int) async throws -> [Comment] {
        let url = endpoint(path: "/posts/\(postId)/comments")
        return try await request(url, responseType: [Comment].self)
    }

    /// 搜索帖子（客户端过滤实现）
    /// Android类比: 类似Room的@Query注解或Flow.filter()
    func searchPosts(query: String) async throws -> [Post] {
        // 先获取所有帖子，然后在客户端过滤
        // 实际项目中应该在服务端实现搜索
        let allPosts = try await fetchPosts()

        if query.isEmpty {
            return allPosts
        }

        // 过滤逻辑
        // Android类比: 类似Kotlin的filter函数
        return allPosts.filter { post in
            post.title.localizedCaseInsensitiveContains(query) ||
            post.body.localizedCaseInsensitiveContains(query)
        }
    }
}
