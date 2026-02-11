//
//  NetworkError.swift
//  iosDemo
//
//  网络错误定义 - 统一的网络层错误类型
//  Android类比: 类似Retrofit/OkHttp中的异常处理类
//

import Foundation

// MARK: - 网络错误类型
// Android类比: 类似自定义的ApiException或Result.Error
enum NetworkError: Error, LocalizedError {
    // URL相关错误
    case invalidURL
    case urlComponentsFailed

    // 网络请求错误
    case requestFailed(Error)
    case noNetworkConnection

    // 服务器响应错误
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(message: String?)

    // 数据解析错误
    case decodingFailed(Error)
    case encodingFailed(Error)

    // 业务逻辑错误
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverUnavailable

    // 通用错误
    case unknown

    // MARK: - 错误描述（用户友好的错误信息）
    // Android类比: 类似Throwable的message属性
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的链接地址"
        case .urlComponentsFailed:
            return "链接构建失败"
        case .requestFailed(let error):
            return "请求失败: \(error.localizedDescription)"
        case .noNetworkConnection:
            return "网络连接不可用，请检查网络设置"
        case .invalidResponse:
            return "服务器响应格式错误"
        case .httpError(let statusCode):
            return "HTTP错误，状态码: \(statusCode)"
        case .serverError(let message):
            return message ?? "服务器错误"
        case .decodingFailed(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "数据编码失败: \(error.localizedDescription)"
        case .unauthorized:
            return "未授权，请先登录"
        case .forbidden:
            return "没有访问权限"
        case .notFound:
            return "请求的资源不存在"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .serverUnavailable:
            return "服务暂时不可用，请稍后再试"
        case .unknown:
            return "发生未知错误"
        }
    }

    // MARK: - 恢复建议（给用户的提示）
    // Android类比: 类似可以显示给用户的错误提示
    var recoverySuggestion: String? {
        switch self {
        case .noNetworkConnection:
            return "请检查您的网络连接后重试"
        case .unauthorized:
            return "请登录后重试"
        case .forbidden:
            return "您没有访问此内容的权限"
        case .notFound:
            return "请确认链接是否正确"
        case .rateLimited:
            return "请等待一段时间后再试"
        case .serverUnavailable:
            return "服务器正在维护中，请稍后再试"
        case .decodingFailed, .encodingFailed:
            return "数据格式错误，请联系开发者"
        default:
            return "请稍后重试，如果问题持续存在请联系技术支持"
        }
    }

    // MARK: - 从URLResponse创建错误
    // Android类比: 类似Retrofit的HttpException处理
    static func from(urlResponse: URLResponse?) -> NetworkError? {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            return .invalidResponse
        }

        switch httpResponse.statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        case 500...599:
            return .serverUnavailable
        case 200...299:
            return nil
        default:
            return .httpError(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - 判断是否可重试的错误
    // Android类比: 类似Retrofit的RetryInterceptor逻辑
    var isRetryable: Bool {
        switch self {
        case .noNetworkConnection, .serverUnavailable, .rateLimited:
            return true
        case .httpError(let statusCode):
            // 5xx错误可重试
            return statusCode >= 500
        default:
            return false
        }
    }
}

// MARK: - Result类型别名
// Android类比: 类似Kotlin的Result<T>
typealias APIResult<T> = Result<T, NetworkError>

// MARK: - API响应包装
// Android类比: 类似Retrofit的Response<T>
struct APIResponse<T> {
    let data: T
    let statusCode: Int
    let headers: [String: String]

    init(data: T, statusCode: Int = 200, headers: [String: String] = [:]) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }
}
