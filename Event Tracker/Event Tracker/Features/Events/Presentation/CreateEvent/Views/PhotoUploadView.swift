import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @Binding var images: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var draggingImage: UIImage?
    @State private var previewIndex: Int?
    @State private var showingImagePicker = false
    
    let thumbnailSize: CGFloat
    let spacing: CGFloat
    let showTitle: Bool
    let maxPhotos: Int
    
    init(images: Binding<[UIImage]>, thumbnailSize: CGFloat = 100, spacing: CGFloat = 12, showTitle: Bool = true, maxPhotos: Int = 5) {
        self._images = images
        self.thumbnailSize = thumbnailSize
        self.spacing = spacing
        self.showTitle = showTitle
        self.maxPhotos = maxPhotos
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if showTitle {
                Text("Fotoğraflar (\(images.count)/\(maxPhotos))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(images.indices, id: \.self) { index in
                        PhotoThumbnail(image: images[index], size: thumbnailSize) {
                            images.remove(at: index)
                        }
                        .onTapGesture { previewIndex = index }
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
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItems, maxSelectionCount: maxPhotos - images.count, matching: .images)
        .onChange(of: selectedItems) { _, items in
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
        .fullScreenCover(isPresented: Binding(get: { previewIndex != nil }, set: { if !$0 { previewIndex = nil } })) {
            if let index = previewIndex {
                FullScreenImageView(image: images[index])
            }
        }
    }
}

