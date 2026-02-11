//
//  TodoListViewModel.swift
//  iosDemo
//
//  待办列表ViewModel - 管理待办事项数据和业务逻辑
//  Android类比: 类似Jetpack ViewModel + StateFlow/LiveData
//

import Foundation
import SwiftData
import Observation

// MARK: - 待办列表ViewModel
// Android类比: class TodoListViewModel : ViewModel()
@Observable
class TodoListViewModel {

    // MARK: - UI状态
    /// 待办列表
    // Android类比: val todos: StateFlow<List<TodoItem>>
    var todos: [TodoItem] = []

    /// 过滤类型
    // Android类比: val filterType: StateFlow<FilterType>
    var filterType: TodoFilter = .all

    /// 选中的分类
    // Android类比: val selectedCategory: StateFlow<String?>
    var selectedCategory: String? = nil

    /// 是否正在加载
    // Android类比: val isLoading: StateFlow<Boolean>
    var isLoading: Bool = false

    /// 错误信息
    // Android类比: val errorMessage: StateFlow<String?>
    var errorMessage: String? = nil

    /// 新建待办标题
    // Android类比: val newTodoTitle: MutableStateFlow<String>
    var newTodoTitle: String = ""

    /// 是否显示新建弹窗
    // Android类比: val showAddDialog: MutableStateFlow<Boolean>
    var showAddDialog: Bool = false

    /// 编辑中的待办
    // Android类比: var editingTodo: TodoItem? = null
    var editingTodo: TodoItem? = nil

    // MARK: - 依赖注入
    private let modelContext: ModelContext

    // MARK: - 初始化
    // Android类比: init(modelContext: ModelContext = inject())
    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // 加载待办列表
        // Android类比: loadTodos()
        loadTodos()
    }

    // MARK: - 计算属性
    /// 过滤后的待办列表
    // Android类比: val filteredTodos: List<TodoItem> get() = ...
    var filteredTodos: [TodoItem] {
        let result: [TodoItem]

        // 根据筛选类型过滤
        // Android类比: when(filterType) { ... }
        switch filterType {
        case .all:
            result = todos
        case .active:
            result = todos.filter { !$0.isCompleted }
        case .completed:
            result = todos.filter { $0.isCompleted }
        case .custom(let predicate):
            result = todos.filter { predicate($0) }
        }

        // 根据分类过滤
        // Android类比: if (selectedCategory != null) { result = result.filter { it.category == selectedCategory } }
        if let category = selectedCategory {
            return result.filter { $0.category == category }
        }

        return result
    }

    /// 未完成数量
    // Android类比: val activeCount: Int get() = todos.count { !it.isCompleted }
    var activeCount: Int {
        todos.filter { !$0.isCompleted }.count
    }

    /// 完成数量
    // Android类比: val completedCount: Int get() = todos.count { it.isCompleted }
    var completedCount: Int {
        todos.filter { $0.isCompleted }.count
    }

    /// 是否有内容
    // Android类比: val hasContent: Boolean get() = filteredTodos.isNotEmpty
    var hasContent: Bool {
        !filteredTodos.isEmpty
    }

    /// 是否显示空状态
    // Android类比: val showEmptyState: Boolean
    var showEmptyState: Bool {
        filteredTodos.isEmpty && !isLoading
    }

    /// 完成进度
    // Android类比: val progress: Float get() = completedCount.toFloat() / todos.size.toFloat()
    var progress: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedCount) / Double(todos.count)
    }

    // MARK: - 数据加载
    /// 加载待办列表
    // Android类比: private fun loadTodos() { ... }
    private func loadTodos() {
        isLoading = true

        do {
            // 从SwiftData查询待办列表
            // Android类比: val todos = todoDao.getAllTodos()
            let descriptor = FetchDescriptor<TodoItem>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            todos = try modelContext.fetch(descriptor)

        } catch {
            errorMessage = "加载待办列表失败: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// 刷新数据
    // Android类比: fun refresh() { loadTodos() }
    func refresh() {
        loadTodos()
    }

    // MARK: - 待办操作
    /// 添加新待办
    // Android类比: suspend fun addTodo(title: String) { ... }
    func addTodo(title: String, category: String? = nil, notes: String? = nil) {
        guard !title.isEmpty else { return }

        // 创建新待办
        // Android类比: val todo = TodoEntity(title = title, ...)
        let newTodo = TodoItem(
            title: title,
            priority: .medium,
            notes: notes,
            category: category
        )

        // 保存到数据库
        // Android类比: todoDao.insert(todo)
        modelContext.insert(newTodo)

        do {
            try modelContext.save()
            // 刷新列表
            loadTodos()
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }

        // 清空输入
        // Android类比: newTodoTitle.value = ""
        newTodoTitle = ""
    }

    /// 删除待办
    // Android类比: suspend fun deleteTodo(todo: TodoItem) { ... }
    func deleteTodo(_ todo: TodoItem) {
        // 从数据库删除
        // Android类比: todoDao.delete(todo)
        modelContext.delete(todo)

        do {
            try modelContext.save()
            // 刷新列表
            loadTodos()
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }

    /// 批量删除已完成的待办
    // Android类比: suspend fun deleteCompleted() { ... }
    func deleteCompleted() {
        let completedTodos = todos.filter { $0.isCompleted }

        // 批量删除
        // Android类比: todoDao.delete(completedTodos)
        completedTodos.forEach { modelContext.delete($0) }

        do {
            try modelContext.save()
            loadTodos()
        } catch {
            errorMessage = "批量删除失败: \(error.localizedDescription)"
        }
    }

    /// 切换完成状态
    // Android类比: fun toggleTodo(todo: TodoItem) { ... }
    func toggleTodo(_ todo: TodoItem) {
        // 切换状态
        // Android类比: todo.isCompleted = !todo.isCompleted
        if todo.isCompleted {
            todo.markAsIncomplete()
        } else {
            todo.markAsCompleted()
        }

        // 保存更改
        // Android类比: todoDao.update(todo)
        do {
            try modelContext.save()
            loadTodos()
        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
        }
    }

    /// 更新待办
    // Android类比: suspend fun updateTodo(todo: TodoItem) { ... }
    func updateTodo(_ todo: TodoItem) {
        do {
            try modelContext.save()
            loadTodos()
        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
        }
    }

    /// 设置筛选类型
    // Android类比: fun setFilter(filterType: FilterType) { ... }
    func setFilter(_ filter: TodoFilter) {
        filterType = filter
    }

    /// 设置分类筛选
    // Android类比: fun setCategory(category: String?) { ... }
    func setCategory(_ category: String?) {
        selectedCategory = category
    }

    // MARK: - 编辑操作
    /// 开始编辑
    // Android类比: fun startEditing(todo: TodoItem) { ... }
    func startEditing(_ todo: TodoItem) {
        editingTodo = todo
        newTodoTitle = todo.title
    }

    /// 取消编辑
    // Android类比: fun cancelEditing() { ... }
    func cancelEditing() {
        editingTodo = nil
        newTodoTitle = ""
    }

    /// 保存编辑
    // Android类比: suspend fun saveEdit() { ... }
    func saveEdit() {
        guard let todo = editingTodo else { return }
        guard !newTodoTitle.isEmpty else { return }

        // 更新标题
        // Android类比: todo.title = newTodoTitle
        todo.title = newTodoTitle

        // 保存
        updateTodo(todo)

        // 清除编辑状态
        editingTodo = nil
        newTodoTitle = ""
    }

    // MARK: - 统计信息
    /// 获取分类统计
    // Android类比: fun getCategoryStats(): Map<String, Int>
    func getCategoryStats() -> [String: Int] {
        var stats: [String: Int] = [:]

        for todo in todos {
            let category = todo.category ?? TodoCategory.other.rawValue
            stats[category, default: 0] += 1
        }

        return stats
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

// MARK: - 待办筛选类型
// Android类比: enum class TodoFilter { ALL, ACTIVE, COMPLETED }
enum TodoFilter: Equatable {
    case all
    case active
    case completed
    case custom((TodoItem) -> Bool)

    static func == (lhs: TodoFilter, rhs: TodoFilter) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.active, .active), (.completed, .completed):
            return true
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }
}

// MARK: - 快捷筛选预设
extension TodoFilter {
    /// 获取显示名称
    // Android类比: fun getDisplayName(): String
    var displayName: String {
        switch self {
        case .all:
            return "全部"
        case .active:
            return "进行中"
        case .completed:
            return "已完成"
        case .custom:
            return "自定义"
        }
    }

    /// 获取图标
    // Android类比: fun getIcon(): Int (返回资源ID)
    var iconName: String {
        switch self {
        case .all:
            return "line.3.horizontal.decrease.circle"
        case .active:
            return "circle"
        case .completed:
            return "checkmark.circle.fill"
        case .custom:
            return "slider.horizontal.3"
        }
    }
}
