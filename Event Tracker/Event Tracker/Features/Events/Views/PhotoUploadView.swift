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
        .fullScreenCover(isPresented: Binding(get: { previewIndex != nil }, set: { if !$0 { previewIndex = nil } })) {
            if let index = previewIndex {
                FullScreenImageView(image: images[index])
            }
        }
    }
}

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

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZoomableScrollView(image: image)
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
            .gesture(DragGesture().onEnded { value in
                if value.translation.height > 100 { dismiss() }
            })
    }
}

struct ZoomableScrollView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.delegate = context.coordinator
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = UIScreen.main.bounds
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // no-op
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }
    }
}
