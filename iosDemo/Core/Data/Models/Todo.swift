//
//  Todo.swift
//  iosDemo
//
//  待办事项数据模型
//  Android类比: 类似Kotlin的data class或Room的@Entity
//

import Foundation
import SwiftData

// MARK: - 待办事项模型
// Android类比: 类似data class Todo(...) 或 Room的@Entity
struct Todo: Codable, Identifiable, Equatable {
    // 待办ID
    // Android类比: @PrimaryKey val id: Int
    let id: Int

    // 用户ID
    // Android类比: @ColumnInfo(name = "user_id") val userId: Int
    let userId: Int

    // 待办标题
    // Android类比: @ColumnInfo(name = "title") val title: String
    let title: String

    // 是否完成
    // Android类比: @ColumnInfo(name = "completed") val isCompleted: Boolean
    let isCompleted: Bool

    // MARK: - 计算属性
    // Android类比: 类似Kotlin的扩展函数或计算属性

    /// 状态文本描述
    var statusText: String {
        isCompleted ? "已完成" : "待完成"
    }

    /// 状态图标
    var statusIcon: String {
        isCompleted ? "checkmark.circle.fill" : "circle"
    }

    /// 优先级（基于标题长度简单模拟）
    var priority: TodoPriority {
        if title.contains("紧急") || title.contains("!") {
            return .high
        } else if title.contains("重要") {
            return .medium
        } else {
            return .low
        }
    }

    // MARK: - Mock数据
    // Android类比: 类似companion object中的静态工厂方法
    static let mock = Todo(
        id: 1,
        userId: 1,
        title: "学习SwiftUI基础",
        isCompleted: false
    )

    static let mocks: [Todo] = [
        mock,
        Todo(
            id: 2,
            userId: 1,
            title: "理解MVVM架构模式",
            isCompleted: false
        ),
        Todo(
            id: 3,
            userId: 1,
            title: "掌握async/await异步编程",
            isCompleted: true
        ),
        Todo(
            id: 4,
            userId: 1,
            title: "学习SwiftData持久化框架",
            isCompleted: false
        ),
        Todo(
            id: 5,
            userId: 1,
            title: "实践Combine响应式编程",
            isCompleted: false
        ),
        Todo(
            id: 6,
            userId: 1,
            title: "完成iOS学习Demo项目",
            isCompleted: false
        ),
        Todo(
            id: 7,
            userId: 1,
            title: "阅读SwiftUI官方文档",
            isCompleted: true
        ),
        Todo(
            id: 8,
            userId: 1,
            title: "理解SwiftUI中的状态管理",
            isCompleted: false
        )
    ]
}

// MARK: - 待办优先级枚举
// Android类比: enum class Priority { HIGH, MEDIUM, LOW }
enum TodoPriority: String, CaseIterable {
    case high = "高"
    case medium = "中"
    case low = "低"

    var color: String {
        switch self {
        case .high:
            return "red"
        case .medium:
            return "orange"
        case .low:
            return "green"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

// MARK: - SwiftData持久化模型（iOS 17+）
// Android类比: 类似Room的@Entity定义
@Model
final class TodoItem {
    // 使用UUID作为唯一标识符
    // Android类比: @PrimaryKey val id: String = UUID.randomUUID().toString()
    var id: UUID

    // 待办标题
    // Android类比: @ColumnInfo(name = "title") val title: String
    var title: String

    // 是否完成
    // Android类比: @ColumnInfo(name = "is_completed") val isCompleted: Boolean
    var isCompleted: Bool

    // 优先级
    // Android类比: @ColumnInfo(name = "priority") val priority: String
    var priority: String

    // 创建时间
    // Android类比: @ColumnInfo(name = "created_at") val createdAt: Long
    var createdAt: Date

    // 完成时间
    // Android类比: @ColumnInfo(name = "completed_at") val completedAt: Long?
    var completedAt: Date?

    // 备注
    // Android类比: @ColumnInfo(name = "notes") val notes: String?
    var notes: String?

    // 分类
    // Android类比: @ColumnInfo(name = "category") val category: String?
    var category: String?

    // 截止日期
    // Android类比: @ColumnInfo(name = "due_date") val dueDate: Long?
    var dueDate: Date?

    // 关联标签（使用逗号分隔）
    // Android类比: @Relation注解或关联表
    var tags: [String]

    // MARK: - 计算属性
    /// 是否已过期
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

    /// 是否即将到期（24小时内）
    var isDueSoon: Bool {
        guard let dueDate = dueDate else { return false }
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        return dueDate.timeIntervalSinceNow < twentyFourHours && dueDate.timeIntervalSinceNow > 0 && !isCompleted
    }

    // MARK: - 初始化方法
    // Android类比: 类似Kotlin的init块或constructor
    init(
        title: String,
        priority: TodoPriority = .medium,
        notes: String? = nil,
        category: String? = nil,
        dueDate: Date? = nil,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.priority = priority.rawValue
        self.createdAt = Date()
        self.notes = notes
        self.category = category
        self.dueDate = dueDate
        self.tags = tags
    }

    // MARK: - 便捷方法
    /// 标记为完成
    // Android类比: fun markAsCompleted() { isCompleted = true; completedAt = System.currentTimeMillis() }
    func markAsCompleted() {
        isCompleted = true
        completedAt = Date()
    }

    /// 标记为未完成
    // Android类比: fun markAsIncomplete() { isCompleted = false; completedAt = null }
    func markAsIncomplete() {
        isCompleted = false
        completedAt = nil
    }

    /// 切换完成状态
    // Android类比: fun toggleCompleted() { isCompleted = !isCompleted }
    func toggleCompleted() {
        if isCompleted {
            markAsIncomplete()
        } else {
            markAsCompleted()
        }
    }

    // MARK: - 便捷查询方法
    // Android类比: 类似Room的@Query注解的DAO方法

    /// 查询所有未完成的待办
    /// Android类比: @Query("SELECT * FROM todos WHERE is_completed = 0 ORDER BY priority ASC, created_at DESC")
    static func fetchIncomplete() -> FetchDescriptor<TodoItem> {
        var descriptor = FetchDescriptor<TodoItem>(predicate: #Predicate { $0.isCompleted == false })
        descriptor.sortBy = [
            SortDescriptor(\.priority, order: .forward),
            SortDescriptor(\.createdAt, order: .reverse)
        ]
        return descriptor
    }

    /// 查询所有已完成的待办
    /// Android类比: @Query("SELECT * FROM todos WHERE is_completed = 1 ORDER BY completed_at DESC")
    static func fetchCompleted() -> FetchDescriptor<TodoItem> {
        var descriptor = FetchDescriptor<TodoItem>(predicate: #Predicate { $0.isCompleted == true })
        descriptor.sortBy = [SortDescriptor(\.completedAt, order: .reverse)]
        return descriptor
    }

    /// 搜索待办
    /// Android类比: @Query("SELECT * FROM todos WHERE title LIKE :query OR notes LIKE :query")
    static func search(query: String) -> FetchDescriptor<TodoItem> {
        FetchDescriptor<TodoItem>(predicate: #Predicate {
            $0.title.contains(query) || ($0.notes != nil && $0.notes!.contains(query))
        })
    }

    /// 按分类查询
    /// Android类比: @Query("SELECT * FROM todos WHERE category = :category")
    static func fetchByCategory(category: String) -> FetchDescriptor<TodoItem> {
        var descriptor = FetchDescriptor<TodoItem>(predicate: #Predicate { $0.category == category })
        descriptor.sortBy = [
            SortDescriptor(\.priority, order: .forward),
            SortDescriptor(\.createdAt, order: .reverse)
        ]
        return descriptor
    }
}

// MARK: - 待办分类枚举
// Android类比: enum class Category(val displayName: String)
enum TodoCategory: String, CaseIterable {
    case work = "工作"
    case study = "学习"
    case life = "生活"
    case health = "健康"
    case other = "其他"

    var displayName: String { rawValue }
    var iconName: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .life: return "house.fill"
        case .health: return "heart.fill"
        case .other: return "folder.fill"
        }
    }
}
