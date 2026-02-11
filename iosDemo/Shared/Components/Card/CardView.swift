//
//  CardView.swift
//  iosDemo
//
//  卡片组件 - 可配置的通用卡片视图
//  Android类比: 类似MaterialCardView或Card组件
//

import SwiftUI

// MARK: - 卡片样式
// Android类比: 类似MaterialCardView的样式属性
enum CardStyle {
    /// 默认样式（带阴影和圆角）
    case elevated

    /// 填充样式（带背景色，无阴影）
    case filled

    /// 边框样式（带边框，无阴影）
    case outlined

    /// 平面样式（无阴影无边框）
    case flat
}

// MARK: - 通用卡片组件
// Android类比: 类似Card(modifier = Modifier...)
struct CardView<Content: View>: View {

    // MARK: - 属性
    /// 卡片内容
    // Android类比: content: @Composable () -> Unit
    let content: () -> Content

    /// 卡片样式
    // Android类比: val style: CardStyle
    var style: CardStyle = .elevated

    /// 背景色
    // Android类比: val backgroundColor: Color
    var backgroundColor: Color = AppColors.surface

    /// 圆角半径
    // Android类比: val cornerRadius: Dp
    var cornerRadius: CGFloat = Spacing.cornerRadiusMD

    /// 内边距
    // Android类比: val contentPadding: PaddingValues
    var padding: CGFloat = Spacing.cardPadding

    /// 点击回调（可选，如果有则卡片可点击）
    // Android类比: val onClick: (() -> Unit)?
    var onTap: (() -> Void)?

    /// 是否显示边框
    // Android类比: val showBorder: Boolean
    var showBorder: Bool = false

    /// 边框颜色
    // Android类比: val borderColor: Color
    var borderColor: Color = AppColors.divider

    // MARK: - 状态
    @State private var isPressed = false

    // MARK: - 初始化
    init(
        style: CardStyle = .elevated,
        backgroundColor: Color = AppColors.surface,
        cornerRadius: CGFloat = Spacing.cornerRadiusMD,
        padding: CGFloat = Spacing.cardPadding,
        onTap: (() -> Void)? = nil,
        showBorder: Bool = false,
        borderColor: Color = AppColors.divider,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.onTap = onTap
        self.showBorder = showBorder
        self.borderColor = borderColor
        self.content = content
    }

    // MARK: - 视图
    var body: some View {
        Group {
            if let onTap = onTap {
                // 可点击版本
                Button(action: {
                    // 触觉反馈
                    // Android类比: view.performHapticFeedback()
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onTap()
                }) {
                    cardContent
                }
                .buttonStyle(InteractiveCardStyle(isPressed: $isPressed))
            } else {
                // 静态版本
                cardContent
            }
        }
    }

    // MARK: - 卡片内容
    private var cardContent: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(showBorder ? borderColor : Color.clear, lineWidth: 1)
            )
            .modifier(CardStyleModifier(style: style, cornerRadius: cornerRadius))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - 卡片样式Modifier
// Android类比: 类似Compose的Modifier.shadow()
private struct CardStyleModifier: ViewModifier {
    let style: CardStyle
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        switch style {
        case .elevated:
            content.shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
        case .filled:
            content
        case .outlined:
            content
        case .flat:
            content
        }
    }
}

// MARK: - 卡片按钮样式
// Android类比: 类似Compose的可点击卡片样式
private struct InteractiveCardStyle: SwiftUI.ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onAppear {
                withAnimation {
                    isPressed = configuration.isPressed
                }
            }
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation {
                    isPressed = newValue
                }
            }
    }
}

// MARK: - 预设卡片组件

/// 带标题的卡片
// Android类比: 类似带有标题的Card布局
struct TitledCard: View {
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    let content: any View

    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        CardView(style: .elevated) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // 标题栏
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxxs) {
                        Text(title)
                            .font(Typography.headline)
                            .foregroundColor(AppColors.textPrimary)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(Typography.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    if let actionTitle = actionTitle, let action = action {
                        Button(action: action) {
                            Text(actionTitle)
                                .font(Typography.callout)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }

                // 内容
                Divider()
                    .padding(.vertical, Spacing.xxs)

                AnyView(content)
            }
        }
    }
}

/// 信息卡片（带图标）
// Android类比: 类似带有图标的信息展示卡片
struct InfoCard: View {
    let icon: Image?
    let title: String
    let description: String
    var color: Color = AppColors.info

    init(
        title: String,
        description: String,
        icon: Image? = nil,
        color: Color = AppColors.info
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
    }

    var body: some View {
        CardView(style: .elevated, backgroundColor: color.opacity(0.1)) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    icon
                        .font(.system(size: 20))
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(color.opacity(0.2))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(title)
                        .font(Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(description)
                        .font(Typography.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - 预览
#Preview("Card Styles") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            // Elevated Card
            CardView(style: .elevated) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Elevated Card")
                        .font(Typography.headline)
                    Text("带有阴影的默认卡片样式")
                        .font(Typography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Filled Card
            CardView(style: .filled, backgroundColor: AppColors.gray100) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Filled Card")
                        .font(Typography.headline)
                    Text("填充背景的卡片样式")
                        .font(Typography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Outlined Card
            CardView(style: .outlined, showBorder: true, borderColor: AppColors.primary) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Outlined Card")
                        .font(Typography.headline)
                    Text("带边框的卡片样式")
                        .font(Typography.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Clickable Card
            CardView(style: .elevated, onTap: {
                print("Card tapped!")
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xxxs) {
                        Text("可点击卡片")
                            .font(Typography.headline)
                        Text("点击我查看详情")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Info Cards
            InfoCard(
                title: "提示",
                description: "这是一条提示信息",
                icon: Image(systemName: "info.circle.fill"),
                color: AppColors.info
            )

            InfoCard(
                title: "成功",
                description: "操作已完成",
                icon: Image(systemName: "checkmark.circle.fill"),
                color: AppColors.success
            )

            InfoCard(
                title: "警告",
                description: "请注意检查",
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                color: AppColors.warning
            )

            // Titled Card
            TitledCard(
                title: "数据统计",
                subtitle: "最近7天",
                actionTitle: "查看更多",
                action: { print("Action tapped") }
            ) {
                HStack(spacing: Spacing.md) {
                    VStack(spacing: Spacing.xxxs) {
                        Text("1,234")
                            .font(Typography.title3)
                            .fontWeight(.bold)
                        Text("浏览量")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    VStack(spacing: Spacing.xxxs) {
                        Text("567")
                            .font(Typography.title3)
                            .fontWeight(.bold)
                        Text("点赞数")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    VStack(spacing: Spacing.xxxs) {
                        Text("89")
                            .font(Typography.title3)
                            .fontWeight(.bold)
                        Text("评论数")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
