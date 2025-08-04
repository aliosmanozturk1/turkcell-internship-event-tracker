import SwiftUI
import PhotosUI

struct PhotoUploadView: View {
    @Binding var selectedImages: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var draggingImage: UIImage?
    @State private var showingViewer = false
    @State private var viewerIndex = 0

    let thumbnailSize: CGFloat
    let spacing: CGFloat
    let maxPhotos: Int

    init(selectedImages: Binding<[UIImage]>, thumbnailSize: CGFloat = 100, spacing: CGFloat = 12, maxPhotos: Int = 5) {
        self._selectedImages = selectedImages
        self.thumbnailSize = thumbnailSize
        self.spacing = spacing
        self.maxPhotos = maxPhotos
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text("Fotoğraflar (\(selectedImages.count)/\(maxPhotos))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        PhotoThumbnail(
                            image: selectedImages[index],
                            size: thumbnailSize,
                            onDelete: {
                                selectedImages.remove(at: index)
                            }
                        )
                        .onTapGesture {
                            viewerIndex = index
                            showingViewer = true
                        }
                        .onDrag {
                            draggingImage = selectedImages[index]
                            return NSItemProvider(object: "image_\(index)" as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: ImageDropDelegate(
                                image: selectedImages[index],
                                images: $selectedImages,
                                draggingImage: $draggingImage
                            )
                        )
                    }

                    if selectedImages.count < maxPhotos {
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: maxPhotos - selectedImages.count,
                            matching: .images
                        ) {
                            AddPhotoButton(size: thumbnailSize) {}
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: selectedItems) { items in
            Task {
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
                selectedItems.removeAll()
            }
        }
        .fullScreenCover(isPresented: $showingViewer) {
            ImageViewer(images: selectedImages, index: $viewerIndex)
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
        guard
            let dragging = draggingImage,
            dragging !== image,
            let from = images.firstIndex(where: { $0 === dragging }),
            let to = images.firstIndex(where: { $0 === image })
        else { return }

        withAnimation(.easeInOut) {
            images.move(
                fromOffsets: IndexSet(integer: from),
                toOffset: to > from ? to + 1 : to
            )
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingImage = nil
        return true
    }
}

// MARK: - Full Screen Viewer

struct ImageViewer: View {
    let images: [UIImage]
    @Binding var index: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $index) {
                ForEach(images.indices, id: \.self) { i in
                    ZoomableScrollView(image: images[i])
                        .tag(i)
                        .background(Color.black)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(Color.black)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 200 {
                    dismiss()
                }
            }
        )
    }
}

struct ZoomableScrollView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = context.coordinator

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    }
}

