//
//  iosDemoApp.swift
//  iosDemo
//
//  应用主入口 - 类似Android的Application类或MainActivity
//  Android类比: class MainApplication : Application()
//

import SwiftUI
import SwiftData

@main
struct iosDemoApp: App {
    // MARK: - SwiftData容器注入
    // Android类比: 类似Room.databaseBuilder()在Application中初始化
    let modelContainer: ModelContainer = AppDataContainer.modelContainer

    // MARK: - API服务注入
    // Android类比: 类似Retrofit在Hilt模块中提供
    private let apiService: APIServiceProtocol = APIService.shared

    // MARK: - UserDefaults注入
    // Android类比: 类似DataStore在Hilt模块中提供
    private let userDefaults: UserDefaultsManager = .shared

    // MARK: - 应用入口
    // Android类比: Application.onCreate() 或 MainActivity.onCreate()
    var body: some Scene {
        WindowGroup {
            // 应用根视图
            // Android类比: setContentView(R.layout.activity_main)
            AppRoot()
                // 注入API服务到环境
                // Android类比: 类似Hilt的@Provides
                .environment(\.apiService, apiService)
        }
        // 注入SwiftData容器到环境
        // Android类比: 类似Room在Application中配置
        .modelContainer(modelContainer)
    }
}

// MARK: - 环境值Key定义（用于依赖注入）
// Android类比: 类似Hilt的@Provides注解或Koin的module
private struct APIServiceKey: EnvironmentKey {
    // Android类比: @Provides fun provideAPIService(): APIService
    static let defaultValue: APIServiceProtocol = APIService.shared
}

private struct DataManagerKey: EnvironmentKey {
    // Android类比: @Provides fun provideDataManager(): DataManager
    static let defaultValue: UserDefaultsManager = .shared
}

// MARK: - EnvironmentValues扩展（注入依赖）
// Android类比: 类似Hilt的@InstallIn或Koin的module
extension EnvironmentValues {
    /// API服务
    // Android类比: @Inject lateinit var apiService: APIService
    var apiService: APIServiceProtocol {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }

    /// 数据管理器
    // Android类比: @Inject lateinit var dataManager: DataManager
    var dataManager: UserDefaultsManager {
        get { self[DataManagerKey.self] }
        set { self[DataManagerKey.self] = newValue }
    }
}

// MARK: - 应用配置常量
// Android类比: class AppConfig { const val ... }
enum AppConfig {
    /// 应用名称
    // Android类比: <string name="app_name">iLearn</string>
    static let appName = "iLearn"

    /// 应用版本
    // Android类比: BuildConfig.VERSION_NAME
    static let version = "1.0.0"

    /// 构建号
    // Android类比: BuildConfig.VERSION_CODE
    static let buildNumber = 1

    /// 是否是调试版本
    // Android类比: BuildConfig.DEBUG
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// API基础URL
    // Android类比: BuildConfig.API_BASE_URL
    static let apiBaseURL = "https://jsonplaceholder.typicode.com"

    /// 应用支持的最低版本
    static let minSupportedVersion = "1.0.0"

    /// 日志开关
    static let isLoggingEnabled: Bool = isDebug
}
