//
//  Post.swift
//  iosDemo
//
//  帖子数据模型
//  Android类比: 类似Kotlin的data class或Room的@Entity
//

import Foundation
import SwiftData

// MARK: - 帖子模型
// Android类比: 类似data class Post(...) 或 Room的@Entity
struct Post: Codable, Identifiable, Equatable {
    // 帖子ID
    // Android类比: @PrimaryKey val id: Int
    let id: Int

    // 用户ID（外键）
    // Android类比: @ColumnInfo(name = "user_id") val userId: Int
    let userId: Int

    // 标题
    // Android类比: @ColumnInfo(name = "title") val title: String
    let title: String

    // 内容/正文
    // Android类比: @ColumnInfo(name = "body") val body: String
    let body: String

    // MARK: - 计算属性
    // Android类比: 类似Kotlin的扩展函数或计算属性

    /// 截取的标题预览（用于列表显示）
    var truncatedTitle: String {
        String(title.prefix(50))
    }

    /// 截取的内容预览（用于列表显示）
    var truncatedBody: String {
        String(body.prefix(100))
    }

    /// 是否为长标题
    var isLongTitle: Bool {
        title.count > 50
    }

    /// 是否为长内容
    var isLongBody: Bool {
        body.count > 100
    }

    // MARK: - 相等性判断
    // Android类比: 类似Kotlin的data class自动生成的equals()
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Mock数据
    // Android类比: 类似companion object中的静态工厂方法
    static let mock = Post(
        id: 1,
        userId: 1,
        title: "SwiftUI学习笔记 - 与Jetpack Compose的对比",
        body: "SwiftUI是苹果推出的声明式UI框架，类似于Android的Jetpack Compose。它们都采用声明式编程范式，让开发者以更直观的方式构建用户界面。本文将从多个角度对比这两个框架的异同，帮助Android开发者快速理解SwiftUI。"
    )

    static let mocks: [Post] = [
        mock,
        Post(
            id: 2,
            userId: 1,
            title: "async/await与Coroutines对比",
            body: "Swift的async/await语法与Kotlin的Coroutines非常相似，都是用于处理异步操作的现代语法糖。它们都提供了结构化并发的能力，让异步代码像同步代码一样易读。"
        ),
        Post(
            id: 3,
            userId: 2,
            title: "SwiftData vs Room数据库框架对比",
            body: "SwiftData是iOS 17引入的新持久化框架，类似于Android的Room。它们都提供了类型安全的ORM操作，支持编译时SQL验证，以及响应式数据查询。"
        ),
        Post(
            id: 4,
            userId: 2,
            title: "Combine框架详解",
            body: "Combine是Apple提供的响应式编程框架，类似于Android的Flow/RxJava。它提供了丰富的操作符用于处理数据流，配合SwiftUI可以实现优雅的数据绑定。"
        ),
        Post(
            id: 5,
            userId: 3,
            title: "iOS开发中的MVVM架构实践",
            body: "MVVM架构在iOS开发中有着广泛的应用，配合@Observable宏和Combine框架，可以实现与Android类似的响应式架构。本文详细介绍如何在SwiftUI中实现MVVM模式。"
        )
    ]
}

// MARK: - SwiftData持久化模型（iOS 17+）
// Android类比: 类似Room的@Entity定义
@Model
final class PostEntity {
    var id: Int
    var userId: Int
    var title: String
    var body: String
    var isFavorite: Bool
    var createdAt: Date
    var readAt: Date?

    // 关联用户
    @Relationship(deleteRule: .nullify) var author: UserEntity?

    init(post: Post) {
        self.id = post.id
        self.userId = post.userId
        self.title = post.title
        self.body = post.body
        self.isFavorite = false
        self.createdAt = Date()
    }

    // 转换为普通Post模型
    // Android类比: 类似Entity到Domain Model的转换函数
    func toPost() -> Post {
        Post(
            id: id,
            userId: userId,
            title: title,
            body: body
        )
    }

    // MARK: - 便捷查询方法
    // Android类比: 类似Room的@Query注解的DAO方法

    /// 查询所有帖子
    /// Android类比: @Query("SELECT * FROM posts") fun getAllPosts(): Flow<List<Post>>
    static func fetchAll(descriptor: FetchDescriptor<PostEntity> = FetchDescriptor<PostEntity>()) -> FetchDescriptor<PostEntity> {
        var descriptor = descriptor
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        return descriptor
    }

    /// 查询收藏的帖子
    /// Android类比: @Query("SELECT * FROM posts WHERE is_favorite = 1") fun getFavoritePosts(): Flow<List<Post>>
    static func fetchFavorites() -> FetchDescriptor<PostEntity> {
        var descriptor = FetchDescriptor<PostEntity>(predicate: #Predicate { $0.isFavorite == true })
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        return descriptor
    }

    /// 搜索帖子
    /// Android类比: @Query("SELECT * FROM posts WHERE title LIKE :query") fun searchPosts(query: String): Flow<List<Post>>
    static func search(query: String) -> FetchDescriptor<PostEntity> {
        FetchDescriptor<PostEntity>(predicate: #Predicate { $0.title.contains(query) || $0.body.contains(query) })
    }
}

// MARK: - 评论模型
// Android类比: data class Comment(...)
struct Comment: Codable, Identifiable, Equatable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String

    // 计算属性
    var displayName: String {
        name.components(separatedBy: " ").first ?? name
    }

    // Mock数据
    static let mock = Comment(
        id: 1,
        postId: 1,
        name: "张三",
        email: "zhangsan@example.com",
        body: "这篇文章写得太好了！帮助我快速理解了SwiftUI的要点。"
    )

    static let mocks: [Comment] = [
        mock,
        Comment(
            id: 2,
            postId: 1,
            name: "李四",
            email: "lisi@example.com",
            body: "作为Android开发者，这个对比非常有用！期待更多类似的文章。"
        ),
        Comment(
            id: 3,
            postId: 1,
            name: "王五",
            email: "wangwu@example.com",
            body: "请问有没有完整的示例项目可以参考？"
        ),
        Comment(
            id: 4,
            postId: 1,
            name: "赵六",
            email: "zhaoliu@example.com",
            body: "SwiftData和Room的对比部分写得很清楚，感谢分享！"
        ),
        Comment(
            id: 5,
            postId: 1,
            name: "孙七",
            email: "sunqi@example.com",
            body: "希望能看到更多关于async/await的详细用法。"
        )
    ]
}

// MARK: - 帖子展示模型（用于UI）
// Android类比: 类似RecyclerView的ViewHolder数据模型或Compose的UiState
struct PostItem: Identifiable {
    let id: Int
    let title: String
    let body: String
    let authorName: String
    var isFavorite: Bool
    let commentCount: Int
    let createdAt: Date

    // 从Post转换
    // Android类比: 类似Mapper函数
    init(post: Post, author: User? = nil, isFavorite: Bool = false, commentCount: Int = 0) {
        self.id = post.id
        self.title = post.title
        self.body = post.body
        self.authorName = author?.displayName ?? "匿名用户"
        self.isFavorite = isFavorite
        self.commentCount = commentCount
        self.createdAt = Date()
    }

    // Mock数据
    static let mock = PostItem(
        post: Post.mock,
        author: User.mock,
        isFavorite: true,
        commentCount: 5
    )
}
