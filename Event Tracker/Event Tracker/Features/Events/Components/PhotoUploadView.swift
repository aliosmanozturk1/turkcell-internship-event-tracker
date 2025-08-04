import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @Binding var images: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingImagePicker = false
    @State private var draggingImage: UIImage?

    let thumbnailSize: CGFloat
    let spacing: CGFloat
    let maxPhotos: Int

    init(images: Binding<[UIImage]>, thumbnailSize: CGFloat = 100, spacing: CGFloat = 12, maxPhotos: Int = 5) {
        _images = images
        self.thumbnailSize = thumbnailSize
        self.spacing = spacing
        self.maxPhotos = maxPhotos
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(images.indices, id: \.self) { index in
                        PhotoThumbnail(image: images[index], size: thumbnailSize) {
                            images.remove(at: index)
                        }
                        .onDrag {
                            draggingImage = images[index]
                            return NSItemProvider(object: "image_\(index)" as NSString)
                        }
                        .onDrop(of: [.text], delegate: ImageDropDelegate(image: images[index], images: $images, draggingImage: $draggingImage))
                    }

                    if images.count < maxPhotos {
                        AddPhotoButton(size: thumbnailSize) {
                            showingImagePicker = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .photosPicker(isPresented: $showingImagePicker,
                      selection: $selectedItems,
                      maxSelectionCount: maxPhotos - images.count,
                      matching: .images)
        .onChange(of: selectedItems) { items in
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                selectedItems.removeAll()
            }
        }
    }
}

private struct PhotoThumbnail: View {
    let image: UIImage
    let size: CGFloat
    var onDelete: () -> Void

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
            }
            .padding(4)
        }
    }
}

private struct AddPhotoButton: View {
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

private struct ImageDropDelegate: DropDelegate {
    let image: UIImage
    @Binding var images: [UIImage]
    @Binding var draggingImage: UIImage?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        guard let dragging = draggingImage,
              dragging !== image,
              let from = images.firstIndex(where: { $0 === dragging }),
              let to = images.firstIndex(where: { $0 === image }) else { return }

        withAnimation(.easeInOut) {
            images.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingImage = nil
        return true
    }
}

