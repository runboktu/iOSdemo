//
//  PrimaryButton.swift
//  iosDemo
//
//  主要按钮组件 - 带动画和触觉反馈
//  Android类比: 类似MaterialButton或Compose的Button组件
//

import SwiftUI

// MARK: - 按钮样式枚举
// Android类比: 类似MaterialButton的style属性
enum ButtonStyle {
    case primary    // 主按钮（填充色）
    case secondary  // 次要按钮（边框）
    case tertiary   // 三级按钮（文本）
    case danger     // 危险按钮（红色）
    case success    // 成功按钮（绿色）
}

// MARK: - 主要按钮组件
// Android类比: 类似Compose的Button + Modifier
struct PrimaryButton: View {

    // MARK: - 属性
    /// 按钮标题
    // Android类比: val text: String
    let title: String

    /// 按钮样式
    // Android类比: val style: ButtonStyle
    var style: ButtonStyle = .primary

    /// 图标（可选）
    // Android类比: val icon: Painter?
    var icon: Image?

    /// 是否禁用
    // Android类比: val enabled: Boolean
    var isDisabled: Bool = false

    /// 是否显示加载状态
    // Android类比: val isLoading: Boolean
    var isLoading: Bool = false

    /// 点击回调
    // Android类比: val onClick: () -> Unit
    var action: () -> Void

    // MARK: - 状态
    @State private var isPressed = false

    // MARK: - 计算属性
    /// 获取背景色
    // Android类比: 根据状态动态设置背景色
    private var backgroundColor: Color {
        if isDisabled {
            return AppColors.gray400
        }

        switch style {
        case .primary:
            return AppColors.primary
        case .secondary:
            return AppColors.background
        case .tertiary:
            return .clear
        case .danger:
            return AppColors.error
        case .success:
            return AppColors.success
        }
    }

    /// 获取前景色
    private var foregroundColor: Color {
        if isDisabled {
            return AppColors.gray500
        }

        switch style {
        case .primary, .danger, .success:
            return .white
        case .secondary:
            return AppColors.primary
        case .tertiary:
            return AppColors.primary
        }
    }

    /// 获取边框色
    private var borderColor: Color? {
        switch style {
        case .primary, .danger, .success, .tertiary:
            return nil
        case .secondary:
            return AppColors.primary
        }
    }

    // MARK: - 视图
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                // 触觉反馈
                // Android类比: view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                action()
            }
        }) {
            HStack(spacing: Spacing.xs) {
                // 加载指示器
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.9)
                } else {
                    // 图标
                    if let icon = icon {
                        icon
                            .font(.system(size: Spacing.iconSize))
                    }

                    // 标题
                    Text(title)
                        .font(Typography.body)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.minTouchTarget)
            .background(
                Group {
                    if let borderColor = borderColor {
                        RoundedRectangle(cornerRadius: Spacing.cornerRadiusMD)
                            .fill(backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: Spacing.cornerRadiusMD)
                                    .stroke(borderColor, lineWidth: 1.5)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: Spacing.cornerRadiusMD)
                            .fill(backgroundColor)
                    }
                }
            )
            .opacity(isPressed ? 0.8 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled && !isLoading {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

// MARK: - 次要按钮组件
// Android类比: 类似MaterialButton的TextButton样式
struct SecondaryButton: View {
    let title: String
    var icon: Image?
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        PrimaryButton(
            title: title,
            style: .secondary,
            icon: icon,
            isDisabled: isDisabled,
            action: action
        )
    }
}

// MARK: - 文本按钮组件
// Android类比: 类似MaterialButton的TextButton或Compose的TextButton
struct TextButton: View {
    let title: String
    var icon: Image?
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            if !isDisabled {
                // 轻触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()

                action()
            }
        }) {
            HStack(spacing: Spacing.xxs) {
                if let icon = icon {
                    icon
                        .font(.system(size: 18))
                }

                Text(title)
                    .font(Typography.body)
                    .foregroundColor(isDisabled ? AppColors.gray400 : AppColors.primary)
            }
            .frame(height: Spacing.minTouchTarget)
        }
        .disabled(isDisabled)
    }
}

// MARK: - 图标按钮组件
// Android类比: 类似ImageButton或IconButton
struct IconButton: View {
    let icon: Image
    var iconSize: CGFloat = Spacing.iconSize
    var accessibilityLabel: String?
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            if !isDisabled {
                // 轻触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()

                action()
            }
        }) {
            icon
                .font(.system(size: iconSize))
                .foregroundColor(isDisabled ? AppColors.gray400 : AppColors.textPrimary)
                .frame(width: Spacing.minTouchTarget, height: Spacing.minTouchTarget)
        }
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel ?? "")
    }
}

// MARK: - 浮动操作按钮（FAB）
// Android类比: 类似FloatingActionButton
struct FloatingActionButton: View {
    let icon: Image
    var backgroundColor: Color = AppColors.primary
    var action: () -> Void

    var body: some View {
        Button(action: {
            // 强触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            action()
        }) {
            icon
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: backgroundColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - 预览
#Preview("Primary Button") {
    VStack(spacing: Spacing.md) {
        PrimaryButton(title: "主按钮", action: {})
        PrimaryButton(title: "禁用按钮", isDisabled: true, action: {})
        PrimaryButton(title: "加载中", isLoading: true, action: {})
        PrimaryButton(title: "带图标", icon: Image(systemName: "heart.fill"), action: {})
        PrimaryButton(title: "危险", style: .danger, icon: Image(systemName: "trash"), action: {})
        SecondaryButton(title: "次要按钮", action: {})
        SecondaryButton(title: "次要", icon: Image(systemName: "share"), action: {})
    }
    .padding()
}

#Preview("Text Button") {
    HStack(spacing: Spacing.md) {
        TextButton(title: "取消", action: {})
        TextButton(title: "保存", icon: Image(systemName: "checkmark"), action: {})
        TextButton(title: "禁用", isDisabled: true, action: {})
    }
    .padding()
}

#Preview("Icon Buttons") {
    HStack(spacing: Spacing.md) {
        IconButton(icon: Image(systemName: "heart"), action: {})
        IconButton(icon: Image(systemName: "heart.fill"), accessibilityLabel: "收藏", action: {})
        IconButton(icon: Image(systemName: "bookmark"), isDisabled: true, action: {})
    }
    .padding()
}
