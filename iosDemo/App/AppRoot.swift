//
//  AppRoot.swift
//  iosDemo
//
//  应用根视图 - 主界面入口
//  Android类比: 类似MainActivity的布局或NavHost
//

import SwiftUI

// MARK: - 应用根视图
// Android类比: class MainActivity : AppCompatActivity() 中的 setContentView
struct AppRoot: View {
    // MARK: - 状态
    /// 是否首次启动（显示引导页）
    // Android类比: val isFirstLaunch: Boolean = Preferences.isFirstLaunch()
    @State private var isFirstLaunch: Bool = UserDefaultsManager.shared.hasOnboarded == false

    /// 选中的Tab
    @State private var selectedTab: MainTab = .home

    // MARK: - 依赖注入
    @Environment(\.modelContext) private var modelContext

    // MARK: - 主Tab枚举
    // Android类比: 类似BottomNavigationView的菜单项
    enum MainTab: String, CaseIterable {
        case home = "首页"
        case search = "搜索"
        case todo = "待办"
        case profile = "我的"

        var iconName: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .todo: return "checkmark.circle"
            case .profile: return "person.circle"
            }
        }

        var iconFilled: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass.circle.fill"
            case .todo: return "checkmark.circle.fill"
            case .profile: return "person.circle.fill"
            }
        }
    }

    // MARK: - 视图
    var body: some View {
        // 首次启动显示引导页
        // Android类比: if (isFirstLaunch) showOnboarding()
        if isFirstLaunch {
            OnboardingView {
                // 完成引导
                isFirstLaunch = false
                UserDefaultsManager.shared.hasOnboarded = true
            }
        } else {
            // 主界面（Tab栏）
            // Android类比: setContentView(R.layout.activity_main) with BottomNavigationView
            mainView
        }
    }

    // MARK: - 主界面视图
    @ViewBuilder
    private var mainView: some View {
        TabView(selection: $selectedTab) {
            // 首页
            // Android类比: HomeFragment()
            HomeView()
                .tabItem {
                    Label(MainTab.home.rawValue, systemImage: selectedTab == .home ? MainTab.home.iconFilled : MainTab.home.iconName)
                }
                .tag(MainTab.home)
                .environment(HomeViewModel())

            // 搜索
            // Android类比: SearchFragment()
            SearchView()
                .tabItem {
                    Label(MainTab.search.rawValue, systemImage: selectedTab == .search ? MainTab.search.iconFilled : MainTab.search.iconName)
                }
                .tag(MainTab.search)
                .environment(SearchViewModel())

            // 待办
            // Android类比: TodoFragment()
            TodoListView()
                .tabItem {
                    Label(MainTab.todo.rawValue, systemImage: selectedTab == .todo ? MainTab.todo.iconFilled : MainTab.todo.iconName)
                }
                .tag(MainTab.todo)

            // 个人中心
            // Android类比: ProfileFragment()
            ProfileView()
                .tabItem {
                    Label(MainTab.profile.rawValue, systemImage: selectedTab == .profile ? MainTab.profile.iconFilled : MainTab.profile.iconName)
                }
                .tag(MainTab.profile)
        }
        .tint(AppColors.primary)
    }
}

// MARK: - 引导页视图
// Android类比: OnboardingActivity或ViewPager
struct OnboardingView: View {
    let onComplete: () -> Void

    // MARK: - 状态
    @State private var currentPage: Int = 0

    // MARK: - 引导页数据
    // Android类比: List<OnboardingPage>
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "swift",
            title: "欢迎使用iLearn",
            description: "专为Android开发者设计的iOS学习应用"
        ),
        OnboardingPage(
            icon: "ladder",
            title: "循序渐进学习",
            description: "每个代码点都有Android类比，快速上手SwiftUI"
        ),
        OnboardingPage(
            icon: "chart.bar.doc.horizontal",
            title: "现代架构实践",
            description: "MVVM + Combine + SwiftData，企业级项目架构"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 跳过按钮（非最后一页显示）
            // Android类比: FloatingActionButton或Button
            if currentPage < pages.count - 1 {
                HStack {
                    Spacer()
                    Button("跳过") {
                        onComplete()
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(Spacing.md)
                }
            }

            Spacer()

            // 引导页内容
            // Android类比: ViewPager2
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageContent(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Spacer()

            // 底部操作区
            // Android类比: 底部按钮区域
            VStack(spacing: Spacing.md) {
                // 下一步/完成按钮
                // Android类比: MaterialButton
                Button(action: {
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                    } else {
                        onComplete()
                    }
                }) {
                    Text(currentPage < pages.count - 1 ? "下一步" : "开始使用")
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Spacing.minTouchTarget)
                        .background(AppColors.primary)
                        .cornerRadius(Spacing.cornerRadiusMD)
                }

                // 页面指示器（手动）
                // Android类比: TabLayoutMediator
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.primary : AppColors.gray300)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.bottom, Spacing.lg)
            }
            .padding(Spacing.md)
        }
        .background(
            // 渐变背景
            // Android类比: gradient_background.xml
            LinearGradient(
                colors: [AppColors.primary.opacity(0.1), AppColors.secondary.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - 引导页内容组件
// Android类比: onboarding_page_item.xml
struct OnboardingPageContent: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // 图标
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(AppColors.primary)

            // 标题
            Text(page.title)
                .font(Typography.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            // 描述
            Text(page.description)
                .font(Typography.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .padding(Spacing.xl)
    }
}

// MARK: - 引导页数据模型
// Android类比: data class OnboardingPage(...)
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

// MARK: - 预览
#Preview("App Root") {
    AppRoot()
        .modelContainer(for: TodoItem.self, inMemory: true)
}

#Preview("Onboarding") {
    OnboardingView {
        print("Completed")
    }
}
