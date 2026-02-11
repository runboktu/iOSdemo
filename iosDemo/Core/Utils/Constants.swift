//
//  Constants.swift
//  iosDemo
//
//  应用常量定义
//  Android类比: 类似object Constants { const val ... }
//

import Foundation
import SwiftUI

// MARK: - API配置常量
// Android类比: 类似Retrofit的object ApiConstants { const val BASE_URL = ... }
enum APIConstants {
    /// API基础URL
    // Android类比: const val BASE_URL = "https://jsonplaceholder.typicode.com"
    static let baseURL = "https://jsonplaceholder.typicode.com"

    /// 请求超时时间（秒）
    // Android类比: const val TIMEOUT = 30L
    static let timeout: TimeInterval = 30

    /// API版本
    // Android类比: const val API_VERSION = "v1"
    static let version = "v1"

    /// 默认分页大小
    // Android类比: const val PAGE_SIZE = 20
    static let defaultPageSize = 20

    /// 最大重试次数
    // Android类比: const val MAX_RETRIES = 3
    static let maxRetries = 3
}

// MARK: - 布局常量
// Android类比: 类似dimens.xml中的尺寸定义
enum LayoutConstants {
    /// 间距（类似Android的margin/padding）
    // Android类比: <dimen name="spacing_xxxs">4dp</dimen>
    static let spacingXXXS: CGFloat = 4
    static let spacingXXS: CGFloat = 8
    static let spacingXS: CGFloat = 12
    static let spacingSM: CGFloat = 16
    static let spacingMD: CGFloat = 20
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    /// 圆角半径
    // Android类比: <dimen name="corner_radius_sm">8dp</dimen>
    static let cornerRadiusXS: CGFloat = 4
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24

    /// 字体大小
    // Android类比: <dimen name="text_size_body">14sp</dimen>
    static let fontSizeCaption: CGFloat = 12
    static let fontSizeBody: CGFloat = 14
    static let fontSizeSubheadline: CGFloat = 15
    static let fontSizeCallout: CGFloat = 16
    static let fontSizeHeadline: CGFloat = 17
    static let fontSizeTitle3: CGFloat = 20
    static let fontSizeTitle2: CGFloat = 22
    static let fontSizeTitle1: CGFloat = 28
    static let fontSizeLargeTitle: CGFloat = 34

    /// 图标尺寸
    // Android类比: <dimen name="icon_size_sm">16dp</dimen>
    static let iconSizeXS: CGFloat = 16
    static let iconSizeSM: CGFloat = 20
    static let iconSizeMD: CGFloat = 24
    static let iconSizeLG: CGFloat = 32
    static let iconSizeXL: CGFloat = 48

    /// 列表高度
    // Android类比: <dimen name="list_item_height">56dp</dimen>
    static let listItemHeight: CGFloat = 56
    static let listItemImageSize: CGFloat = 40

    /// 导航栏高度（系统默认）
    // Android类比: ?attr/actionBarSize
    @available(*, unavailable)
    static let navigationBarHeight: CGFloat = 44 // 系统会自动处理

    /// Tab栏高度
    // Android类比: ?attr/actionBarSize (Bottom Nav)
    static let tabBarHeight: CGFloat = 49
}

// MARK: - 动画常量
// Android类比: 类似动画资源文件或R.dimen定义
enum AnimationConstants {
    /// 默认动画时长
    // Android类比: android:duration="200" (XML)
    static let defaultDuration: Double = 0.25

    /// 快速动画
    static let fastDuration: Double = 0.15

    /// 慢速动画
    static let slowDuration: Double = 0.35

    /// Spring动画阻尼
    // Android类比: SpringForce类的阻尼比
    static let springDamping: Double = 0.7

    /// Spring动画初始速度
    static let springVelocity: Double = 0.5
}

// MARK: - 用户界面常量
// Android类比: 类似R.string或硬编码的UI文本常量
enum UIConstants {
    /// 应用名称
    // Android类比: <string name="app_name">iLearn</string>
    static let appName = "iLearn"

    /// 默认错误消息
    // Android类比: <string name="error_default">发生了错误</string>
    static let defaultErrorMessage = "发生了错误，请稍后重试"

    /// 网络错误消息
    // Android类比: <string name="error_network">网络连接失败</string>
    static let networkErrorMessage = "网络连接失败，请检查网络设置"

    /// 加载中提示
    // Android类比: <string name="loading">加载中...</string>
    static let loadingMessage = "加载中..."

    /// 占位符文本
    // Android类比: <string name="placeholder_search">搜索...</string>
    static let searchPlaceholder = "搜索..."

    /// 确认按钮文本
    // Android类比: <string name="button_confirm">确定</string>
    static let confirmButton = "确定"
    static let cancelButton = "取消"
    static let deleteButton = "删除"
    static let saveButton = "保存"

    /// Toast持续时间
    // Android类比: Toast.LENGTH_SHORT
    static let toastDurationShort: TimeInterval = 2
    static let toastDurationLong: TimeInterval = 4
}

// MARK: - 存储键常量
// Android类比: 类似SharedPreferences的键常量定义
enum StorageKeys {
    /// 用户偏好前缀
    static let userDefaultsPrefix = "com.ilearn."

    // 用户相关
    static let userId = "\(userDefaultsPrefix)user_id"
    static let userName = "\(userDefaultsPrefix)user_name"
    static let userAvatar = "\(userDefaultsPrefix)user_avatar"

    // 设置相关
    static let themeMode = "\(userDefaultsPrefix)theme_mode"
    static let language = "\(userDefaultsPrefix)language"

    // 缓存相关
    static let cachedPosts = "\(userDefaultsPrefix)cached_posts"
    static let lastFetchTime = "\(userDefaultsPrefix)last_fetch_time"
}

// MARK: - Mock数据常量
// Android类比: 类似调试用的Mock数据常量
enum MockConstants {
    /// Mock数据延迟（模拟网络请求）
    // Android类比: const val MOCK_DELAY = 1000L
    static let networkDelay: TimeInterval = 1.0

    /// 是否启用Mock数据
    // Android类比: const val USE_MOCK_DATA = BuildConfig.DEBUG
    static let useMockData = false

    /// Mock用户数量
    static let mockUserCount = 10

    /// Mock帖子数量
    static let mockPostCount = 100
}

// MARK: - 分页常量
// Android类比: 类似Paging库的配置常量
enum PaginationConstants {
    /// 每页加载数量
    // Android类比: const val PAGE_SIZE = 20
    static let pageSize = 20

    /// 预加载阈值（距离底部多少项时开始预加载）
    // Android类比: PagingConfig(prefetchDistance = 5)
    static let prefetchDistance = 5

    /// 初始加载页码
    // Android类比: const val INITIAL_PAGE = 1
    static let initialPage = 1

    /// 最大页码
    // Android类比: const val MAX_PAGES = 100
    static let maxPages = 100
}

// MARK: - 图片相关常量
// Android类比: 类似图片加载库的配置
enum ImageConstants {
    /// 默认占位图名称
    // Android类比: R.drawable.placeholder
    static let placeholder = "photo"

    /// 错误占位图名称
    static let errorPlaceholder = "exclamationmark.triangle"

    /// 默认头像
    static let defaultAvatar = "person.circle.fill"

    /// 图片缓存大小（MB）
    // Android类比: ImageLoader配置中的内存缓存大小
    static let cacheSize: Int = 100 * 1024 * 1024 // 100MB
}

// MARK: - 应用行为常量
// Android类比: 类似Feature Flag或行为配置
enum AppBehavior {
    /// 是否启用调试模式
    // Android类比: BuildConfig.DEBUG
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// 是否显示引导页
    static let showOnboarding = true

    /// 是否启用分析统计
    static let analyticsEnabled = true

    /// 版本号
    // Android类比: BuildConfig.VERSION_CODE
    static let appVersion = "1.0.0"

    /// 构建号
    // Android类比: BuildConfig.VERSION_NAME
    static let buildNumber = "1"
}
