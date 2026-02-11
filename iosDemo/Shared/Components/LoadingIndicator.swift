//
//  LoadingIndicator.swift
//  iosDemo
//
//  加载指示器组件 - 各种加载状态展示
//  Android类比: 类似ProgressBar或CircularProgressIndicator
//

import SwiftUI

// MARK: - 加载指示器类型
// Android类比: 类似ProgressBar的不同样式
enum LoadingIndicatorStyle {
    /// 圆形进度条
    case circular

    /// 线性进度条
    case linear

    /// 点状加载
    case dots

    /// 自定义文本加载
    case text
}

// MARK: - 加载指示器组件
// Android类比: 类似ProgressBar或CircularProgressIndicator
struct LoadingIndicator: View {

    // MARK: - 属性
    /// 加载提示文本
    // Android类比: android:hint或提示文本
    var message: String?

    /// 指示器样式
    // Android类比: style="?android:attr/progressBarStyle"
    var style: LoadingIndicatorStyle = .circular

    /// 是否显示背景遮罩
    // Android类比: 是否显示半透明背景
    var showBackground: Bool = false

    /// 指示器颜色
    // Android类比: android:indeterminateTint
    var tint: Color = AppColors.primary

    /// 指示器大小
    // Android类比: android:layout_width/height
    var size: CGFloat = 48

    // MARK: - 视图
    var body: some View {
        Group {
            if showBackground {
                // 全屏加载遮罩
                // Android类比: 类似ProgressBar覆盖层
                ZStack {
                    // 半透明背景
                    // Android类比: android:background="#80000000"
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    loadingContent
                        .padding(Spacing.lg)
                        .background(Color(.systemBackground))
                        .cornerRadius(Spacing.cornerRadiusMD)
                        .shadow(radius: Spacing.shadowMD)
                }
            } else {
                // 内联加载指示器
                loadingContent
            }
        }
    }

    // MARK: - 加载内容
    @ViewBuilder
    private var loadingContent: some View {
        HStack(spacing: Spacing.sm) {
            switch style {
            case .circular:
                // 圆形进度条
                // Android类比: ProgressBar(indeterminate = true)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: tint))
                    .scaleEffect(size / 50) // 默认大小约50pt

            case .linear:
                // 线性进度条
                // Android类比: <ProgressBar style="?android:attr/progressBarStyleHorizontal" />
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: tint))
                    .frame(width: 150)

            case .dots:
                // 点状加载动画
                // Android类比: 自定义点状动画
                DotsLoadingIndicator(tint: tint, size: size)

            case .text:
                // 文本加载动画
                TextLoadingIndicator()
            }

            // 提示文本
            if let message = message {
                Text(message)
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(Spacing.sm)
    }
}

// MARK: - 点状加载指示器
// Android类比: 类似自定义的三个点动画
struct DotsLoadingIndicator: View {
    let tint: Color
    let size: CGFloat

    @State private var isAnimating = false

    private let animationDuration: Double = 0.6
    private let maxScale: CGFloat = 1.3

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(tint)
                    .frame(width: size / 3, height: size / 3)
                    .scaleEffect(dotScale(for: index))
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * animationDuration / 3),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    private func dotScale(for index: Int) -> CGFloat {
        isAnimating ? maxScale : 1.0
    }
}

// MARK: - 文本加载指示器
// Android类比: 类似"加载中..."文字动画
struct TextLoadingIndicator: View {
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 2) {
            Text("加载中")
                .font(Typography.callout)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<dotCount, id: \.self) { _ in
                Text(".")
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

// MARK: - 骨架屏加载器
// Android类比: 类似Shimmer效果或Skeleton Layout
struct SkeletonLoader: View {
    @State private var isAnimating = false

    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = Spacing.cornerRadiusSM

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.gray200)
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.5),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? width : -width)
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
            .clipped()
    }
}

// MARK: - 状态视图（空状态/错误状态）
// Android类比: 类似EmptyStateLayout或ErrorStateLayout
struct StateView: View {
    enum StateType {
        case empty
        case error
        case noNetwork
        case noResults
    }

    let type: StateType
    let title: String?
    let message: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        type: StateType,
        title: String? = nil,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.title = title ?? type.defaultTitle
        self.message = message ?? type.defaultMessage
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // 图标
            type.icon
                .font(.system(size: 64))
                .foregroundColor(type.color)

            VStack(spacing: Spacing.xs) {
                // 标题
                Text(title ?? "")
                    .font(Typography.headline)
                    .foregroundColor(AppColors.textPrimary)

                // 描述
                Text(message ?? "")
                    .font(Typography.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // 操作按钮
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - StateType扩展
extension StateView.StateType {
    var icon: Image {
        switch self {
        case .empty:
            return Image(systemName: "tray")
        case .error:
            return Image(systemName: "exclamationmark.triangle")
        case .noNetwork:
            return Image(systemName: "wifi.slash")
        case .noResults:
            return Image(systemName: "magnifyingglass")
        }
    }

    var color: Color {
        switch self {
        case .empty:
            return AppColors.gray500
        case .error:
            return AppColors.error
        case .noNetwork:
            return AppColors.warning
        case .noResults:
            return AppColors.info
        }
    }

    var defaultTitle: String {
        switch self {
        case .empty:
            return "暂无内容"
        case .error:
            return "出错了"
        case .noNetwork:
            return "网络连接失败"
        case .noResults:
            return "未找到结果"
        }
    }

    var defaultMessage: String {
        switch self {
        case .empty:
            return "这里还没有任何内容"
        case .error:
            return "抱歉，发生了错误，请稍后重试"
        case .noNetwork:
            return "请检查网络连接后重试"
        case .noResults:
            return "尝试使用其他关键词搜索"
        }
    }
}

// MARK: - 预览
#Preview("Loading Indicators") {
    VStack(spacing: Spacing.xl) {
        LoadingIndicator(style: .circular)
        LoadingIndicator(style: .linear)
        LoadingIndicator(style: .dots)
        LoadingIndicator(style: .text)
        LoadingIndicator(message: "加载中...", style: .circular)
    }
    .padding()
}

#Preview("Full Screen Loading") {
    LoadingIndicator(
        message: "正在加载数据...",
        style: .circular,
        showBackground: true
    )
}

#Preview("Skeleton Loader") {
    VStack(alignment: .leading, spacing: Spacing.sm) {
        HStack(spacing: Spacing.sm) {
            SkeletonLoader(width: 50, height: 50, cornerRadius: 25)
            VStack(alignment: .leading, spacing: Spacing.xxxs) {
                SkeletonLoader(width: 120, height: 16)
                SkeletonLoader(width: 80, height: 14)
            }
        }
        SkeletonLoader(width: .infinity, height: 100)
        SkeletonLoader(width: .infinity, height: 16)
        SkeletonLoader(width: 200, height: 16)
    }
    .padding()
}

#Preview("State Views") {
    VStack(spacing: Spacing.xl) {
        StateView(type: .empty, actionTitle: "添加内容", action: {})
        StateView(type: .error, actionTitle: "重试", action: {})
        StateView(type: .noNetwork, actionTitle: "刷新", action: {})
        StateView(type: .noResults)
    }
}
