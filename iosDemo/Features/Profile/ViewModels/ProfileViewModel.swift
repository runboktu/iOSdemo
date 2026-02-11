//
//  ProfileViewModel.swift
//  iosDemo
//
//  个人中心ViewModel - 管理用户数据和个人信息
//  Android类比: 类似Jetpack ViewModel + StateFlow/LiveData
//

import Foundation
import Observation

// MARK: - 个人中心ViewModel
// Android类比: class ProfileViewModel : ViewModel()
@Observable
class ProfileViewModel {

    // MARK: - UI状态
    /// 用户信息
    // Android类比: val user: StateFlow<User?>
    var currentUser: User?

    /// 是否正在加载
    // Android类比: val isLoading: StateFlow<Boolean>
    var isLoading: Bool = false

    /// 错误信息
    // Android类比: val errorMessage: StateFlow<String?>
    var errorMessage: String? = nil

    /// 是否已登录
    // Android类比: val isLoggedIn: StateFlow<Boolean>
    var isLoggedIn: Bool = false {
        didSet {
            // 状态变化自动通知
        }
    }

    /// 应用设置
    // Android类比: val settings: StateFlow<AppSettings>
    var appSettings: AppSettings = AppSettings()

    // MARK: - 依赖注入
    private let apiService: APIServiceProtocol
    private let userDefaults: UserDefaultsManager

    // MARK: - 初始化
    // Android类比: init(...)
    init(
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaultsManager = .shared
    ) {
        self.apiService = apiService
        self.userDefaults = userDefaults

        // 检查登录状态
        // Android类比: isLoggedIn = checkLoginStatus()
        self.isLoggedIn = userDefaults.isLoggedIn

        // 加载设置
        // Android类比: loadSettings()
        loadSettings()

        // 异步加载用户信息
        // Android类比: if (isLoggedIn) loadUserInfo()
        if isLoggedIn, let userId = userDefaults.userId {
            Task {
                await loadUserInfo(userId: userId)
            }
        }
    }

    // MARK: - 计算属性
    /// 用户显示名称
    // Android类比: val displayName: String get() = user?.displayName ?: "Guest"
    var displayName: String {
        currentUser?.displayName ?? "游客"
    }

    /// 用户头像首字母
    // Android类比: val initials: String get() = user?.initials ?: "?"
    var initials: String {
        currentUser?.initials ?? "?"
    }

    /// 是否是首次使用
    // Android类比: val isFirstTime: Boolean get() = !userDefaults.hasOnboarded
    var isFirstTime: Bool {
        !userDefaults.hasOnboarded
    }

    /// 统计信息
    // Android类比: val stats: UserStats get() = ...
    var stats: UserStats {
        UserStats(
            postsCount: UserDefaults.standard.integer(forKey: "stats_posts"),
            commentsCount: UserDefaults.standard.integer(forKey: "stats_comments"),
            likesCount: UserDefaults.standard.integer(forKey: "stats_likes"),
            favoritesCount: userDefaults.searchHistory.count // 使用搜索历史作为示例
        )
    }

    // MARK: - 数据加载方法
    /// 加载用户信息
    // Android类比: suspend fun loadUserInfo(userId: Int) { ... }
    func loadUserInfo(userId: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            // 网络请求获取用户信息
            // Android类比: val user = apiService.getUser(userId)
            let user = try await apiService.fetchUser(id: userId)

            // 更新UI状态
            // Android类比: _currentUser.value = user
            currentUser = user

            // 保存到本地
            // Android类比: userDefaults.saveUserInfo(user)
            userDefaults.userId = user.id
            userDefaults.username = user.username

        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription

            // 加载失败时使用本地缓存数据
            // Android类比: currentUser = loadCachedUser()
            loadCachedUser()
        }

        isLoading = false
    }

    /// 从本地加载缓存的用户信息
    // Android类比: private fun loadCachedUser() { ... }
    private func loadCachedUser() {
        if let username = userDefaults.username, let userId = userDefaults.userId {
            // 构建基本用户信息
            // Android类比: User(id = userId, username = username, ...)
            currentUser = User(
                id: userId,
                username: username,
                name: username,
                email: "user@example.com",
                phone: "",
                website: "",
                company: User.Company(name: "", catchPhrase: "", bs: ""),
                address: User.Address(street: "", suite: "", city: "", zipcode: "", geo: User.Address.Geo(lat: "", lng: ""))
            )
        }
    }

    /// 刷新用户信息
    // Android类比: suspend fun refresh() { loadUserInfo() }
    func refresh() async {
        if let userId = userDefaults.userId {
            await loadUserInfo(userId: userId)
        }
    }

    // MARK: - 登录/登出
    /// 登录
    // Android类比: suspend fun login(username: String, password: String): Result<User>
    func login(username: String, password: String) async -> Bool {
        isLoading = true

        do {
            // 模拟登录请求
            // Android类比: val response = authApi.login(username, password)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // 模拟成功登录
            // 实际应用中应该解析响应获取用户ID
            let mockUserId = 1
            userDefaults.saveUserSession(userId: mockUserId, username: username)

            // 加载用户信息
            await loadUserInfo(userId: mockUserId)

            isLoggedIn = true
            return true

        } catch {
            errorMessage = "登录失败: \(error.localizedDescription)"
            isLoggedIn = false
            return false
        }
    }

    /// 登出
    // Android类比: fun logout() { ... }
    func logout() {
        // 清除用户会话
        // Android类比: authManager.logout()
        userDefaults.clearUserSession()

        // 清除状态
        // Android类比: _currentUser.value = null; _isLoggedIn.value = false
        currentUser = nil
        isLoggedIn = false
    }

    // MARK: - 设置管理
    /// 加载设置
    // Android类比: private fun loadSettings() { ... }
    private func loadSettings() {
        appSettings = AppSettings(
            themeMode: userDefaults.themeMode,
            language: userDefaults.language,
            fontSize: userDefaults.fontSize,
            enableNotifications: userDefaults.enableNotifications
        )
    }

    /// 更新主题设置
    // Android类比: fun updateTheme(mode: ThemeMode) { ... }
    func updateTheme(_ mode: UserDefaultsManager.ThemeMode) {
        userDefaults.themeMode = mode
        appSettings.themeMode = mode
    }

    /// 更新语言设置
    // Android类比: fun updateLanguage(language: String) { ... }
    func updateLanguage(_ language: String) {
        userDefaults.language = language
        appSettings.language = language
    }

    /// 更新字体大小
    // Android类比: fun updateFontSize(size: Float) { ... }
    func updateFontSize(_ size: Double) {
        userDefaults.fontSize = size
        appSettings.fontSize = size
    }

    /// 切换通知设置
    // Android类比: fun toggleNotifications(enabled: Boolean) { ... }
    func toggleNotifications(_ enabled: Bool) {
        userDefaults.enableNotifications = enabled
        appSettings.enableNotifications = enabled
    }

    // MARK: - 用户操作
    /// 更新用户信息
    // Android类比: suspend fun updateProfile(info: ProfileInfo): Result<User>
    func updateProfile(name: String, email: String, phone: String) async -> Bool {
        isLoading = true

        do {
            // 模拟网络请求
            // Android类比: apiService.updateProfile(userInfo)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // 更新本地用户信息
            // Android类比: _currentUser.value = currentUser?.copy(...)
            if let user = currentUser {
                // 注意：User是struct，这里需要重新赋值
                // 实际应用中应该有完整的User模型更新方法
                currentUser = User(
                    id: user.id,
                    username: user.username,
                    name: name,
                    email: email,
                    phone: phone,
                    website: user.website,
                    company: user.company,
                    address: user.address
                )
            }

            return true

        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
            return false
        }
    }

    /// 修改密码
    // Android类比: suspend fun changePassword(old: String, new: String): Result<Unit>
    func changePassword(oldPassword: String, newPassword: String) async -> Bool {
        isLoading = true

        do {
            // 模拟API调用
            // Android类比: apiService.changePassword(oldPassword, newPassword)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            return true

        } catch {
            errorMessage = "密码修改失败: \(error.localizedDescription)"
            return false
        }
    }

    /// 删除账户
    // Android类比: suspend fun deleteAccount(): Result<Unit>
    func deleteAccount() async -> Bool {
        isLoading = true

        do {
            // 模拟API调用
            // Android类比: apiService.deleteAccount()
            try await Task.sleep(nanoseconds: 2_000_000_000)

            // 登出
            logout()

            return true

        } catch {
            errorMessage = "删除账户失败: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - 清除数据
    /// 清除缓存
    // Android类比: fun clearCache() { ... }
    func clearCache() {
        // 清除搜索历史
        // Android类比: searchHistoryDao.clear()
        userDefaults.clearSearchHistory()

        // 可以添加更多缓存清除逻辑
        // Android类比: glide.clearDiskCache()
    }

    /// 重置所有设置
    // Android类比: fun resetAllSettings() { ... }
    func resetAllSettings() {
        userDefaults.resetAll()
        loadSettings()
    }

    // MARK: - ViewModel生命周期
    func cancel() {
        // 取消所有异步任务
        // Android类比: viewModelScope.cancel()
    }

    /// 清除错误
    // Android类比: fun clearError() { _errorMessage.value = null }
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - 应用设置模型
// Android类比: data class AppSettings(...)
struct AppSettings {
    var themeMode: UserDefaultsManager.ThemeMode = .system
    var language: String = "zh-Hans"
    var fontSize: Double = 16
    var enableNotifications: Bool = true

    // 主题选项
    static let themeOptions: [(UserDefaultsManager.ThemeMode, String, String)] = [
        (.system, "跟随系统", "system"),
        (.light, "浅色模式", "sun.max.fill"),
        (.dark, "深色模式", "moon.fill")
    ]

    // 语言选项
    static let languageOptions: [(String, String)] = [
        ("zh-Hans", "简体中文"),
        ("en", "English"),
        ("ja", "日本語")
    ]
}

// MARK: - 用户统计模型
// Android类比: data class UserStats(...)
struct UserStats {
    var postsCount: Int = 0
    var commentsCount: Int = 0
    var likesCount: Int = 0
    var favoritesCount: Int = 0
}

