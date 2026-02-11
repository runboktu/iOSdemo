//
//  TodoListView.swift
//  iosDemo
//
//  待办列表视图 - 显示和管理待办事项
//  Android类比: 类似TodoFragment或TodoActivity
//

import SwiftUI
import SwiftData

// MARK: - 待办列表视图
// Android类比: class TodoFragment : Fragment()
struct TodoListView: View {

    // MARK: - 状态
    /// 新建待办输入
    // Android类比: val newTodoInput = MutableLiveData<String>()
    @FocusState private var isNewTodoFocused: Bool

    /// 显示分类选择
    @State private var showCategoryPicker: Bool = false

    /// 选中的分类
    @State private var selectedCategory: TodoCategory? = nil

    // MARK: - 依赖注入
    /// ModelContext（从环境获取）
    // Android类比: private val db: AppDatabase = inject()
    @Environment(\.modelContext) private var modelContext

    // MARK: - 视图
    var body: some View {
        // 创建ViewModel
        // Android类比: private val viewModel: TodoListViewModel by viewModels()
        TodoListContainerView(viewModel: TodoListViewModel(modelContext: modelContext))
    }
}

// MARK: - ViewModel容器视图
// Android类比: 类似Fragment的视图容器
private struct TodoListContainerView: View {
    @State private var viewModel: TodoListViewModel

    // 初始化
    init(viewModel: TodoListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 进度卡片
                // Android类比: include progress_card.xml
                progressCard

                // 筛选栏
                // Android类比: include filter_bar.xml
                filterBar

                // 待办列表
                // Android类比: RecyclerView with todos
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.showEmptyState {
                    emptyView
                } else {
                    todoList
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                // 新建按钮
                // Android类比: FAB (FloatingActionButton)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddDialog = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // 新建待办弹窗
            // Android类比: AlertDialog or BottomSheetDialog
            .sheet(isPresented: $viewModel.showAddDialog) {
                addTodoSheet
            }
            // 编辑待办弹窗
            .sheet(item: Binding(
                get: { viewModel.editingTodo.map { EditWrapper(value: $0) } },
                set: { viewModel.editingTodo = $0?.value }
            )) { wrapper in
                EditTodoSheet(todo: wrapper.value)
            }
            // 错误提示
            .alertError(error: $viewModel.errorMessage)
        }
    }

    // MARK: - 进度卡片
    // Android类比: progress_card.xml
    @ViewBuilder
    private var progressCard: some View {
        VStack(spacing: Spacing.sm) {
            // 进度条
            // Android类比: ProgressBar
            HStack {
                Text("完成进度")
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(Int(viewModel.progress * 100))%")
                    .font(Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    // Android类比: ProgressBar background
                    RoundedRectangle(cornerRadius: Spacing.xxxs)
                        .fill(AppColors.gray200)
                        .frame(height: 8)

                    // 进度条
                    // Android类比: ProgressBar progress
                    RoundedRectangle(cornerRadius: Spacing.xxxs)
                        .fill(AppColors.primary)
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                        .animation(.easeInOut, value: viewModel.progress)
                }
            }
            .frame(height: 8)

            // 统计信息
            // Android类比: TextView with stats
            HStack(spacing: Spacing.lg) {
                Label("\(viewModel.activeCount) 进行中", systemImage: "circle")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Label("\(viewModel.completedCount) 已完成", systemImage: "checkmark.circle.fill")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()
            }
        }
        .padding(Spacing.cardPadding)
        .background(AppColors.gray100)
    }

    // MARK: - 筛选栏
    // Android类比: filter_bar.xml 或 ChipGroup
    @ViewBuilder
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                // 筛选按钮
                // Android类比: Chip 或 MaterialButton
                ForEach([TodoFilter.all, .active, .completed], id: \.displayName) { filter in
                    FilterChip(
                        title: filter.displayName,
                        icon: filter.iconName,
                        isSelected: viewModel.filterType == filter
                    ) {
                        viewModel.setFilter(filter)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - 待办列表
    // Android类比: RecyclerView with TodoAdapter
    @ViewBuilder
    private var todoList: some View {
        List {
            ForEach(viewModel.filteredTodos) { todo in
                TodoCell(
                    todo: todo,
                    onToggle: {
                        viewModel.toggleTodo(todo)
                    },
                    onEdit: {
                        viewModel.startEditing(todo)
                    },
                    onDelete: {
                        viewModel.deleteTodo(todo)
                    }
                )
                .listRowInsets(EdgeInsets(top: Spacing.xxxs, leading: Spacing.sm, bottom: Spacing.xxxs, trailing: Spacing.sm))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // 滑动删除
                    // Android类比: ItemTouchHelper.SimpleCallback
                    Button(role: .destructive, action: {
                        viewModel.deleteTodo(todo)
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - 加载视图
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("加载中...")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 空视图
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: viewModel.filterType == .completed ? "checkmark.circle" : "tray")
                .font(.system(size: 64))
                .foregroundColor(AppColors.gray400)

            Text(viewModel.filterType == .completed ? "暂无已完成的待办" : "暂无待办事项")
                .font(Typography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("点击右上角 + 添加新待办")
                .font(Typography.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }

    // MARK: - 新建待办弹窗
    @ViewBuilder
    private var addTodoSheet: some View {
        NavigationStack {
            AddTodoView()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - 筛选芯片组件
// Android类比: Material Design的Chip组件
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxxs) {
                Image(systemName: icon)
                    .font(.system(size: 12))

                Text(title)
                    .font(Typography.callout)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? AppColors.primary : AppColors.gray100)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .cornerRadius(Spacing.cornerRadiusSM)
        }
    }
}

// MARK: - 待办单元格
// Android类比: class TodoViewHolder : RecyclerView.ViewHolder
struct TodoCell: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 完成状态按钮
            // Android类比: CheckBox or CheckableImageView
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onToggle()
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.isCompleted ? AppColors.success : AppColors.gray400)
            }
            .buttonStyle(PlainButtonStyle())

            // 待办内容
            // Android类比: TextView with todo title
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(todo.title)
                    .font(Typography.callout)
                    .foregroundColor(todo.isCompleted ? AppColors.gray500 : AppColors.textPrimary)
                    .strikethrough(todo.isCompleted)

                // 元信息
                // Android类比: TextView with metadata
                HStack(spacing: Spacing.xxxs) {
                    if let category = todo.category {
                        Text(category)
                            .font(Typography.caption)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(AppColors.primary.opacity(0.1))
                            .foregroundColor(AppColors.primary)
                            .cornerRadius(4)
                    }

                    if todo.isCompleted, let completedAt = todo.completedAt {
                        Text("完成于 \(completedAt, style: .relative) up to now")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }

            Spacer()

            // 编辑按钮
            // Android类比: ImageButton
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.gray400)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(Spacing.sm)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.cornerRadiusMD)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - 新建待办视图
struct AddTodoView: View {
    @Environment(TodoListViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var selectedCategory: TodoCategory? = nil
    @State private var notes: String = ""

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: Spacing.lg) {
            // 标题输入
            // Android类比: EditText
            TextField("添加新待办...", text: $viewModel.newTodoTitle)
                .textFieldStyle(.roundedBorder)
                .font(Typography.body)
                .focused($isFocused)
                .onSubmit {
                    saveTodo()
                }

            // 分类选择
            // Android类比: RadioGroup or ChipGroup
            if let selectedCategory = selectedCategory {
                HStack {
                    Text(selectedCategory.rawValue)
                        .font(Typography.callout)
                        .foregroundColor(AppColors.primary)

                    Button("清除") {
                        self.selectedCategory = nil
                    }
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                    Spacer()
                }
            }

            // 备注输入
            // Android类比: EditText (multiline)
            TextField("备注（可选）", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(Typography.body)
                .lineLimit(3...6)

            // 分类选择器
            Picker("分类", selection: $selectedCategory) {
                Text("无").tag(TodoCategory?.none)
                ForEach(TodoCategory.allCases, id: \.self) { category in
                    Text(category.displayName).tag(category as TodoCategory?)
                }
            }
            .pickerStyle(.segmented)

            Spacer()
        }
        .padding(Spacing.md)
        .navigationTitle("新待办")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveTodo()
                }
                .disabled(viewModel.newTodoTitle.isEmpty)
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private func saveTodo() {
        viewModel.addTodo(
            title: viewModel.newTodoTitle,
            category: selectedCategory?.rawValue,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}

// MARK: - 编辑待办视图
struct EditTodoSheet: View {
    @Environment(TodoListViewModel.self) private var viewModel
    let todo: TodoItem
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel
        Form {
            Section {
                TextField("标题", text: $viewModel.newTodoTitle)
                    .focused($isFocused)
            } header: {
                Text("待办标题")
            }

            Section {
                if let category = todo.category {
                    HStack {
                        Text("分类")
                        Spacer()
                        Text(category)
                            .foregroundColor(.secondary)
                    }
                }

                if let notes = todo.notes {
                    HStack {
                        Text("备注")
                        Spacer()
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("状态")
                    Spacer()
                    Text(todo.isCompleted ? "已完成" : "进行中")
                        .foregroundColor(todo.isCompleted ? .green : .orange)
                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isCompleted ? .green : .orange)
                }
            } header: {
                Text("详细信息")
            }

            Section {
                Button(role: .destructive) {
                    viewModel.deleteTodo(todo)
                    dismiss()
                } label: {
                    Label("删除待办", systemImage: "trash")
                }
            }
        }
        .navigationTitle("编辑待办")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    viewModel.cancelEditing()
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    viewModel.saveEdit()
                    dismiss()
                }
                .disabled(viewModel.newTodoTitle.isEmpty)
            }
        }
        .onAppear {
            viewModel.newTodoTitle = todo.title
            isFocused = true
        }
    }
}

// MARK: - EditWrapper（用于可选值绑定）
struct EditWrapper: Identifiable {
    let id = UUID()
    let value: TodoItem
}

// MARK: - 预览
#Preview("Todo List View") {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

#Preview("Todo Cell") {
    VStack(spacing: Spacing.sm) {
        TodoCell(
            todo: TodoItem(title: "学习SwiftUI"),
            onToggle: {},
            onEdit: {},
            onDelete: {}
        )

        TodoCell(
            todo: {
                let todo = TodoItem(title: "已完成的待办")
                todo.markAsCompleted()
                return todo
            }(),
            onToggle: {},
            onEdit: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
