//
//  UserDefaultsManager.swift
//  iosDemo
//
//  本地偏好设置管理
//  Android类比: 类似SharedPreferences或DataStore
//

import Foundation

// MARK: - UserDefaults管理器
// Android类比: 类似Kotlin的DataStore封装类
class UserDefaultsManager {

    // 单例模式
    // Android类比: 类似Kotlin的object单例
    static let shared = UserDefaultsManager()

    // 私有初始化
    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - 键定义（内部使用）
    // Android类比: 类似SharedPreferences的键常量定义
    private enum Keys {
        static let hasOnboarded = "hasOnboarded"
        static let isLoggedIn = "isLoggedIn"
        static let userId = "userId"
        static let username = "username"
        static let lastLoginDate = "lastLoginDate"
        static let themeMode = "themeMode"
        static let language = "language"
        static let fontSize = "fontSize"
        static let enableNotifications = "enableNotifications"
        static let searchHistory = "searchHistory"
        static let favoritePostIds = "favoritePostIds"
    }

    // MARK: - 用户偏好设置
    // Android类比: 类似DataStore的preferencesKey()

    /// 是否已完成引导流程
    var hasOnboarded: Bool {
        get { userDefaults.bool(forKey: Keys.hasOnboarded) }
        set { userDefaults.set(newValue, forKey: Keys.hasOnboarded) }
    }

    /// 是否已登录
    var isLoggedIn: Bool {
        get { userDefaults.bool(forKey: Keys.isLoggedIn) }
        set { userDefaults.set(newValue, forKey: Keys.isLoggedIn) }
    }

    /// 当前用户ID
    var userId: Int? {
        get {
            let value = userDefaults.object(forKey: Keys.userId) as? Int
            return value
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.userId)
            } else {
                userDefaults.removeObject(forKey: Keys.userId)
            }
        }
    }

    /// 当前用户名
    var username: String? {
        get {
            return userDefaults.string(forKey: Keys.username)
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.username)
            } else {
                userDefaults.removeObject(forKey: Keys.username)
            }
        }
    }

    /// 最后登录时间
    var lastLoginDate: Date? {
        get {
            return userDefaults.object(forKey: Keys.lastLoginDate) as? Date
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.lastLoginDate)
            } else {
                userDefaults.removeObject(forKey: Keys.lastLoginDate)
            }
        }
    }

    // MARK: - 应用设置

    /// 主题模式（可选值：system, light, dark）
    // Android类比: 类似AppCompatDelegate.setDefaultNightMode()
    enum ThemeMode: String {
        case system = "system"
        case light = "light"
        case dark = "dark"
    }

    var themeMode: ThemeMode {
        get {
            let rawValue = userDefaults.string(forKey: Keys.themeMode) ?? ThemeMode.system.rawValue
            return ThemeMode(rawValue: rawValue) ?? .system
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.themeMode)
        }
    }

    /// 语言设置
    var language: String {
        get { userDefaults.string(forKey: Keys.language) ?? "zh-Hans" }
        set { userDefaults.set(newValue, forKey: Keys.language) }
    }

    /// 字体大小（默认：16）
    var fontSize: Double {
        get { userDefaults.double(forKey: Keys.fontSize) }
        set { userDefaults.set(newValue, forKey: Keys.fontSize) }
    }

    /// 是否启用通知
    var enableNotifications: Bool {
        get { userDefaults.bool(forKey: Keys.enableNotifications) }
        set { userDefaults.set(newValue, forKey: Keys.enableNotifications) }
    }

    // MARK: - 搜索历史

    /// 搜索历史记录（最多保存20条）
    // Android类比: 类似Room数据库中的搜索历史表或SharedPreferences
    private(set) var searchHistory: [String] {
        get {
            guard let array = userDefaults.array(forKey: Keys.searchHistory) as? [String] else {
                return []
            }
            return array
        }
        set {
            userDefaults.set(newValue, forKey: Keys.searchHistory)
        }
    }

    /// 添加搜索历史
    // Android类比: suspend fun addSearchHistory(query: String)
    func addSearchHistory(_ query: String) {
        guard !query.isEmpty else { return }

        // 移除重复项
        var history = searchHistory.filter { $0 != query }

        // 添加到开头
        history.insert(query, at: 0)

        // 限制数量
        if history.count > 20 {
            history = Array(history.prefix(20))
        }

        searchHistory = history
    }

    /// 清除搜索历史
    // Android类比: suspend fun clearSearchHistory()
    func clearSearchHistory() {
        userDefaults.removeObject(forKey: Keys.searchHistory)
    }

    // MARK: - 收藏帖子

    /// 收藏的帖子ID集合
    private(set) var favoritePostIds: Set<Int> {
        get {
            guard let array = userDefaults.array(forKey: Keys.favoritePostIds) as? [Int] else {
                return []
            }
            return Set(array)
        }
        set {
            userDefaults.set(Array(newValue), forKey: Keys.favoritePostIds)
        }
    }

    /// 检查帖子是否已收藏
    // Android类比: fun isFavorite(postId: Int): Boolean
    func isFavorite(postId: Int) -> Bool {
        favoritePostIds.contains(postId)
    }

    /// 添加收藏
    // Android类比: suspend fun addToFavorites(postId: Int)
    func addFavorite(postId: Int) {
        var favorites = favoritePostIds
        favorites.insert(postId)
        favoritePostIds = favorites
    }

    /// 移除收藏
    // Android类比: suspend fun removeFromFavorites(postId: Int)
    func removeFavorite(postId: Int) {
        var favorites = favoritePostIds
        favorites.remove(postId)
        favoritePostIds = favorites
    }

    /// 切换收藏状态
    // Android类比: suspend fun toggleFavorite(postId: Int)
    func toggleFavorite(postId: Int) -> Bool {
        if isFavorite(postId: postId) {
            removeFavorite(postId: postId)
            return false
        } else {
            addFavorite(postId: postId)
            return true
        }
    }

    // MARK: - 用户会话管理

    /// 保存用户登录信息
    // Android类比: fun saveUserSession(user: User)
    func saveUserSession(userId: Int, username: String) {
        self.userId = userId
        self.username = username
        self.isLoggedIn = true
        self.lastLoginDate = Date()
    }

    /// 清除用户登录信息（登出）
    // Android类比: fun clearUserSession()
    func clearUserSession() {
        userId = nil
        username = nil
        isLoggedIn = false
        // 保留其他偏好设置
    }

    // MARK: - 重置所有设置
    // Android类比: fun clearAll()
    func resetAll() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }

    // MARK: - 同步设置
    // Android类比: 类似DataStore的同步操作
    func synchronize() -> Bool {
        userDefaults.synchronize()
    }
}

// MARK: - UserDefaults键扩展（调试用）
// Android类比: 类似用于调试的日志工具
extension UserDefaultsManager {
    /// 打印所有存储的键值对（仅用于调试）
    func printAllKeys() {
        let dictionary = userDefaults.dictionaryRepresentation()
        print("===== UserDefaults Contents =====")
        for (key, value) in dictionary {
            print("\(key): \(value)")
        }
        print("================================")
    }
}
