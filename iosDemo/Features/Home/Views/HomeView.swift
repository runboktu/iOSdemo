//
//  HomeView.swift
//  iosDemo
//
//  首页视图 - 应用主页面，显示帖子列表
//  Android类比: 类似Fragment或Activity + RecyclerView
//

import SwiftUI

// MARK: - 首页视图
// Android类比: class HomeFragment : Fragment()
struct HomeView: View {

    // MARK: - 状态
    /// 搜索文本
    // Android类比: private val searchQuery = MutableStateFlow("")
    @State private var searchQuery: String = ""

    /// 选中的帖子（用于导航）
    // Android类比: private var selectedPost: Post? = null
    @State private var selectedPost: Post?

    /// 显示搜索栏
    // Android类比: private var showSearchBar = MutableStateFlow(false)
    @State private var showSearchBar: Bool = false

    // MARK: - 依赖注入
    /// ViewModel（从环境获取）
    // Android类比: private val viewModel: HomeViewModel by viewModels()
    @Environment(HomeViewModel.self) private var viewModel

    // MARK: - 视图
    var body: some View {
        // NavigationStack - 类型安全的导航容器
        // Android类比: NavHost 或 NavController
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏（可展开）
                // Android类比: SearchView 或 EditText
                if showSearchBar {
                    searchBarView
                }

                // 帖子列表
                // Android类比: RecyclerView
                PostListView(
                    listStyle: .list,
                    onPostTap: { post in
                        selectedPost = post
                    }
                )
            }
            .navigationTitle("首页")
            .navigationDestination(isPresented: Binding(
                get: { selectedPost != nil },
                set: { if !$0 { selectedPost = nil } }
            )) {
                // 帖子详情页
                // Android类比: Fragment导航或Intent
                if let post = selectedPost {
                    DetailView(post: post)
                }
            }
            .toolbar {
                // 导航栏工具栏
                // Android类比: onCreateOptionsMenu 或 MenuItem
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarItems
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingToolbarItems
                }
            }
            // 搜索栏
            .searchable(
                text: $searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "搜索帖子..."
            )
            .onChange(of: searchQuery) { oldValue, newValue in
                // 搜索输入变化
                // Android类比: TextWatcher.afterTextChanged
                viewModel.search(query: newValue)
            }
            // 视图出现时加载数据
            // Android类比: onViewCreated 或 onActivityCreated
            .task {
                if viewModel.posts.isEmpty {
                    await viewModel.loadPosts()
                }
            }
        }
    }

    // MARK: - 搜索栏视图
    // Android类比: SearchView 或 SearchBar
    @ViewBuilder
    private var searchBarView: some View {
        HStack(spacing: Spacing.sm) {
            // 搜索框
            // Android类比: EditText
            HStack(spacing: Spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.gray500)

                TextField("搜索帖子标题或内容...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppColors.textPrimary)

                if !searchQuery.isEmpty {
                    // 清除按钮
                    Button(action: {
                        searchQuery = ""
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.gray400)
                    }
                }
            }
            .padding(Spacing.sm)
            .background(AppColors.gray100)
            .cornerRadius(Spacing.cornerRadiusSM)

            // 取消按钮
            Button("取消") {
                showSearchBar = false
                searchQuery = ""
                viewModel.clearSearch()
            }
            .foregroundColor(AppColors.primary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color(.systemBackground))
    }

    // MARK: - 导航栏左侧工具
    @ViewBuilder
    private var leadingToolbarItems: some View {
        Menu {
            // 筛选选项
            // Android类比: PopupMenu或SubMenu
            Button(action: {}) {
                Label("最新发布", systemImage: "clock")
            }

            Button(action: {}) {
                Label("最多评论", systemImage: "bubble.right")
            }

            Button(action: {}) {
                Label("最多点赞", systemImage: "heart")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(AppColors.primary)
        }
    }

    // MARK: - 导航栏右侧工具
    @ViewBuilder
    private var trailingToolbarItems: some View {
        HStack(spacing: Spacing.sm) {
            // 切换列表样式
            // Android类比: MenuItem with icon
            Menu {
                Button("列表样式", systemImage: "list.bullet") {}
                Button("卡片样式", systemImage: "square.grid.2x2") {}
                Button("紧凑样式", systemImage: "line.horizontal.3") {}
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            // 刷新按钮
            // Android类比: MenuItem with refresh icon
            Button(action: {
                Task {
                    await viewModel.refresh()
                }
            }) {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}

// MARK: - 带Tab栏的首页包装器
// Android类比: MainActivity + BottomNavigationView
struct HomeTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case search
        case todo
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            // Android类比: BottomNavigationView的菜单项
            HomeView()
                .tabItem {
                    Label("首页", systemImage: selectedTab == .home ? "house.fill" : "house")
                }
                .tag(Tab.home)

            // 搜索页
            SearchView()
                .tabItem {
                    Label("搜索", systemImage: selectedTab == .search ? "magnifyingglass.circle.fill" : "magnifyingglass")
                }
                .tag(Tab.search)

            // 待办页
            TodoListView()
                .tabItem {
                    Label("待办", systemImage: selectedTab == .todo ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .tag(Tab.todo)

            // 个人中心
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: selectedTab == .profile ? "person.circle.fill" : "person.circle")
                }
                .tag(Tab.profile)
        }
        .tint(AppColors.primary)
    }
}

// MARK: - 预览
#Preview("Home View") {
    HomeView()
        .environment(HomeViewModel())
}

#Preview("Home View with Data") {
    NavigationStack {
        HomeView()
            .environment({
                let vm = HomeViewModel()
                vm.posts = Post.mocks
                return vm
            }())
    }
}

#Preview("Home View Dark Mode") {
    HomeView()
        .environment(HomeViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Tab View") {
    HomeTabView()
        .environment(HomeViewModel())
}
