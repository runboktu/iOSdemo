//
//  DetailViewModel.swift
//  iosDemo
//
//  详情页ViewModel - 管理帖子详情和评论数据
//  Android类比: 类似Jetpack ViewModel + StateFlow/LiveData
//

import Foundation
import Observation

// MARK: - 详情页ViewModel
// Android类比: class DetailViewModel : ViewModel()
@Observable
class DetailViewModel {

    // MARK: - UI状态
    /// 帖子数据
    // Android类比: val post: StateFlow<Post?>
    var post: Post?

    /// 作者数据
    // Android类比: val author: StateFlow<User?>
    var author: User?

    /// 评论列表
    // Android类比: val comments: StateFlow<List<Comment>>
    var comments: [Comment] = []

    /// 是否正在加载
    // Android类比: val isLoading: StateFlow<Boolean>
    var isLoading: Bool = false

    /// 是否正在加载评论
    // Android类比: val isLoadingComments: StateFlow<Boolean>
    var isLoadingComments: Bool = false

    /// 错误信息
    // Android类比: val errorMessage: StateFlow<String?>
    var errorMessage: String? = nil

    /// 是否收藏
    // Android类比: val isFavorite: StateFlow<Boolean>
    var isFavorite: Bool = false {
        didSet {
            // 状态变化自动通知
        }
    }

    // MARK: - 依赖注入
    private let apiService: APIServiceProtocol
    private let userDefaults: UserDefaultsManager

    // MARK: - 初始化
    // Android类比: init(post: Post, apiService: APIService = inject())
    init(
        post: Post,
        apiService: APIServiceProtocol = APIService.shared,
        userDefaults: UserDefaultsManager = .shared
    ) {
        self.post = post
        self.apiService = apiService
        self.userDefaults = userDefaults

        // 检查收藏状态
        // Android类比: isFavorite = checkFavorite(post.id)
        self.isFavorite = userDefaults.isFavorite(postId: post.id)
    }

    // MARK: - 计算属性
    /// 是否有评论
    // Android类比: val hasComments: Boolean get() = comments.isNotEmpty
    var hasComments: Bool {
        !comments.isEmpty
    }

    /// 评论数量
    // Android类比: val commentCount: Int get() = comments.size
    var commentCount: Int {
        comments.count
    }

    /// 是否有错误
    // Android类比: val hasError: Boolean get() = errorMessage != null
    var hasError: Bool {
        errorMessage != nil
    }

    // MARK: - 数据加载方法
    /// 加载帖子详情
    // Android类比: suspend fun loadPostDetail() { ... }
    func loadPostDetail() async {
        guard let post = post else { return }

        isLoading = true
        errorMessage = nil

        do {
            // 并行加载作者和评论
            // Android类比: coroutineScope { launch { loadAuthor() }; launch { loadComments() } }
            async let authorData = apiService.fetchUser(id: post.userId)
            async let commentsData = apiService.fetchComments(postId: post.id)

            // 等待所有请求完成
            // Android类比: awaitAll()
            let (fetchedAuthor, fetchedComments) = try await (authorData, commentsData)

            // 更新UI状态
            // Android类比: _author.value = fetchedAuthor; _comments.value = fetchedComments
            author = fetchedAuthor
            comments = fetchedComments

        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    /// 加载作者信息
    // Android类比: private suspend fun loadAuthor() { ... }
    private func loadAuthor() async {
        guard let post = post else { return }

        do {
            let fetchedAuthor = try await apiService.fetchUser(id: post.userId)
            author = fetchedAuthor
        } catch {
            print("加载作者失败: \(error)")
        }
    }

    /// 加载评论
    // Android类比: private suspend fun loadComments() { ... }
    private func loadComments() async {
        guard let post = post else { return }

        isLoadingComments = true

        do {
            let fetchedComments = try await apiService.fetchComments(postId: post.id)
            comments = fetchedComments
        } catch {
            print("加载评论失败: \(error)")
        }

        isLoadingComments = false
    }

    /// 加载更多评论（分页）
    // Android类比: suspend fun loadMoreComments() { ... }
    func loadMoreComments() async {
        // 当前API不支持分页，这里只是示例
        // Android类比: if (hasMore) { ... }
        guard !isLoadingComments else { return }

        await loadComments()
    }

    // MARK: - 交互方法
    /// 切换收藏状态
    // Android类比: fun toggleFavorite() { ... }
    func toggleFavorite() -> Bool {
        guard let post = post else { return false }

        let newState = userDefaults.toggleFavorite(postId: post.id)
        isFavorite = newState

        // 触觉反馈（在View层处理）
        return newState
    }

    /// 分享帖子
    // Android类比: fun sharePost() { ... }
    func sharePost() -> String? {
        guard let post = post else { return nil }

        // 构建分享内容
        // Android类比: Intent(Intent.ACTION_SEND).putExtra(Intent.EXTRA_TEXT, ...)
        let shareText = """
        \(post.title)

        \(post.body)

        来自 iLearn App
        """

        return shareText
    }

    /// 复制链接
    // Android类比: fun copyLink() { ... }
    func copyLink() -> String {
        guard let post = post else { return "" }

        // 模拟帖子链接
        // Android类比: val url = "https://ilearn.app/posts/${post.id}"
        return "https://ilearn.app/posts/\(post.id)"
    }

    /// 举报帖子
    // Android类比: fun reportPost(reason: String) { ... }
    func reportPost(reason: String) async -> Bool {
        // 实际应用中应该调用举报API
        // Android类比: apiService.reportPost(postId, reason)
        print("举报帖子: \(post?.id ?? 0), 原因: \(reason)")

        // 模拟API调用
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        return true
    }

    /// 删除帖子（如果是作者）
    // Android类比: suspend fun deletePost() { ... }
    func deletePost() async -> Bool {
        // 实际应用中应该调用删除API
        // Android类比: apiService.deletePost(postId)
        guard let post = post else { return false }

        print("删除帖子: \(post.id)")

        // 模拟API调用
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        return true
    }

    /// 关注作者
    // Android类比: suspend fun followAuthor() { ... }
    func followAuthor() async -> Bool {
        // 实际应用中应该调用关注API
        // Android类比: apiService.followUser(authorId)
        guard let author = author else { return false }

        print("关注作者: \(author.id)")

        // 模拟API调用
        try? await Task.sleep(nanoseconds: 500_000_000)

        return true
    }

    // MARK: - 评论操作
    /// 删除评论
    // Android类比: suspend fun deleteComment(commentId: Int) { ... }
    func deleteComment(commentId: Int) async -> Bool {
        // 实际应用中应该调用删除评论API
        // Android类比: apiService.deleteComment(commentId)
        print("删除评论: \(commentId)")

        // 从列表中移除
        // Android类比: _comments.value = comments.filter { it.id != commentId }
        comments.removeAll { $0.id == commentId }

        return true
    }

    /// 举报评论
    // Android类比: suspend fun reportComment(commentId: Int, reason: String) { ... }
    func reportComment(commentId: Int, reason: String) async -> Bool {
        print("举报评论: \(commentId), 原因: \(reason)")

        try? await Task.sleep(nanoseconds: 500_000_000)

        return true
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

// MARK: - 详情页UI状态
// Android类比: sealed class DetailUiState { ... }
enum DetailUiState {
    case idle
    case loading
    case success(post: Post, author: User?, comments: [Comment])
    case error(message: String)
}

// MARK: - 评论展示模型
// Android类比: data class CommentItem(val ...)
struct CommentItem: Identifiable {
    let id: Int
    let name: String
    let email: String
    let body: String
    let avatar: String
    let createdAt: Date

    // 从Comment转换
    // Android类比: fun Comment.toItem(): CommentItem { ... }
    init(comment: Comment) {
        self.id = comment.id
        self.name = comment.name
        self.email = comment.email
        self.body = comment.body
        self.avatar = String(comment.name.prefix(1))
        self.createdAt = Date()
    }
}
