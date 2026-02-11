//
//  DetailView.swift
//  iosDemo
//
//  帖子详情页视图 - 显示帖子详情和评论
//  Android类比: 类似DetailFragment或详情Activity
//

import SwiftUI

// MARK: - 详情页视图
// Android类比: class DetailFragment : Fragment()
struct DetailView: View {

    // MARK: - 属性
    /// 帖子数据
    // Android类比: private val args: DetailFragmentArgs by navArgs()
    let post: Post

    /// 是否正在加载分享
    // Android类比: var isSharing: Boolean = false
    @State private var isSharing: Bool = false

    /// 显示分享弹窗
    @State private var showShareSheet: Bool = false

    /// 显示更多选项
    @State private var showMoreOptions: Bool = false

    /// 显示举报弹窗
    @State private var showReportDialog: Bool = false

    // MARK: - 依赖注入
    @State private var viewModel: DetailViewModel

    // MARK: - 初始化
    // Android类比: 实际上Fragment会通过SavedStateHandle获取参数
    init(post: Post) {
        self.post = post
        self._viewModel = State(initialValue: DetailViewModel(post: post))
    }

    // MARK: - 视图
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 帖子内容
                // Android类比: include post_content_layout.xml
                postContentSection

                // 分割线
                // Android类比: <View android:background="@color/divider" />
                Divider()
                    .padding(.vertical, Spacing.md)

                // 作者信息卡片
                // Android类比: include author_card_layout.xml
                if let author = viewModel.author {
                    authorCard(author)
                        .padding(.horizontal, Spacing.md)
                }

                // 评论区标题
                // Android类比: TextView with comments title
                commentsHeader

                // 评论列表
                // Android类比: RecyclerView with comments
                if viewModel.hasComments {
                    commentsList
                } else if !viewModel.isLoadingComments {
                    emptyCommentsView
                }
            }
        }
        .navigationTitle("帖子详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 导航栏按钮
            // Android类比: onCreateOptionsMenu
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    // 分享按钮
                    // Android类比: MenuItem with share icon
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }

                    // 更多选项按钮
                    // Android类比: MenuItem with more icon
                    Menu {
                        Button(action: {
                            showReportDialog = true
                        }) {
                            Label("举报", systemImage: "exclamationmark.triangle")
                        }

                        if let link = viewModel.copyLink() as String? {
                            Button(action: {
                                UIPasteboard.general.string = link
                            }) {
                                Label("复制链接", systemImage: "doc.on.doc")
                            }
                        }

                        Button(role: .destructive, action: {}) {
                            Label("不感兴趣", systemImage: "hand.thumbsdown")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        // 分享弹窗
        // Android类比: ShareCompat.IntentBuilder
        .sheet(isPresented: $showShareSheet) {
            if let shareText = viewModel.sharePost() {
                ShareSheet(activityItems: [shareText])
            }
        }
        // 举报弹窗
        // Android类比: AlertDialog
        .alert("举报内容", isPresented: $showReportDialog) {
            Button("取消", role: .cancel) {}
            Button("举报", role: .destructive) {
                Task {
                    _ = await viewModel.reportPost(reason: "垃圾内容")
                }
            }
        } message: {
            Text("确定要举报此内容吗？")
        }
        // 视图出现时加载数据
        // Android类比: onViewCreated 或 onViewStateRestored
        .task {
            if viewModel.author == nil && viewModel.comments.isEmpty {
                await viewModel.loadPostDetail()
            }
        }
        // 错误提示
        // Android类比: Snackbar或Toast
        .alertError(error: $viewModel.errorMessage)
    }

    // MARK: - 帖子内容区域
    // Android类比: post_content_layout.xml
    @ViewBuilder
    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // 标题
            // Android类比: TextView with post title
            Text(post.title)
                .font(Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            // 元信息
            // Android类比: TextView with metadata
            HStack(spacing: Spacing.sm) {
                // 日期标签
                // Android类比: TextView with date
                Label("2小时前", systemImage: "clock")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                // 阅读次数
                Label("1.2k 阅读", systemImage: "eye")
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                // 分类标签
                Text("技术")
                    .font(Typography.caption)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, Spacing.xxxs)
                    .background(AppColors.primary.opacity(0.1))
                    .foregroundColor(AppColors.primary)
                    .cornerRadius(Spacing.cornerRadiusSM)
            }

            // 正文内容
            // Android类比: TextView with post body
            Text(post.body)
                .font(Typography.body)
                .foregroundColor(AppColors.textPrimary)
                .lineSpacing(4)

            // 互动栏
            // Android类比: include interaction_bar.xml
            interactionBar
        }
        .padding(Spacing.md)
    }

    // MARK: - 互动栏
    // Android类比: interaction_bar.xml（点赞、收藏、评论按钮）
    @ViewBuilder
    private var interactionBar: some View {
        HStack(spacing: Spacing.lg) {
            // 点赞按钮
            // Android类比: ImageButton with like icon
            Button(action: {}) {
                HStack(spacing: Spacing.xxxs) {
                    Image(systemName: "heart")
                        .foregroundColor(AppColors.textSecondary)
                    Text("128")
                        .font(Typography.callout)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // 评论按钮
            // Android类比: ImageButton with comment icon
            HStack(spacing: Spacing.xxxs) {
                Image(systemName: "bubble.right")
                    .foregroundColor(AppColors.textSecondary)
                Text("\(viewModel.commentCount)")
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            // 收藏按钮
            // Android类比: FAB or ImageButton with bookmark icon
            Button(action: {
                _ = viewModel.toggleFavorite()
                // 触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }) {
                HStack(spacing: Spacing.xxxs) {
                    Image(systemName: viewModel.isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundColor(viewModel.isFavorite ? AppColors.primary : AppColors.textSecondary)
                    Text(viewModel.isFavorite ? "已收藏" : "收藏")
                        .font(Typography.callout)
                        .foregroundColor(viewModel.isFavorite ? AppColors.primary : AppColors.textSecondary)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - 作者卡片
    // Android类比: author_card_layout.xml
    @ViewBuilder
    private func authorCard(_ author: User) -> some View {
        Button(action: {
            // 跳转到作者详情页
            // Android类比: findNavController().navigate(DetailFragmentDirections.toAuthorProfile(authorId))
        }) {
            HStack(spacing: Spacing.sm) {
                // 头像
                // Android类比: CircleImageView
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Text(author.initials)
                        .font(Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }

                // 作者信息
                // Android类比: TextView with author name and bio
                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(author.displayName)
                        .font(Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(author.company.name)
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // 关注按钮
                // Android类比: Button with "Follow" text
                Text("关注")
                    .font(Typography.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(AppColors.primary)
                    .cornerRadius(Spacing.cornerRadiusSM)
            }
            .padding(Spacing.sm)
            .background(AppColors.gray100)
            .cornerRadius(Spacing.cornerRadiusMD)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 评论区标题
    @ViewBuilder
    private var commentsHeader: some View {
        HStack {
            Text("评论 (\(viewModel.commentCount))")
                .font(Typography.headline)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            if viewModel.isLoadingComments {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - 评论列表
    // Android类比: RecyclerView with comments adapter
    @ViewBuilder
    private var commentsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.comments) { comment in
                commentCell(comment)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)

                if comment.id != viewModel.comments.last?.id {
                    Divider()
                        .padding(.leading, 60) // 对齐内容
                }
            }
        }
    }

    // MARK: - 评论单元格
    // Android类比: comment_item_layout.xml
    @ViewBuilder
    private func commentCell(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            // 头像
            // Android类比: CircleImageView
            ZStack {
                Circle()
                    .fill(AppColors.gray200)
                    .frame(width: 40, height: 40)

                Text(String(comment.name.prefix(1)))
                    .font(Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.gray600)
            }

            // 评论内容
            // Android类比: TextView with comment body
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                // 用户名和邮箱
                HStack(spacing: Spacing.xxxs) {
                    Text(comment.name)
                        .font(Typography.callout)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    Text("·")
                        .foregroundColor(AppColors.textTertiary)

                    Text(comment.email)
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textTertiary)
                }

                // 评论内容
                Text(comment.body)
                    .font(Typography.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - 空评论视图
    // Android类比: empty_comments_layout.xml
    @ViewBuilder
    private var emptyCommentsView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "bubble.right")
                .font(.system(size: 48))
                .foregroundColor(AppColors.gray400)

            Text("暂无评论")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)

            Text("快来发表第一条评论吧")
                .font(Typography.caption)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
    }
}

// MARK: - 分享弹窗
// Android类比: ShareCompat.IntentBuilder
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}

// MARK: - 预览
#Preview("Detail View") {
    NavigationStack {
        DetailView(post: Post.mock)
            .environment({
                let vm = DetailViewModel(post: Post.mock)
                vm.author = User.mock
                vm.comments = Comment.mocks
                return vm
            }())
    }
}

#Preview("Detail View - Loading") {
    NavigationStack {
        DetailView(post: Post.mock)
            .environment(DetailViewModel(post: Post.mock))
    }
}

#Preview("Detail View Dark Mode") {
    NavigationStack {
        DetailView(post: Post.mock)
            .environment({
                let vm = DetailViewModel(post: Post.mock)
                vm.author = User.mock
                vm.comments = Comment.mocks
                return vm
            }())
    }
    .preferredColorScheme(.dark)
}
