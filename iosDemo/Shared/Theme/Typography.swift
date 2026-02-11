//
//  Typography.swift
//  iosDemo
//
//  字体排版定义 - 统一管理应用字体样式
//  Android类比: 类似Typography.kt或textAppearance样式
//

import SwiftUI

// MARK: - 字体排版
// Android类比: 类似Material Design的Type Scale或Typography.kt
struct Typography {

    // MARK: - 标题样式
    /// 大标题（Large Title）- 用于页面主标题
    // Android类比: <style name="TextAppearance.MaterialComponents.Headline1">
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)

    /// 标题1（Title 1）
    // Android类比: Headline2
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)

    /// 标题2（Title 2）
    // Android类比: Headline3
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)

    /// 标题3（Title 3）
    // Android类比: Headline4
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)

    /// 大标题（Headline）- 用于章节标题
    // Android类比: Headline5
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)

    // MARK: - 正文样式
    /// 正文（Body）- 主要内容文本
    // Android类比: TextAppearance.MaterialComponents.Body1
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// 次要正文（Callout）- 强调的正文
    // Android类比: TextAppearance.MaterialComponents.Body2
    static let callout = Font.system(size: 16, weight: .regular, design: .default)

    /// 子标题（Subheadline）
    // Android类比: TextAppearance.MaterialComponents.Subtitle1
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    /// 脚注（Footnote）
    // Android类比: TextAppearance.MaterialComponents.Caption
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)

    /// 说明文字（Caption）
    // Android类比: TextAppearance.MaterialComponents.Overline
    static let caption = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - 特殊样式
    /// 代码字体（Monospace）
    // Android类比: FontFamily.Monospace
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)

    /// 小号代码字体
    static let codeSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: - 字体权重
// Android类比: 类似FontWeight枚举
enum FontWeight {
    case ultraLight
    case thin
    case light
    case regular
    case medium
    case semibold
    case bold
    case heavy
    case black

    var value: Font.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}

// MARK: - Text样式扩展（便捷方法）
// Android类比: 类似Compose的TextStyle
extension View {

    /// 应用标题样式
    // Android类比: style = MaterialTheme.typography.h1
    func titleStyle() -> some View {
        font(Typography.title1)
    }

    /// 应用大标题样式
    func largeTitleStyle() -> some View {
        font(Typography.largeTitle)
    }

    /// 应用Headline样式
    func headlineStyle() -> some View {
        font(Typography.headline)
    }

    /// 应用Body样式
    // Android类比: style = MaterialTheme.typography.body1
    func bodyStyle() -> some View {
        font(Typography.body)
    }

    /// 应用次级Body样式
    func bodySecondaryStyle() -> some View {
        font(Typography.callout)
            .foregroundColor(.secondary)
    }

    /// 应用Caption样式
    // Android类比: style = MaterialTheme.typography.caption
    func captionStyle() -> some View {
        font(Typography.caption)
            .foregroundColor(.secondary)
    }
}

// MARK: - 自定义TextStyle
// Android类比: 类似SpanStyle或AnnotatedString
struct TextStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    let alignment: TextAlignment

    static let heading = TextStyle(
        font: Typography.headline,
        color: AppColors.textPrimary,
        lineSpacing: 2,
        alignment: .leading
    )

    static let body = TextStyle(
        font: Typography.body,
        color: AppColors.textPrimary,
        lineSpacing: 4,
        alignment: .leading
    )

    static let caption = TextStyle(
        font: Typography.caption,
        color: AppColors.textSecondary,
        lineSpacing: 2,
        alignment: .leading
    )

    static let code = TextStyle(
        font: Typography.code,
        color: AppColors.textPrimary,
        lineSpacing: 2,
        alignment: .leading
    )
}

// MARK: - Text扩展（应用样式）
// Android类比: 类似Compose的Modifier扩展
extension Text {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
            .lineSpacing(style.lineSpacing)
            .multilineTextAlignment(style.alignment)
    }
}

// MARK: - AttributedString样式辅助
// Android类比: 类似AnnotatedString.Builder
struct AttributedTextStyle {
    let font: Font
    let color: Color?

    func attributes() -> AttributeContainer {
        var container = AttributeContainer()
        container.font = font
        if let color = color {
            container.foregroundColor = color
        }
        return container
    }
}

// MARK: - 预定义的AttributedString样式
enum TextStyles {
    static let bold = AttributedTextStyle(font: Typography.headline, color: nil)
    static let link = AttributedTextStyle(font: Typography.body, color: .blue)
    static let codeInline = AttributedTextStyle(font: Typography.code, color: AppColors.error)
    static let muted = AttributedTextStyle(font: Typography.body, color: AppColors.textSecondary)
}
