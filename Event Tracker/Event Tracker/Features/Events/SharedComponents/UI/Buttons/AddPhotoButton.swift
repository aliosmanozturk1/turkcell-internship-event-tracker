import SwiftUI

struct AddPhotoButton: View {
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: size * 0.05) {
                Image(systemName: "plus")
                    .font(.system(size: size * 0.25, weight: .light))
                    .foregroundColor(.gray)
                Text("Fotoğraf\nEkle")
                    .font(.system(size: size * 0.12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}