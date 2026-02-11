//
//  User.swift
//  iosDemo
//
//  用户数据模型
//  Android类比: 类似Kotlin的data class或Room的@Entity
//

import Foundation
import SwiftData

// MARK: - 用户模型
// Android类比: 类似data class User(...) 或 Room的@Entity
struct User: Codable, Identifiable, Equatable {
    // 用户ID - Identifiable协议要求必须有id属性
    // Android类比: 类似@ColumnInfo(name = "id") val id: Int
    let id: Int

    // 用户名
    // Android类比: @ColumnInfo(name = "username") val username: String
    let username: String

    // 姓名
    let name: String

    // 邮箱
    let email: String

    // 电话
    let phone: String

    // 网站
    let website: String

    // 公司信息
    let company: Company

    // 地址信息
    let address: Address

    // MARK: - 嵌套模型：公司信息
    // Android类比: 类似嵌套的data class
    struct Company: Codable, Equatable {
        let name: String
        let catchPhrase: String
        let bs: String
    }

    // MARK: - 嵌套模型：地址信息
    // Android类比: 类似嵌套的data class，可以使用@Embedded注解
    struct Address: Codable, Equatable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo

        // 地理坐标
        struct Geo: Codable, Equatable {
            let lat: String
            let lng: String
        }
    }

    // MARK: - 计算属性（Computed Property）
    // Android类比: 类似Kotlin的val custom getter
    var displayName: String {
        name.isEmpty ? username : name
    }

    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.map { String($0.prefix(1)) }.joined()
    }

    // MARK: - Mock数据（用于开发测试）
    // Android类比: 类似companion object中的静态工厂方法
    static let mock = User(
        id: 1,
        username: "mingshu",
        name: "明书",
        email: "mingshu@example.com",
        phone: "1-770-736-8031",
        website: "example.com",
        company: Company(name: "Tech Corp", catchPhrase: "Innovating solutions", bs: "B2B"),
        address: Address(street: "123 Main St", suite: "Apt 1", city: "Beijing", zipcode: "100000", geo: User.Address.Geo(lat: "39.9042", lng: "116.4074"))
    )

    // MARK: - 示例数据数组
    // Android类比: 类似companion object中的静态工厂方法
    static let mocks: [User] = [
        mock,
        User(
            id: 2,
            username: "john_doe",
            name: "John Doe",
            email: "john@example.com",
            phone: "2-123-456-7890",
            website: "johndoe.com",
            company: Company(name: "John's Company", catchPhrase: "Making things", bs: "B2C"),
            address: Address(street: "456 Oak Ave", suite: "Suite 100", city: "Shanghai", zipcode: "200000", geo: User.Address.Geo(lat: "31.2304", lng: "121.4737"))
        ),
        User(
            id: 3,
            username: "jane_smith",
            name: "Jane Smith",
            email: "jane@example.com",
            phone: "3-987-654-3210",
            website: "janesmith.com",
            company: Company(name: "Jane Inc", catchPhrase: "Doing great work", bs: "SaaS"),
            address: Address(street: "789 Pine Rd", suite: "Floor 5", city: "Shenzhen", zipcode: "518000", geo: User.Address.Geo(lat: "22.5431", lng: "114.0579"))
        )
    ]
}

// MARK: - SwiftData持久化模型（iOS 17+）
// Android类比: 类似Room的@Entity定义
@Model
final class UserEntity {
    var id: Int
    var username: String
    var name: String
    var email: String
    var phone: String
    var website: String
    var companyName: String
    var city: String
    var createdAt: Date

    init(user: User) {
        self.id = user.id
        self.username = user.username
        self.name = user.name
        self.email = user.email
        self.phone = user.phone
        self.website = user.website
        self.companyName = user.company.name
        self.city = user.address.city
        self.createdAt = Date()
    }

    // 转换为普通User模型
    // Android类比: 类似Entity到Domain Model的转换函数
    func toUser() -> User {
        User(
            id: id,
            username: username,
            name: name,
            email: email,
            phone: phone,
            website: website,
            company: User.Company(name: companyName, catchPhrase: "", bs: ""),
            address: User.Address(street: "", suite: "", city: city, zipcode: "", geo: User.Address.Geo(lat: "", lng: ""))
        )
    }
}
