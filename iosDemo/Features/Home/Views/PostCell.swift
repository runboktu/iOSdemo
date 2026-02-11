//
//  PostCell.swift
//  iosDemo
//
//  帖子列表单元格 - 单个帖子的展示视图
//  Android类比: 类似RecyclerView的ViewHolder或Compose的ListItem
//

import SwiftUI

// MARK: - 帖子单元格
// Android类比: class PostViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)
struct PostCell: View {

    // MARK: - 属性
    /// 帖子数据
    // Android类比: val post: Post (在ViewHolder中绑定)
    let post: Post

    /// 作者信息（可选）
    // Android类比: val author: User?
    var author: User?

    /// 是否收藏
    // Android类比: var isFavorite: Boolean
    var isFavorite: Bool = false

    /// 收藏回调
    // Android类比: val onFavoriteClick: (Int) -> Unit
    var onFavoriteToggle: ((Int) -> Void)?

    /// 点击回调
    // Android类比: val onClick: (Post) -> Unit
    var onTap: ((Post) -> Void)?

    // MARK: - 状态
    @State private var isPressed = false

    // MARK: - 视图
    var body: some View {
        // 可点击的卡片
        // Android类比: itemView.setOnClickListener { ... }
        Button(action: {
            // 触觉反馈
            // Android类比: view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            onTap?(post)
        }) {
            cellContent
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }

    // MARK: - 单元格内容
    private var cellContent: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 顶部：作者信息
            headerSection

            // 中部：标题
            titleSection

            // 底部：内容和元信息
            contentSection

            // 可选：评论数量等
            footerSection
        }
        .padding(Spacing.cardPadding)
        .background(Color(.systemBackground))
        .cornerRadius(Spacing.cornerRadiusMD)
        .shadow(color: Color.black.opacity(isPressed ? 0.15 : 0.05), radius: isPressed ? 4 : 2, x: 0, y: 1)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }

    // MARK: - 头部区域（作者信息）
    // Android类比: holder.authorTextView.text = post.authorName
    private var headerSection: some View {
        HStack(spacing: Spacing.xs) {
            // 头像
            // Android类比: CircleImageView 或类似组件
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 32, height: 32)

                Text(author?.initials ?? "U")
                    .font(Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
            }

            // 作者名
            Text(author?.displayName ?? "用户\(post.userId)")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)

            Spacer()

            // 收藏按钮
            // Android类比: ImageButton 或 IconButton
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onFavoriteToggle?(post.id)
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: Spacing.iconSize))
                    .foregroundColor(isFavorite ? AppColors.error : AppColors.gray400)
            }
        }
    }

    // MARK: - 标题区域
    // Android类比: holder.titleTextView.text = post.title
    private var titleSection: some View {
        Text(post.title)
            .font(Typography.headline)
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    // MARK: - 内容区域
    // Android类比: holder.bodyTextView.text = post.body
    private var contentSection: some View {
        Text(post.body)
            .font(Typography.body)
            .foregroundColor(AppColors.textSecondary)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }

    // MARK: - 底部区域（元信息）
    // Android类比: holder.metadataTextView.text = ...
    private var footerSection: some View {
        HStack(spacing: Spacing.sm) {
            // 日期标签（模拟）
            // Android类比: TextView with icon
            Label("2小时前", systemImage: "clock")
                .font(Typography.caption)
                .foregroundColor(AppColors.textTertiary)

            // 评论数
            // Android类比: TextView with icon
            Label("5", systemImage: "bubble.right")
                .font(Typography.caption)
                .foregroundColor(AppColors.textTertiary)

            Spacer()

            // 分类标签
            // Android类比: Chip 或 Badge
            Text("技术")
                .font(Typography.caption)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.xxxs)
                .background(AppColors.primary.opacity(0.1))
                .foregroundColor(AppColors.primary)
                .cornerRadius(Spacing.cornerRadiusSM)
        }
    }
}

// MARK: - 紧凑型帖子单元格
// Android类比: 类似RecyclerView的紧凑布局
struct CompactPostCell: View {
    let post: Post
    var onTap: ((Post) -> Void)?

    var body: some View {
        HStack(spacing: Spacing.sm) {
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                Text(post.title)
                    .font(Typography.callout)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(post.truncatedBody)
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.gray400)
        }
        .padding(Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?(post)
        }
    }
}

// MARK: - 卡片式帖子单元格
// Android类比: 类似Material Design的Card布局
struct CardPostCell: View {
    let post: Post
    var author: User?
    var isFavorite: Bool = false
    var onFavoriteToggle: ((Int) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // 图片占位（可选）
            // Android类比: ImageView
            RoundedRectangle(cornerRadius: Spacing.cornerRadiusSM)
                .fill(AppColors.gray200)
                .frame(height: 150)
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.gray400)
                }

            // 内容
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(post.title)
                    .font(Typography.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)

                Text(post.truncatedBody)
                    .font(Typography.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            // 底部信息
            HStack {
                HStack(spacing: Spacing.xxxs) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.error)

                    Text("128")
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                HStack(spacing: Spacing.xxxs) {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.info)

                    Text("24")
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - 预览
#Preview("Post Cell") {
    ScrollView {
        VStack(spacing: Spacing.sm) {
            // 标准单元格
            PostCell(
                post: Post.mock,
                author: User.mock,
                isFavorite: true,
                onFavoriteToggle: { id in
                    print("Favorite toggled for post \(id)")
                },
                onTap: { post in
                    print("Tapped post \(post.id)")
                }
            )

            // 未收藏状态
            PostCell(
                post: Post.mocks[1],
                author: User.mocks[1],
                isFavorite: false,
                onFavoriteToggle: { id in
                    print("Favorite toggled for post \(id)")
                }
            )

            Divider()

            // 紧凑型
            CompactPostCell(post: Post.mock) { post in
                print("Tapped compact cell")
            }

            CompactPostCell(post: Post.mocks[1])

            Divider()

            // 卡片式
            CardPostCell(
                post: Post.mock,
                author: User.mock,
                isFavorite: true
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Post Cell Dark") {
    ScrollView {
        VStack(spacing: Spacing.sm) {
            PostCell(
                post: Post.mock,
                author: User.mock,
                isFavorite: true
            )

            PostCell(
                post: Post.mocks[1],
                author: User.mocks[1],
                isFavorite: false
            )
        }
        .padding()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}
