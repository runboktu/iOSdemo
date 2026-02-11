//
//  String+Extensions.swift
//  iosDemo
//
//  String扩展 - 为String添加便捷方法和属性
//  Android类比: 类似Kotlin的String扩展函数
//

import Foundation

// MARK: - String扩展
// Android类比: 类似Kotlin的扩展函数 fun String.xxx()
extension String {

    // MARK: - 验证方法
    /// 是否为有效的邮箱格式
    // Android类比: fun String.isValidEmail(): Boolean
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    /// 是否为有效的手机号（中国）
    // Android类比: fun String.isValidPhoneNumber(): Boolean
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: self)
    }

    /// 是否只包含数字
    // Android类比: fun String.isNumeric(): Boolean
    var isNumeric: Bool {
        return Double(self) != nil
    }

    /// 是否为空或只包含空白字符
    // Android类比: fun String.isNullOrBlank(): Boolean
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - 字符串处理
    /// 截取前n个字符，超出则添加省略号
    // Android类比: fun String.truncate(length: Int): String
    func truncate(_ length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }

    /// 移除首尾空白字符
    // Android类比: String.trim() (Kotlin已有)
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 转换为首字母大写
    // Android类比: fun String.capitalize(): String
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }

    // MARK: - HTML处理
    /// 移除HTML标签
    // Android类比: 类似HtmlCompat.fromHtml().toString()
    var strippingHTML: String {
        guard let data = self.data(using: .utf8) else { return self }
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            return self
        }
    }

    // MARK: - 本地化
    /// 本地化字符串（如果需要）
    // Android类比: Context.getString(stringRes)
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// 带参数的本地化
    // Android类比: Context.getString(stringRes, args)
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }

    // MARK: - Base64编码/解码
    /// Base64编码
    // Android类比: fun String.encodeBase64(): String
    var base64Encoded: String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    /// Base64解码
    // Android类比: fun String.decodeBase64(): String?
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - URL处理
    /// 添加URL Scheme（如果没有）
    // Android类比: 类似URL处理工具
    func addingURLScheme(_ scheme: String = "https://") -> String {
        guard !isEmpty else { return self }
        if hasPrefix("http://") || hasPrefix("https://") {
            return self
        }
        return scheme + self
    }

    /// 提取URL中的域名
    // Android类比: fun Uri.host: String?
    var extractDomain: String? {
        guard let url = URL(string: self) else { return nil }
        return url.host
    }
}

// MARK: - Optional String扩展
// Android类比: 类似Kotlin的String?扩展函数
extension Optional where Wrapped == String {

    /// 是否为nil或空字符串
    // Android类比: fun String?.isNullOrEmpty(): Boolean
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }

    /// 解包或返回默认值
    // Android类比: fun String?.orEmpty(): String
    var unwrappedOrEmpty: String {
        return self ?? ""
    }
}

// MARK: - Substring扩展
// Android类比: 类似Kotlin的Substring操作
extension Substring {
    /// 转换为String
    // Android类比: Substring.toString()
    var string: String {
        return String(self)
    }
}

// MARK: - 字符串正则扩展
// Android类比: 类似Kotlin的Regex操作
extension String {
    /// 执行正则替换
    // Android类比: fun String.replace(regex: Regex, replacement: String): String
    func replacingOccurrences(of regexPattern: String, with template: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let range = NSRange(startIndex..., in: self)
            return regex.stringByReplacingMatches(in: self, range: range, withTemplate: template)
        } catch {
            return self
        }
    }

    /// 检查是否匹配正则表达式
    // Android类比: fun String.matches(regex: Regex): Boolean
    func matches(_ regexPattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let range = NSRange(startIndex..., in: self)
            return regex.firstMatch(in: self, range: range) != nil
        } catch {
            return false
        }
    }
}

// MARK: - 字符串分割辅助
// Android类比: 类似Kotlin的split操作
extension String {
    /// 分割字符串并去除空白项
    // Android类比: fun String.split(vararg delimiters: String): List<String>
    func componentsByChar(_ char: Character) -> [String] {
        return split(separator: char).map { String($0) }
    }

    /// 分割字符串并去除空白和空项
    // Android类比: 类似split后的filter操作
    func componentsByCharIgnoringEmpty(_ char: Character) -> [String] {
        return split(separator: char)
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }
    }
}
