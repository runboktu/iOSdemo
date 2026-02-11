//
//  Colors.swift
//  iosDemo
//
//  颜色定义 - 统一管理应用颜色
//  Android类比: 类似colors.xml或Color.kt文件
//

import SwiftUI

// MARK: - 颜色主题
// Android类比: 类似Material Design的颜色系统或colors.xml
struct AppColors {

    // MARK: - 品牌色
    /// 主色（Primary）
    // Android类比: <color name="colorPrimary">#6366F1</color>
    static let primary = Color(red: 0.39, green: 0.4, blue: 0.95)
    static let primaryDark = Color(red: 0.29, green: 0.31, blue: 0.85)
    static let primaryLight = Color(red: 0.49, green: 0.51, blue: 1.0)

    /// 次要色（Secondary）
    // Android类比: <color name="colorSecondary">#EC4899</color>
    static let secondary = Color(red: 0.93, green: 0.28, blue: 0.6)
    static let secondaryDark = Color(red: 0.83, green: 0.18, blue: 0.5)
    static let secondaryLight = Color(red: 1.0, green: 0.38, blue: 0.7)

    // MARK: - 功能色
    /// 成功色
    // Android类比: <color name="colorSuccess">#10B981</color>
    static let success = Color(red: 0.06, green: 0.73, blue: 0.51)
    static let successLight = Color(red: 0.16, green: 0.83, blue: 0.61)

    /// 警告色
    // Android类比: <color name="colorWarning">#F59E0B</color>
    static let warning = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let warningLight = Color(red: 1.0, green: 0.72, blue: 0.14)

    /// 错误色
    // Android类比: <color name="colorError">#EF4444</color>
    static let error = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let errorLight = Color(red: 1.0, green: 0.37, blue: 0.37)

    /// 信息色
    // Android类比: <color name="colorInfo">#3B82F6</color>
    static let info = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let infoLight = Color(red: 0.33, green: 0.61, blue: 1.0)

    // MARK: - 中性色
    /// 文本色
    // Android类比: 类似Theme中的text colors
    static let textPrimary = Color(.label)            // 主要文本（随深色模式变化）
    static let textSecondary = Color(.secondaryLabel)  // 次要文本
    static let textTertiary = Color(.tertiaryLabel)    // 三级文本
    static let textInverse = Color.white               // 反色文本（白色）

    /// 背景色
    // Android类比: android:background="?attr/colorBackground"
    static let background = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    /// 分割线色
    // Android类比: <color name="colorDivider">#E5E7EB</color>
    static let divider = Color(.separator)
    static let dividerLight = Color(.separator).opacity(0.5)

    /// 填充色
    // Android类比: <color name="colorSurface">#FFFFFF</color>
    static let surface = Color(.systemBackground)
    static let surfaceVariant = Color(.secondarySystemBackground)

    // MARK: - 灰度色
    /// 灰度色阶（100-900）
    // Android类比: 类似Material Design的gray palette
    static let gray50 = Color(white: 0.98)
    static let gray100 = Color(white: 0.95)
    static let gray200 = Color(white: 0.9)
    static let gray300 = Color(white: 0.85)
    static let gray400 = Color(white: 0.75)
    static let gray500 = Color(white: 0.6)
    static let gray600 = Color(white: 0.45)
    static let gray700 = Color(white: 0.35)
    static let gray800 = Color(white: 0.25)
    static let gray900 = Color(white: 0.15)

    // MARK: - 渐变色
    /// 主色渐变
    // Android类比: 类似GradientDrawable
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 次要色渐变
    static let secondaryGradient = LinearGradient(
        colors: [secondary, secondaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 蓝色渐变
    static let blueGradient = LinearGradient(
        colors: [Color.blue, Color.blue.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 暖色渐变（橙-黄）
    static let warmGradient = LinearGradient(
        colors: [Color.orange, Color.yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 冷色渐变（蓝-紫）
    static let coolGradient = LinearGradient(
        colors: [Color.blue, Color.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color扩展
// Android类比: 类似Kotlin的Color扩展函数
extension Color {

    // MARK: - 初始化方法
    /// 从RGB值创建颜色（0-255）
    // Android类比: Color(rgb = 0xFF6366F1)
    init(rgb: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    /// 从十六进制字符串创建颜色
    // Android类比: Color.parseColor("#6366F1")
    init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    // MARK: - 颜色操作
    /// 调整亮度
    // Android类比: 类似ColorUtils.blendARGB()
    func adjustedBrightness(by amount: CGFloat) -> Color {
        // 简化版实现，实际应用中需要更复杂的HSB转换
        return self.opacity(max(0, min(1, amount)))
    }

    /// 变浅（混合白色）
    // Android类比: 类似ColorUtils.blendARGB() with WHITE
    func lightened(by amount: CGFloat = 0.2) -> Color {
        self.opacity(1 - amount)
    }

    /// 变深（混合黑色）
    // Android类比: 类似ColorUtils.blendARGB() with BLACK
    func darkened(by amount: CGFloat = 0.2) -> Color {
        // 简化实现
        return self
    }

    // MARK: - 颜色信息
    /// 转换为十六进制字符串
    // Android类比: fun Color.toHex(): String
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    /// 获取RGB值
    func rgbValue() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = UIColor(self).cgColor.components, components.count >= 4 else {
            return nil
        }
        return (components[0], components[1], components[2], components[3])
    }
}

// MARK: - 主题色扩展（用于SwiftUI）
// Android类比: 类似MaterialColor主题色
extension ShapeStyle where Self == Color {

    /// 品牌主色
    // Android类比: ?attr/colorPrimary
    static var brandPrimary: Color { AppColors.primary }

    /// 品牌次要色
    // Android类比: ?attr/colorSecondary
    static var brandSecondary: Color { AppColors.secondary }

    /// 成功状态色
    // Android类比: ?attr/colorSuccess
    static var statusSuccess: Color { AppColors.success }

    /// 警告状态色
    // Android类比: ?attr/colorWarning
    static var statusWarning: Color { AppColors.warning }

    /// 错误状态色
    // Android类比: ?attr/colorError
    static var statusError: Color { AppColors.error }

    /// 信息状态色
    // Android类比: ?attr/colorInfo
    static var statusInfo: Color { AppColors.info }
}
