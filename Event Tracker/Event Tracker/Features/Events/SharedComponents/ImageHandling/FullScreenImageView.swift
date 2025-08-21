import SwiftUI

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZoomableImageView(
            image: image,
            onDismiss: { dismiss() }
        )
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}