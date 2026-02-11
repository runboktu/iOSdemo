//
//  Persistence.swift
//  iosDemo
//
//  旧的Core Data Persistence文件
//  注意：此项目已迁移到SwiftData，请使用AppDataContainer
//  此文件保留仅为向后兼容，实际使用SwiftDataContainer.swift
//

import Foundation
import SwiftData

// 标记为已弃用
@available(*, deprecated, message: "Use AppDataContainer instead. Core Data has been replaced with SwiftData.")
typealias PersistenceController = AppDataContainer
