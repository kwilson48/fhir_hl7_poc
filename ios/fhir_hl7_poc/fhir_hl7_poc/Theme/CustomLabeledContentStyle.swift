import SwiftUI

struct CustomLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(AppTypography.labelText)
                .foregroundColor(AppColors.darkBlue)
            configuration.content
                .font(AppTypography.bodyText)
                .foregroundColor(.secondary)
        }
    }
} 