//
//  HomeViewModel.swift
//  iosDemo
//
//  首页ViewModel - 管理首页数据和业务逻辑
//  Android类比: 类似Jetpack ViewModel + StateFlow/LiveData
//

import Foundation
import Observation

// MARK: - 首页ViewModel
// Android类比: class HomeViewModel : ViewModel()
@Observable
class HomeViewModel {

    // MARK: - UI状态（使用@Observable宏自动发布变化）
    // Android类比: private val _uiState = MutableStateFlow<UiState>(UiState.Idle)

    /// 加载状态
    // Android类比: val isLoading: StateFlow<Boolean>
    var isLoading: Bool = false {
        didSet {
            // 状态变化会自动通知观察者
            // Android类比: _uiState.value = UiState.Loading
        }
    }

    /// 错误信息
    // Android类比: val errorMessage: StateFlow<String?>
    var errorMessage: String? = nil

    /// 帖子列表
    // Android类比: val posts: StateFlow<List<Post>>
    var posts: [Post] = []

    /// 搜索关键词
    // Android类比: val searchQuery: StateFlow<String>
    var searchQuery: String = "" {
        didSet {
            filterPosts()
        }
    }

    /// 当前页面（用于分页）
    // Android类比: private var currentPage: Int = 1
    private var currentPage: Int = 1

    /// 是否还有更多数据
    // Android类比: val hasMore: Boolean
    var hasMore: Bool = true

    // MARK: - 依赖注入
    // Android类比: private val apiService: APIService = inject()
    private let apiService: APIServiceProtocol

    // MARK: - 初始化
    // Android类比: init(apiService: APIService = retrofit.create(APIService::class.java))
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    // MARK: - 计算属性（Computed Properties）
    // Android类比: val filteredPosts: List<Post> get() = ...

    /// 过滤后的帖子列表
    /// 根据搜索关键词过滤帖子
    // Android类比: val filteredPosts: List<Post>
    var filteredPosts: [Post] {
        if searchQuery.isEmpty {
            return posts
        }
        return posts.filter { post in
            post.title.localizedCaseInsensitiveContains(searchQuery) ||
            post.body.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    /// 是否有内容显示
    // Android类比: val hasContent: Boolean get() = posts.isNotEmpty()
    var hasContent: Bool {
        !filteredPosts.isEmpty
    }

    /// 是否显示空状态
    // Android类比: val showEmptyState: Boolean get() = ...
    var showEmptyState: Bool {
        !isLoading && filteredPosts.isEmpty
    }

    // MARK: - 数据加载方法
    /// 加载帖子列表
    // Android类比: suspend fun loadPosts() { ... }
    func loadPosts() async {
        // 防止重复加载
        // Android类比: if (isLoading.value) return
        guard !isLoading else { return }

        // 开始加载
        // Android类比: _isLoading.value = true
        isLoading = true
        errorMessage = nil

        do {
            // 网络请求
            // Android类比: val response = apiService.getPosts()
            let fetchedPosts = try await apiService.fetchPosts()

            // 更新数据
            // Android类比: _posts.value = response
            posts = fetchedPosts
            currentPage = 1
            hasMore = fetchedPosts.count >= APIConstants.defaultPageSize

            print("成功加载 \(fetchedPosts.count) 条帖子")

        } catch {
            // 错误处理
            // Android类比: _errorMessage.value = error.message
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            print("加载失败: \(error)")
        }

        // 结束加载
        // Android类比: _isLoading.value = false
        isLoading = false
    }

    /// 刷新数据（下拉刷新）
    // Android类比: suspend fun refresh() { ... }
    func refresh() async {
        currentPage = 1
        hasMore = true
        await loadPosts()
    }

    /// 加载更多（上拉加载）
    // Android类比: suspend fun loadMore() { ... }
    func loadMore() async {
        // 防止重复加载或无更多数据
        // Android类比: if (isLoading.value || !hasMore) return
        guard !isLoading && hasMore else { return }

        isLoading = true

        do {
            // 加载下一页
            currentPage += 1
            // 注：JSONPlaceholder的API实际上不支持分页，这里只是演示
            let newPosts = try await apiService.fetchPosts()

            // 追加数据
            // Android类比: _posts.value += newPosts
            posts.append(contentsOf: newPosts)

            // 检查是否还有更多
            hasMore = newPosts.count >= APIConstants.defaultPageSize

        } catch {
            currentPage -= 1 // 回退页码
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - 数据操作方法
    /// 过滤帖子
    // Android类比: private fun filterPosts() { ... }
    private func filterPosts() {
        // 计算属性会自动重新计算
        // Android类比: _filteredPosts.value = computeFilteredPosts()
    }

    /// 搜索帖子
    // Android类比: fun search(query: String) { ... }
    func search(query: String) {
        searchQuery = query
    }

    /// 清除搜索
    // Android类比: fun clearSearch() { ... }
    func clearSearch() {
        searchQuery = ""
    }

    /// 切换帖子收藏状态
    // Android类比: fun toggleFavorite(postId: Int) { ... }
    func toggleFavorite(postId: Int) -> Bool {
        return UserDefaultsManager.shared.toggleFavorite(postId: postId)
    }

    /// 检查帖子是否已收藏
    // Android类比: fun isFavorite(postId: Int): Boolean { ... }
    func isFavorite(postId: Int) -> Bool {
        return UserDefaultsManager.shared.isFavorite(postId: postId)
    }

    // MARK: - ViewModel生命周期
    /// 取消所有异步任务
    // Android类比: override fun onCleared() { ... }
    func cancel() {
        // 在实际应用中，这里应该取消所有未完成的网络请求
        // Android类比: viewModelScope.cancel()
    }

    /// 清除错误信息
    // Android类比: fun clearError() { _errorMessage.value = null }
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - UI状态定义（可选）
// Android类比: sealed class UiState { ... }
enum HomeUiState {
    case idle
    case loading
    case success(posts: [Post])
    case error(message: String)
    case empty
}

