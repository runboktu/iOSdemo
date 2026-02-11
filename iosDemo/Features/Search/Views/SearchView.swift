//
//  SearchView.swift
//  iosDemo
//
//  搜索页视图 - 提供搜索功能和搜索结果展示
//  Android类比: 类似SearchActivity或SearchFragment
//

import SwiftUI

// MARK: - 搜索页视图
// Android类比: class SearchFragment : Fragment()
struct SearchView: View {

    // MARK: - 状态
    /// 搜索焦点状态
    // Android类比: var isSearchFocused: Boolean = false
    @FocusState private var isSearchFocused: Bool

    /// 选中的帖子（用于导航）
    // Android类比: var selectedPost: Post? = null
    @State private var selectedPost: Post?

    // MARK: - 依赖注入
    @Environment(SearchViewModel.self) private var viewModel

    // MARK: - 视图
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 根据状态显示不同内容
                // Android类比: ViewFlipper或Fragment切换
                Group {
                    if viewModel.showInitialState {
                        // 初始状态（搜索历史和热门搜索）
                        // Android类比: initialSearchView.isVisible = true
                        initialSearchView
                    } else if viewModel.isSearching {
                        // 搜索中状态
                        // Android类比: progressBar.isVisible = true
                        searchingView
                    } else if viewModel.showEmptyState {
                        // 空结果状态
                        // Android类比: emptyView.isVisible = true
                        emptyResultsView
                    } else {
                        // 搜索结果
                        // Android类比: resultsView.isVisible = true
                        searchResultsView
                    }
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 右侧清除按钮
                // Android类比: menu.findItem(R.id.action_clear).isVisible = showClear
                if viewModel.showClearButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("清除") {
                            viewModel.clearSearch()
                            hideKeyboard()
                        }
                        .foregroundColor(AppColors.primary)
                    }
                }
            }
            .searchable(
                text: Binding(
                    get: { viewModel.searchQuery },
                    set: { newValue in
                        viewModel.searchQuery = newValue
                        if newValue.isEmpty {
                            viewModel.clearSearch()
                        }
                    }
                ),
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "搜索帖子..."
            )
            .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                // 搜索输入变化
                // Android类比: TextWatcher.afterTextChanged
                if newValue.count >= 2 {
                    // 防抖搜索
                    // Android类比: debounce(300)
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 500ms防抖
                        if viewModel.searchQuery == newValue {
                            await viewModel.search(query: newValue)
                        }
                    }
                } else if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedPost != nil },
                set: { if !$0 { selectedPost = nil } }
            )) {
                if let post = selectedPost {
                    DetailView(post: post)
                }
            }
        }
    }

    // MARK: - 初始搜索视图（历史记录 + 热门搜索）
    // Android类比: initialSearchLayout.xml
    @ViewBuilder
    private var initialSearchView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                // 搜索历史
                // Android类比: RecyclerView with search history
                if !viewModel.searchHistory.isEmpty {
                    searchHistorySection
                }

                // 热门搜索
                // Android类比: trending searches section
                trendingSearchesSection
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - 搜索历史区域
    @ViewBuilder
    private var searchHistorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 标题行
            // Android类比: TextView with title
            HStack {
                Text("搜索历史")
                    .font(Typography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                // 清除历史按钮
                // Android类比: Button with clear icon
                Button(action: {
                    viewModel.clearHistory()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // 历史标签列表
            // Android类比: FlexboxLayout或ChipGroup
            FlowLayout(spacing: Spacing.xs) {
                ForEach(viewModel.searchHistory, id: \.self) { query in
                    searchHistoryTag(query)
                }
            }
        }
    }

    // MARK: - 搜索历史标签
    @ViewBuilder
    private func searchHistoryTag(_ query: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)

            Text(query)
                .font(Typography.callout)
                .foregroundColor(AppColors.textPrimary)

            // 删除按钮
            Button(action: {
                viewModel.removeFromHistory(query)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(AppColors.gray100)
        .cornerRadius(Spacing.cornerRadiusSM)
        .onTapGesture {
            viewModel.selectFromHistory(query)
            hideKeyboard()
        }
    }

    // MARK: - 热门搜索区域
    @ViewBuilder
    private var trendingSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 标题
            // Android类比: TextView with trending icon
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.warning)

                Text("热门搜索")
                    .font(Typography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            // 热门搜索标签
            // Android类比: ChipGroup or FlexboxLayout
            FlowLayout(spacing: Spacing.xs) {
                ForEach(viewModel.trendingSearches, id: \.self) { tag in
                    trendingTag(tag)
                }
            }
        }
    }

    // MARK: - 热门搜索标签
    @ViewBuilder
    private func trendingTag(_ tag: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Text(tag)
                .font(Typography.callout)
                .foregroundColor(AppColors.primary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(AppColors.primary.opacity(0.1))
        .cornerRadius(Spacing.cornerRadiusSM)
        .onTapGesture {
            viewModel.quickSearch(tag: tag)
            hideKeyboard()
        }
    }

    // MARK: - 搜索中视图
    // Android类比: ProgressBar布局
    @ViewBuilder
    private var searchingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)

            Text("正在搜索 \"\(viewModel.searchQuery)\"...")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 空结果视图
    // Android类比: EmptyView布局
    @ViewBuilder
    private var emptyResultsView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(AppColors.gray400)

            Text("未找到 \"\(viewModel.searchQuery)\"")
                .font(Typography.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("尝试其他关键词或查看热门搜索")
                .font(Typography.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }

    // MARK: - 搜索结果视图
    // Android类比: RecyclerView with results
    @ViewBuilder
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            // 结果数量提示
            // Android类比: TextView with result count
            if viewModel.hasResults {
                HStack {
                    Text("找到 \(viewModel.searchResults.count) 条结果")
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(AppColors.gray100)
            }

            // 结果列表
            // Android类比: RecyclerView
            List {
                ForEach(viewModel.searchResults) { post in
                    searchResultCell(post)
                        .listRowInsets(EdgeInsets(top: Spacing.xxxs, leading: Spacing.sm, bottom: Spacing.xxxs, trailing: Spacing.sm))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .onTapGesture {
                            selectedPost = post
                        }
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - 搜索结果单元格
    @ViewBuilder
    private func searchResultCell(_ post: Post) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // 图标
            // Android类比: ImageView
            Image(systemName: "doc.text.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)
                .frame(width: 32, height: 32)

            // 内容
            // Android类比: TextView with post info
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                // 标题（高亮搜索词）
                // Android类比: SpannableString with highlight
                highlightedText(post.title, highlight: viewModel.searchQuery)
                    .font(Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                // 内容预览
                // Android类比: TextView with body preview
                Text(post.truncatedBody)
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.cornerRadiusSM)
    }

    // MARK: - 高亮文本
    /// 高亮显示搜索关键词
    // Android类比: SpannableString with ForegroundColorSpan
    @ViewBuilder
    private func highlightedText(_ text: String, highlight: String) -> some View {
        if highlight.isEmpty {
            Text(text)
        } else {
            // 简化版高亮实现
            // 实际应用中应该使用更复杂的文本处理
            let range = (text.lowercased() as NSString).range(of: highlight.lowercased())
            if range.location != NSNotFound {
                // 有匹配项 - 这里简化显示原文本
                // 实际应该使用AttributedString进行高亮
                Text(text)
            } else {
                Text(text)
            }
        }
    }

    // MARK: - 辅助方法
    /// 隐藏键盘
    // Android类比: InputMethodManager.hideSoftInputFromWindow()
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - FlowLayout（用于标签布局）
// Android类比: FlexboxLayout或ChipGroup
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - 预览
#Preview("Search View - Initial") {
    SearchView()
        .environment(SearchViewModel())
}

#Preview("Search View - Results") {
    SearchView()
        .environment({
            let vm = SearchViewModel()
            vm.searchQuery = "SwiftUI"
            vm.searchResults = Post.mocks
            return vm
        }())
}

#Preview("Search View - Empty") {
    SearchView()
        .environment({
            let vm = SearchViewModel()
            vm.searchQuery = "xyz"
            vm.searchResults = []
            return vm
        }())
}

#Preview("Search View Dark Mode") {
    SearchView()
        .environment(SearchViewModel())
        .preferredColorScheme(.dark)
}
