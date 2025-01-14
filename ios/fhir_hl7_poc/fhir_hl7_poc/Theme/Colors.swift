import SwiftUI

struct AppColors {
    static let darkBlue = Color(hex: 0x001C2F)
    static let aquaBlue = Color(hex: 0x009DDE)
    static let burntOrange = Color(hex: 0xFF9900)
    static let lightBlue = Color(hex: 0xD2E8F7)
    static let white = Color.white
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }
} 