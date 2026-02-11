//
//  SearchViewModel.swift
//  iosDemo
//
//  搜索页ViewModel - 管理搜索功能和状态
//  Android类比: 类似Jetpack ViewModel + StateFlow/LiveData
//

import Foundation
import Observation

// MARK: - 搜索ViewModel
// Android类比: class SearchViewModel : ViewModel()
@Observable
class SearchViewModel {

    // MARK: - UI状态
    /// 搜索文本
    // Android类比: val searchQuery: StateFlow<String>
    var searchQuery: String = ""

    /// 搜索结果
    // Android类比: val searchResults: StateFlow<List<Post>>
    var searchResults: [Post] = []

    /// 搜索历史
    // Android类比: val searchHistory: StateFlow<List<String>>
    var searchHistory: [String] = []

    /// 热门搜索
    // Android类比: val trendingSearches: StateFlow<List<String>>
    var trendingSearches: [String] = []

    /// 是否正在搜索
    // Android类比: val isSearching: StateFlow<Boolean>
    var isSearching: Bool = false

    /// 错误信息
    // Android类比: val errorMessage: StateFlow<String?>
    var errorMessage: String? = nil

    /// 是否显示清除按钮
    // Android类比: val showClearButton: StateFlow<Boolean>
    var showClearButton: Bool = false {
        didSet {
            // 自动更新UI
        }
    }

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

        // 加载搜索历史
        // Android类比: loadSearchHistory()
        loadSearchHistory()

        // 设置热门搜索
        // Android类比: setupTrendingSearches()
        setupTrendingSearches()
    }

    // MARK: - 计算属性
    /// 是否有搜索结果
    // Android类比: val hasResults: Boolean get() = searchResults.isNotEmpty
    var hasResults: Bool {
        !searchResults.isEmpty
    }

    /// 是否显示空状态
    // Android类比: val showEmptyState: Boolean
    var showEmptyState: Bool {
        !isSearching && !searchQuery.isEmpty && searchResults.isEmpty
    }

    /// 是否显示初始状态
    // Android类比: val showInitialState: Boolean
    var showInitialState: Bool {
        searchQuery.isEmpty
    }

    // MARK: - 搜索方法
    /// 执行搜索
    // Android类比: suspend fun search(query: String) { ... }
    func search(query: String) async {
        searchQuery = query
        showClearButton = !query.isEmpty

        // 空查询时清空结果
        // Android类比: if (query.isEmpty) { clearResults(); return }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        // 开始搜索
        // Android类比: _isSearching.value = true
        isSearching = true
        errorMessage = nil

        do {
            // 执行搜索
            // Android类比: val results = apiService.searchPosts(query)
            let results = try await apiService.searchPosts(query: query)

            // 更新结果
            // Android类比: _searchResults.value = results
            searchResults = results

            // 保存搜索历史
            // Android类比: saveSearchHistory(query)
            if !results.isEmpty {
                saveToHistory(query)
            }

        } catch {
            // 错误处理
            // Android类比: _errorMessage.value = error.message
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            searchResults = []
        }

        // 结束搜索
        // Android类比: _isSearching.value = false
        isSearching = false
    }

    /// 清除搜索
    // Android类比: fun clearSearch() { ... }
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        showClearButton = false
        errorMessage = nil
    }

    // MARK: - 搜索历史管理
    /// 从本地加载搜索历史
    // Android类比: private fun loadSearchHistory() { ... }
    private func loadSearchHistory() {
        searchHistory = userDefaults.searchHistory
    }

    /// 保存到搜索历史
    // Android类比: private fun saveToHistory(query: String) { ... }
    private func saveToHistory(_ query: String) {
        userDefaults.addSearchHistory(query)
        searchHistory = userDefaults.searchHistory
    }

    /// 从历史记录删除
    // Android类比: fun removeFromHistory(query: String) { ... }
    func removeFromHistory(_ query: String) {
        // 重新构建历史（不包含要删除的项）
        // Android类比: searchHistory = searchHistory.filter { it != query }
        var history = userDefaults.searchHistory
        history.removeAll { $0 == query }
        // 更新本地状态
        searchHistory = history
        // 注意：由于searchHistory的setter是私有的，这里只更新本地状态
        // 在实际应用中应该提供一个updateSearchHistory方法
    }

    /// 清空搜索历史
    // Android类比: fun clearHistory() { ... }
    func clearHistory() {
        userDefaults.clearSearchHistory()
        searchHistory = []
    }

    /// 从历史记录选择
    // Android类比: fun selectFromHistory(query: String) { ... }
    func selectFromHistory(_ query: String) {
        Task {
            await search(query: query)
        }
    }

    // MARK: - 热门搜索设置
    /// 设置热门搜索标签
    // Android类比: private fun setupTrendingSearches() { ... }
    private func setupTrendingSearches() {
        trendingSearches = [
            "SwiftUI基础",
            "async/await",
            "SwiftData",
            "MVVM架构",
            "Combine框架",
            "iOS开发技巧"
        ]
    }

    // MARK: - 搜索建议（可选）
    /// 获取搜索建议
    // Android类比: suspend fun getSuggestions(query: String): List<String>
    func getSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return [] }

        // 从历史记录中匹配
        // Android类比: return searchHistory.filter { it.contains(query, ignoreCase = true) }
        let historyMatches = searchHistory.filter {
            $0.localizedCaseInsensitiveContains(query)
        }

        // 从热门搜索中匹配
        // Android类比: + trendingSearches.filter { ... }
        let trendingMatches = trendingSearches.filter {
            $0.localizedCaseInsensitiveContains(query)
        }

        // 合并去重
        // Android类比: return (historyMatches + trendingMatches).distinct()
        return Array(Set(historyMatches + trendingMatches)).sorted()
    }

    // MARK: - 快速搜索标签
    /// 点击快速搜索标签
    // Android类比: fun quickSearch(tag: String) { ... }
    func quickSearch(tag: String) {
        Task {
            await search(query: tag)
        }
    }

    // MARK: - 防抖搜索（实际应用中可使用）
    /// 防抖搜索延迟执行
    // Android类比: 类似Flow的debounce操作符
    @MainActor
    func debouncedSearch(query: String) async {
        // 等待用户停止输入
        // Android类比: .debounce(300)
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms

        // 检查查询是否变化
        guard searchQuery == query else { return }

        await search(query: query)
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

// MARK: - 搜索状态枚举
// Android类比: sealed class SearchState { ... }
enum SearchState {
    case idle              // 初始状态
    case searching         // 搜索中
    case results([Post])   // 有结果
    case empty             // 无结果
    case error(String)     // 错误
}

// MARK: - 搜索建议项
// Android类比: data class SearchSuggestion(val ...)
struct SearchSuggestion: Identifiable {
    let id = UUID()
    let text: String
    let type: SuggestionType

    enum SuggestionType {
        case history   // 历史记录
        case trending  // 热门搜索
        case result    // 搜索结果
    }
}
