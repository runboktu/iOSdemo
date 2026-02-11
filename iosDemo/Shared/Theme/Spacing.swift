//
//  Spacing.swift
//  iosDemo
//
//  间距定义 - 统一管理应用间距
//  Android类比: 类似dimens.xml或Spacing.kt文件
//

import SwiftUI

// MARK: - 间距系统
// Android类比: 类似dimens.xml中的dimen定义
struct Spacing {

    // MARK: - 基础间距（4的倍数）
    /// 极小间距 (4pt)
    // Android类比: <dimen name="spacing_xxxs">4dp</dimen>
    static let xxxs: CGFloat = 4

    /// 超小间距 (8pt)
    // Android类比: <dimen name="spacing_xxs">8dp</dimen>
    static let xxs: CGFloat = 8

    /// 小间距 (12pt)
    // Android类比: <dimen name="spacing_xs">12dp</dimen>
    static let xs: CGFloat = 12

    /// 中小间距 (16pt)
    // Android类比: <dimen name="spacing_sm">16dp</dimen>
    static let sm: CGFloat = 16

    /// 中等间距 (20pt)
    // Android类比: <dimen name="spacing_md">20dp</dimen>
    static let md: CGFloat = 20

    /// 中大间距 (24pt)
    // Android类比: <dimen name="spacing_lg">24dp</dimen>
    static let lg: CGFloat = 24

    /// 大间距 (32pt)
    // Android类比: <dimen name="spacing_xl">32dp</dimen>
    static let xl: CGFloat = 32

    /// 超大间距 (48pt)
    // Android类比: <dimen name="spacing_xxl">48dp</dimen>
    static let xxl: CGFloat = 48

    // MARK: - 组件间距
    /// 列表项内边距
    // Android类比: <dimen name="padding_list_item">16dp</dimen>
    static let listItemPadding: CGFloat = 16

    /// 列表项间距
    // Android类比: <dimen name="margin_list_item">8dp</dimen>
    static let listItemMargin: CGFloat = 8

    /// 卡片内边距
    // Android类比: <dimen name="padding_card">16dp</dimen>
    static let cardPadding: CGFloat = 16

    /// 卡片间距
    // Android类比: <dimen name="margin_card">12dp</dimen>
    static let cardMargin: CGFloat = 12

    /// 屏幕边距
    // Android类比: <dimen name="margin_screen">16dp</dimen>
    static let screenMargin: CGFloat = 16

    /// 按钮内边距
    // Android类比: <dimen name="padding_button">12dp</dimen>
    static let buttonPadding: CGFloat = 12

    /// 输入框内边距
    // Android类比: <dimen name="padding_text_field">12dp</dimen>
    static let textFieldPadding: CGFloat = 12

    // MARK: - 圆角
    /// 小圆角
    // Android类比: <dimen name="corner_radius_sm">8dp</dimen>
    static let cornerRadiusSM: CGFloat = 8

    /// 中等圆角
    // Android类比: <dimen name="corner_radius_md">12dp</dimen>
    static let cornerRadiusMD: CGFloat = 12

    /// 大圆角
    // Android类比: <dimen name="corner_radius_lg">16dp</dimen>
    static let cornerRadiusLG: CGFloat = 16

    /// 超大圆角
    // Android类比: <dimen name="corner_radius_xl">24dp</dimen>
    static let cornerRadiusXL: CGFloat = 24

    // MARK: - 尺寸
    /// 最小触摸目标尺寸 (44pt)
    // Android类比: 48dp触摸目标
    static let minTouchTarget: CGFloat = 44

    /// 图标尺寸
    // Android类比: <dimen name="icon_size">24dp</dimen>
    static let iconSize: CGFloat = 24

    /// 头像尺寸（小）
    static let avatarSizeSM: CGFloat = 32

    /// 头像尺寸（中）
    static let avatarSizeMD: CGFloat = 48

    /// 头像尺寸（大）
    static let avatarSizeLG: CGFloat = 64

    /// 分割线高度
    // Android类比: <dimen name="divider_height">1dp</dimen>
    static let dividerHeight: CGFloat = 1

    // MARK: - 阴影
    /// 小阴影
    static let shadowSM: CGFloat = 2

    /// 中等阴影
    static let shadowMD: CGFloat = 4

    /// 大阴影
    static let shadowLG: CGFloat = 8
}

// MARK: - View间距扩展
// Android类比: 类似Compose的Modifier.padding扩展
extension View {

    /// 应用极小间距
    // Android类比: Modifier.padding(Spacing.xxxs)
    func paddingXXS() -> some View {
        padding(Spacing.xxxs)
    }

    /// 应用超小间距
    func paddingXXS(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.xxxs)
    }

    /// 应用小间距
    func paddingXS(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.xs)
    }

    /// 应用中小间距
    func paddingSM(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.sm)
    }

    /// 应用中等间距
    func paddingMD(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.md)
    }

    /// 应用中大间距
    func paddingLG(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.lg)
    }

    /// 应用大间距
    func paddingXL(_ edges: Edge.Set = .all) -> some View {
        padding(edges, Spacing.xl)
    }

    /// 应用屏幕边距
    // Android类比: Modifier.padding(16.dp)
    func screenPadding() -> some View {
        padding(Spacing.screenMargin)
    }
}

// 注意：SwiftUI没有VerticalAlignment间距，这里只是展示概念
// 实际使用时应该直接在VStack中使用spacing参数

// MARK: - VStack间距扩展
extension View {
    /// 创建带有预设间距的VStack辅助
    // Android类比: Column(verticalArrangement = Arrangement.spacedBy(8.dp))
    func vSpacedXXXS() -> some View {
        self
    }

    func vSpacedXXS() -> some View {
        self
    }

    func vSpacedXS() -> some View {
        self
    }

    func vSpacedSM() -> some View {
        self
    }
}

// MARK: - 间距预设（用于VStack/HStack等）
// Android类比: 类似Arrangement.spacedBy()
enum SpacingPreset {
    case xxxs, xxs, xs, sm, md, lg, xl, xxl

    var value: CGFloat {
        switch self {
        case .xxxs: return Spacing.xxxs
        case .xxs: return Spacing.xxs
        case .xs: return Spacing.xs
        case .sm: return Spacing.sm
        case .md: return Spacing.md
        case .lg: return Spacing.lg
        case .xl: return Spacing.xl
        case .xxl: return Spacing.xxl
        }
    }
}

// MARK: - EdgeInsets扩展
// Android类比: 类似Rect或padding值的计算
extension EdgeInsets {
    /// 统一的内边距
    // Android类比: Rect(all = 16)
    static func uniform(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }

    /// 水平内边距
    // Android类比: paddingHorizontal = 16
    static func horizontal(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
    }

    /// 垂直内边距
    // Android类比: paddingVertical = 16
    static func vertical(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
    }

    /// 常用的内边距预设
    static let card = EdgeInsets(top: Spacing.cardPadding, leading: Spacing.cardPadding, bottom: Spacing.cardPadding, trailing: Spacing.cardPadding)
    static let listItem = EdgeInsets(top: Spacing.listItemPadding, leading: Spacing.listItemPadding, bottom: Spacing.listItemPadding, trailing: Spacing.listItemPadding)
    static let button = EdgeInsets(top: Spacing.buttonPadding, leading: Spacing.buttonPadding, bottom: Spacing.buttonPadding, trailing: Spacing.buttonPadding)
}
