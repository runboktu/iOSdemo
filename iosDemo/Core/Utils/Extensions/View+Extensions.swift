//
//  View+Extensions.swift
//  iosDemo
//
//  View扩展 - 为SwiftUI视图添加便捷方法和Modifier
//  Android类比: 类似Jetpack Compose的Modifier扩展函数
//

import SwiftUI

// MARK: - View扩展
// Android类比: 类似Compose的Modifier扩展
extension View {

    // MARK: - 便捷条件应用
    /// 条件性应用Modifier
    // Android类比: fun Modifier.thenIf(condition: Boolean, modifier: Modifier): Modifier
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 条件性应用Modifier（带else分支）
    // Android类比: fun Modifier.when(condition: Boolean, ifTrue: Modifier, ifFalse: Modifier): Modifier
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }

    // MARK: - 卡片样式
    /// 应用卡片样式
    // Android类比: 类似Compose的Card组件样式
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 2)
    }

    /// 应用内嵌卡片样式（无边框阴影）
    // Android类比: 类似Compose的Surface组件
    func insetCardStyle(
        padding: CGFloat = 16,
        backgroundColor: Color = Color(.systemBackground)
    ) -> some View {
        self
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(12)
    }

    // MARK: - 加载状态
    /// 应用加载状态遮罩
    // Android类比: 类似Android的ProgressBar覆盖层
    @ViewBuilder
    func overlayLoading(isLoading: Bool) -> some View {
        if isLoading {
            self
                .overlay {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(12)
                }
                .disabled(true)
        } else {
            self
        }
    }

    // MARK: - 错误处理
    /// 应用错误提示
    // Android类比: 类似Android的Snackbar或Toast
    @ViewBuilder
    func alertError(error: Binding<String?>, buttonTitle: String = "确定") -> some View {
        self.alert(
            "错误",
            isPresented: .constant(error.wrappedValue != nil),
            presenting: error.wrappedValue,
            actions: { _ in
                Button(buttonTitle) {
                    error.wrappedValue = nil
                }
            },
            message: { errorMessage in
                Text(errorMessage)
            }
        )
    }

    // MARK: - 布局辅助
    /// 水平居中
    // Android类比: Modifier.align(Alignment.CenterHorizontally)
    func hCenter() -> some View {
        frame(maxWidth: .infinity, alignment: .center)
    }

    /// 垂直居中
    // Android类比: Modifier.align(Alignment.CenterVertically)
    func vCenter() -> some View {
        frame(maxHeight: .infinity, alignment: .center)
    }

    /// 居中（水平和垂直）
    // Android类比: Modifier.align(Alignment.Center)
    func center() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    /// 占满可用空间
    // Android类比: Modifier.fillMaxSize()
    func fill() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 响应式布局
    /// 适配不同屏幕尺寸
    // Android类比: 类似Compose的WindowSizeMode或不同尺寸的资源限定符
    @ViewBuilder
    func adaptiveLayout<CompactContent: View, RegularContent: View>(
        @ViewBuilder compact: () -> CompactContent,
        @ViewBuilder regular: () -> RegularContent
    ) -> some View {
        // 使用@Environment读取屏幕尺寸类型
        @Environment(\.horizontalSizeClass) var horizontalSizeClass

        if horizontalSizeClass == .compact {
            compact()
        } else {
            regular()
        }
    }
}

// MARK: - 隐藏键盘
// Android类比: 类似Android的InputMethodManager.hideSoftInputFromWindow()
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - 触摸手势
// Android类比: 类似Android的OnClickListener
extension View {
    /// 添加点击手势（带触觉反馈）
    // Android类比: Modifier.clickable(onClickLabel = "...", interactionSource = ...)
    func tapWithHaptic(
        onTap: @escaping () -> Void,
        hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) -> some View {
        self
            .onTapGesture {
                // 触觉反馈
                // Android类比: 类似View.performHapticFeedback()
                let generator = UIImpactFeedbackGenerator(style: hapticStyle)
                generator.impactOccurred()
                onTap()
            }
    }
}

#if DEBUG
// MARK: - 调试辅助
extension View {
    /// 调试边框（仅用于调试布局）
    // Android类比: 类似Compose的debugBorder()
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        self.border(color, width: width)
    }

    /// 打印视图尺寸（仅用于调试）
    func onSizeChanged(action: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        action(geometry.size)
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        action(newSize)
                    }
            }
        )
    }
}
#endif
