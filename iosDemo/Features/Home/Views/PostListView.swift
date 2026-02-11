//
//  PostListView.swift
//  iosDemo
//
//  帖子列表视图 - 显示帖子列表
//  Android类比: 类似RecyclerView + Adapter或Compose的LazyColumn
//

import SwiftUI

// MARK: - 帖子列表样式枚举
// Android类比: 类似RecyclerView的LayoutManager
enum PostListStyle {
    case list        // 列表样式
    case card        // 卡片样式
    case compact     // 紧凑样式
}

// MARK: - 帖子列表视图
// Android类比: class PostAdapter : RecyclerView.Adapter<PostViewHolder()>
struct PostListView: View {

    // MARK: - 环境变量
    /// 从环境获取ViewModel
    // Android类比: private val viewModel: HomeViewModel by viewModels()
    @Environment(HomeViewModel.self) private var viewModel

    // MARK: - 属性
    /// 列表样式
    // Android类比: val listStyle: PostListStyle
    var listStyle: PostListStyle = .list

    /// 点击帖子回调
    // Android类比: val onPostClick: (Post) -> Unit
    var onPostTap: ((Post) -> Void)?

    /// 刷新回调
    // Android类比: val onRefresh: () -> Unit
    var onRefresh: (() async -> Void)?

    // MARK: - 视图
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                // 首次加载状态
                // Android类比: ProgressBar.isVisible = true
                loadingView
            } else if viewModel.showEmptyState {
                // 空状态
                // Android类比: EmptyView.isVisible = true
                emptyView
            } else {
                // 列表内容
                // Android类比: RecyclerView.isVisible = true
                contentView
            }
        }
    }

    // MARK: - 加载视图
    // Android类比: ProgressBar布局
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text("正在加载帖子...")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 空状态视图
    // Android类比: EmptyView布局
    @ViewBuilder
    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(AppColors.gray400)
            Text(viewModel.searchQuery.isEmpty ? "暂无帖子" : "未找到相关帖子")
                .font(Typography.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(viewModel.searchQuery.isEmpty ? "下拉刷新获取内容" : "尝试其他关键词")
                .font(Typography.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 内容视图
    // Android类比: RecyclerView with adapter
    @ViewBuilder
    private var contentView: some View {
        List {
            // 帖子列表
            // Android类比: adapter.submitList(viewModel.posts)
            ForEach(viewModel.filteredPosts) { post in
                // 根据列表样式显示不同单元格
                // Android类比: ViewHolder类型判断
                switch listStyle {
                case .list:
                    listCell(for: post)
                case .card:
                    cardCell(for: post)
                case .compact:
                    compactCell(for: post)
                }
            }

            // 加载更多指示器
            // Android类比: LoadState视图
            if viewModel.hasMore && !viewModel.filteredPosts.isEmpty {
                loadMoreIndicator
            }
        }
        .listStyle(.plain)
        .refreshable {
            // 下拉刷新
            // Android类比: SwipeRefreshLayout.setOnRefreshListener { ... }
            if let onRefresh = onRefresh {
                await onRefresh()
            } else {
                // Default to viewModel.refresh() if no custom callback
                await viewModel.refresh()
            }
        }
    }

    // MARK: - 列表样式单元格
    // Android类比: class ListPostViewHolder : RecyclerView.ViewHolder
    @ViewBuilder
    private func listCell(for post: Post) -> some View {
        PostCell(
            post: post,
            author: nil,
            isFavorite: viewModel.isFavorite(postId: post.id),
            onFavoriteToggle: { _ in },
            onTap: { post in
                onPostTap?(post)
            }
        )
        .listRowInsets(EdgeInsets(top: Spacing.xxxs, leading: Spacing.sm, bottom: Spacing.xxxs, trailing: Spacing.sm))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - 卡片样式单元格
    @ViewBuilder
    private func cardCell(for post: Post) -> some View {
        CardPostCell(
            post: post,
            author: nil,
            isFavorite: viewModel.isFavorite(postId: post.id),
            onFavoriteToggle: { _ in }
        )
        .listRowInsets(EdgeInsets(top: Spacing.xxxs, leading: Spacing.sm, bottom: Spacing.xxxs, trailing: Spacing.sm))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - 紧凑样式单元格
    @ViewBuilder
    private func compactCell(for post: Post) -> some View {
        CompactPostCell(post: post) { tappedPost in
            onPostTap?(tappedPost)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - 加载更多指示器
    // Android类比: LoadState.Loading视图
    @ViewBuilder
    private var loadMoreIndicator: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
            Text("加载更多...")
                .font(Typography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(Spacing.sm)
        .onAppear {
            // 滚动到底部时自动加载更多
            // Android类比: RecyclerView.addOnScrollListener
            Task {
                await viewModel.loadMore()
            }
        }
    }
}

// MARK: - 预览
#Preview("Post List View") {
    NavigationStack {
        PostListView(
            listStyle: .list,
            onPostTap: { post in
                print("Tapped post \(post.id)")
            },
            onRefresh: {
                // Preview refresh action
            }
        )
        .navigationTitle("首页")
    }
    .environment(HomeViewModel())
}
