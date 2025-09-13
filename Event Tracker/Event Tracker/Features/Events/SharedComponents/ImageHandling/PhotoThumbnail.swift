import SwiftUI

struct PhotoThumbnail: View {
    let image: UIImage
    let size: CGFloat
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
                .cornerRadius(8)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.7)))
                    .font(.system(size: max(12, size * 0.15)))
            }
            .padding(4)
        }
    }
}