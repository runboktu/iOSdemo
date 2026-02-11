//
//  ProfileView.swift
//  iosDemo
//
//  个人中心视图 - 显示用户信息和设置
//  Android类比: 类似ProfileFragment或ProfileActivity
//

import SwiftUI

// MARK: - 个人中心视图
// Android类比: class ProfileFragment : Fragment()
struct ProfileView: View {

    // MARK: - 状态
    /// 显示编辑个人资料弹窗
    @State private var showEditProfile: Bool = false

    /// 显示设置页
    @State private var showSettings: Bool = false

    /// 显示登出确认
    @State private var showLogoutAlert: Bool = false

    /// 显示删除账户确认
    @State private var showDeleteAccountAlert: Bool = false

    /// 显示主题选择器
    @State private var showThemePicker: Bool = false

    /// 显示语言选择器
    @State private var showLanguagePicker: Bool = false

    // MARK: - 依赖注入
    @State private var viewModel = ProfileViewModel()

    // MARK: - 视图
    var body: some View {
        NavigationStack {
            List {
                // 用户信息卡片
                // Android类比: include user_info_card.xml
                userInfoSection

                // 统计信息
                // Android类比: include stats_section.xml
                if viewModel.isLoggedIn {
                    statsSection
                }

                // 功能列表
                // Android类比: 功能菜单项列表
                settingsSection

                // 关于信息
                // Android类比: include about_section.xml
                aboutSection

                // 登出/登录按钮
                // Android类比: Button with login/logout action
                logoutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("我的")
            .toolbar {
                // 设置按钮
                // Android类比: MenuItem with settings icon
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            // 编辑资料弹窗
            // Android类比: BottomSheetDialog或Dialog
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
            // 设置页
            // Android类比: startActivity(SettingsActivity::class.java)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            // 登出确认
            // Android类比: AlertDialog
            .alert("确认登出", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) {}
                Button("登出", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
            // 删除账户确认
            .alert("删除账户", isPresented: $showDeleteAccountAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
            } message: {
                Text("此操作不可撤销，确定要删除账户吗？")
            }
            // 错误提示
            .alertError(error: $viewModel.errorMessage)
        }
    }

    // MARK: - 用户信息区域
    // Android类比: user_info_card.xml
    @ViewBuilder
    private var userInfoSection: some View {
        Section {
            HStack(spacing: Spacing.md) {
                // 头像
                // Android类比: CircleImageView
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 64, height: 64)

                    Text(viewModel.initials)
                        .font(Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }

                // 用户信息
                // Android类比: TextView with user name and email
                VStack(alignment: .leading, spacing: Spacing.xxxs) {
                    Text(viewModel.displayName)
                        .font(Typography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    if let user = viewModel.currentUser {
                        Text(user.email)
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    } else if !viewModel.isLoggedIn {
                        Text("登录后查看更多信息")
                            .font(Typography.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                // 箭头图标
                // Android类比: ImageView with arrow
                if viewModel.isLoggedIn {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.gray400)
                }
            }
            .padding(.vertical, Spacing.xs)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.isLoggedIn {
                    showEditProfile = true
                } else {
                    // 跳转到登录页
                    // Android类比: startActivity(LoginActivity::class.java)
                }
            }
        }
    }

    // MARK: - 统计信息区域
    // Android类比: stats_section.xml
    @ViewBuilder
    private var statsSection: some View {
        Section(header: Text("统计")) {
            HStack(spacing: 0) {
                // 帖子数
                // Android类比: TextView with posts count
                StatItem(
                    icon: "doc.text.fill",
                    title: "帖子",
                    value: "\(viewModel.stats.postsCount)"
                )

                Divider()
                    .frame(height: 40)

                // 评论数
                StatItem(
                    icon: "bubble.right.fill",
                    title: "评论",
                    value: "\(viewModel.stats.commentsCount)"
                )

                Divider()
                    .frame(height: 40)

                // 收藏数
                StatItem(
                    icon: "heart.fill",
                    title: "收藏",
                    value: "\(viewModel.stats.favoritesCount)"
                )
            }
        }
    }

    // MARK: - 设置区域
    // Android类比: 功能菜单列表
    @ViewBuilder
    private var settingsSection: some View {
        Section(header: Text("设置")) {
            // 主题设置
            // Android类比: Preference with theme selection
            HStack {
                Label("主题模式", systemImage: "paintbrush.fill")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(viewModel.appSettings.themeMode.rawValue)
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.gray400)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showThemePicker = true
            }
            .confirmationDialog("选择主题", isPresented: $showThemePicker, titleVisibility: .visible) {
                ForEach(AppSettings.themeOptions, id: \.0) { option in
                    Button(option.1) {
                        viewModel.updateTheme(option.0)
                    }
                }
            }

            // 语言设置
            HStack {
                Label("语言", systemImage: "globe")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(currentLanguageName)
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.gray400)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showLanguagePicker = true
            }
            .confirmationDialog("选择语言", isPresented: $showLanguagePicker, titleVisibility: .visible) {
                ForEach(AppSettings.languageOptions, id: \.0) { option in
                    Button(option.1) {
                        viewModel.updateLanguage(option.0)
                    }
                }
            }

            // 通知设置
            // Android类比: SwitchPreferenceCompat
            HStack {
                Label("推送通知", systemImage: "bell.fill")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { viewModel.appSettings.enableNotifications },
                    set: { viewModel.toggleNotifications($0) }
                ))
            }

            // 字体大小
            HStack {
                Label("字体大小", systemImage: "textformat.size")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("\(Int(viewModel.appSettings.fontSize))")
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - 关于区域
    @ViewBuilder
    private var aboutSection: some View {
        Section(header: Text("关于")) {
            // 版本信息
            // Android类比: Preference with app version
            HStack {
                Label("版本", systemImage: "info.circle.fill")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text(AppBehavior.appVersion)
                    .font(Typography.callout)
                    .foregroundColor(AppColors.textSecondary)
            }

            // 清除缓存
            // Android类比: Preference with clear cache action
            Button(action: {
                viewModel.clearCache()
            }) {
                HStack {
                    Label("清除缓存", systemImage: "trash.fill")
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text("清除")
                        .font(Typography.callout)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // 反馈
            HStack {
                Label("意见反馈", systemImage: "envelope.fill")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.gray400)
            }

            // 关于
            HStack {
                Label("关于我们", systemImage: "heart.circle.fill")
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.gray400)
            }
        }
    }

    // MARK: - 登出区域
    @ViewBuilder
    private var logoutSection: some View {
        Section {
            if viewModel.isLoggedIn {
                // 登出按钮
                // Android类比: Button with logout action
                Button(role: .destructive, action: {
                    showLogoutAlert = true
                }) {
                    HStack {
                        Spacer()
                        Label("退出登录", systemImage: "arrow.right.square")
                        Spacer()
                    }
                }
            } else {
                // 登录按钮
                Button(action: {
                    Task {
                        await viewModel.login(username: "demo", password: "123456")
                    }
                }) {
                    HStack {
                        Spacer()
                        Label("登录 / 注册", systemImage: "person.circle")
                        Spacer()
                    }
                }
            }

            // 危险操作区域
            if viewModel.isLoggedIn {
                Button(role: .destructive, action: {
                    showDeleteAccountAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text("删除账户")
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - 计算属性
    /// 当前语言名称
    private var currentLanguageName: String {
        AppSettings.languageOptions.first { $0.0 == viewModel.appSettings.language }?.1 ?? "简体中文"
    }
}

// MARK: - 统计项组件
// Android类比: stat_item.xml
struct StatItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: Spacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primary)

            Text(value)
                .font(Typography.callout)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            Text(title)
                .font(Typography.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 编辑资料弹窗
struct EditProfileSheet: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("手机号", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            _ = await viewModel.updateProfile(name: name, email: email, phone: phone)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
            .onAppear {
                name = viewModel.currentUser?.name ?? ""
                email = viewModel.currentUser?.email ?? ""
                phone = viewModel.currentUser?.phone ?? ""
            }
        }
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("外观")) {
                    // 主题选择器
                    Picker("主题模式", selection: Binding(
                        get: { viewModel.appSettings.themeMode },
                        set: { viewModel.updateTheme($0) }
                    )) {
                        ForEach(AppSettings.themeOptions, id: \.0) { option in
                            HStack {
                                Image(systemName: option.2)
                                Text(option.1)
                            }
                            .tag(option.0)
                        }
                    }
                    .pickerStyle(.inline)

                    // 语言选择
                    Picker("语言", selection: Binding(
                        get: { viewModel.appSettings.language },
                        set: { viewModel.updateLanguage($0) }
                    )) {
                        ForEach(AppSettings.languageOptions, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }

                    // 字体大小滑块
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text("字体大小")
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Text("\(Int(viewModel.appSettings.fontSize))")
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Slider(
                            value: Binding(
                                get: { viewModel.appSettings.fontSize },
                                set: { viewModel.updateFontSize($0) }
                            ),
                            in: 12...24,
                            step: 1
                        )
                    }
                    .padding(.vertical, Spacing.xxs)
                }

                Section(header: Text("通知")) {
                    Toggle("推送通知", isOn: Binding(
                        get: { viewModel.appSettings.enableNotifications },
                        set: { viewModel.toggleNotifications($0) }
                    ))
                }

                Section(header: Text("存储")) {
                    Button(action: {
                        viewModel.clearCache()
                    }) {
                        HStack {
                            Text("清除缓存")
                                .foregroundColor(AppColors.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.gray400)
                        }
                    }

                    Button(role: .destructive, action: {
                        viewModel.resetAllSettings()
                    }) {
                        Text("重置所有设置")
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 预览
#Preview("Profile View - Logged In") {
    ProfileView()
        .environment({
            let vm = ProfileViewModel()
            vm.currentUser = User.mock
            vm.isLoggedIn = true
            return vm
        }())
}

#Preview("Profile View - Guest") {
    ProfileView()
}

#Preview("Profile View Dark Mode") {
    ProfileView()
        .environment({
            let vm = ProfileViewModel()
            vm.currentUser = User.mock
            vm.isLoggedIn = true
            return vm
        }())
        .preferredColorScheme(.dark)
}
