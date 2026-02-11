//
//  SwiftDataContainer.swift
//  iosDemo
//
//  SwiftData数据库容器配置
//  Android类比: 类似Room的Database.Builder或Room.databaseBuilder()
//

import Foundation
import SwiftData

// MARK: - SwiftData容器配置
// Android类比: 类似Room数据库的配置类
// 注意：@main在iosDemoApp.swift中定义，这里只定义ModelContainer
struct AppDataContainer {
    // MARK: - ModelContainer配置
    // Android类比: 类似Room.databaseBuilder()的配置
    static let modelContainer: ModelContainer = {
        do {
            // 定义数据库Schema（表结构）
            // Android类比: 类似Room的@Database注解中的entities数组
            let schema = Schema([
                TodoItem.self,
                PostEntity.self,
                UserEntity.self
            ])

            // 配置数据库选项
            // Android类比: 类似Room的Database.Builder配置
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false, // 持久化存储（非内存模式）
                allowsSave: true,            // 允许保存
                cloudKitDatabase: .none      // 不使用CloudKit（可改为automatic启用）
            )

            // 创建ModelContainer
            // Android类比: 类似Room.databaseBuilder().build()
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            // 数据库创建失败时的处理
            // Android类比: 类似Room的CreationFailure错误处理
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
}

// MARK: - SwiftData便捷扩展
// Android类比: 类似Room的Database类扩展方法
extension ModelContext {
    /// 保存上下文更改（带错误处理）
    // Android类比: 类似Room的@Transaction注解方法
    func safeSave() {
        do {
            try self.save()
        } catch {
            print("Failed to save ModelContext: \(error)")
            // 在实际应用中，应该将错误传递给UI层显示
        }
    }

    /// 批量插入数据
    // Android类比: 类似Room的@Insert注解的onConflict策略
    func batchInsert<T: PersistentModel>(_ items: [T]) {
        items.forEach { insert($0) }
        safeSave()
    }
}

// MARK: - 数据库迁移辅助类
// Android类比: 类似Room的Migration类
struct SwiftDataMigration {
    /// 获取Schema版本
    // Android类比: 类似Room的version = 1配置
    static let currentVersion: Schema.Version = Schema.Version(1, 0, 0)

    /// 迁移计划（未来版本升级时使用）
    // Android类比: 类似Room的Migration(1, 2)等
    static var migrationPlan: any VersionedSchema.Type {
        // 在未来版本中，可以定义多个版本的Schema
        // 然后使用MigrationPlan进行迁移
        return AppDataSchema_V1.self
    }
}

// MARK: - V1 Schema定义（当前版本）
// Android类比: 类似Room的v1版本的数据库定义
enum AppDataSchema_V1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [TodoItem.self, PostEntity.self, UserEntity.self]
    }

    // 注意：Model定义在其他文件中（Todo.swift, Post.swift, User.swift），这里只用于版本管理

    // MARK: - 准备迁移（示例）
    // Android类比: 类似Room的Migration.migrate()方法
    static func migrate(from: Schema.Version) throws {
        // 在未来版本中，这里可以编写数据迁移逻辑
        // 例如：添加新字段、修改表结构等
    }
}
