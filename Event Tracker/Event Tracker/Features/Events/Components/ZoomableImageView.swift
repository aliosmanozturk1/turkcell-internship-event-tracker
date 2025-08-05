import SwiftUI

struct ZoomableImageView: View {
    let image: UIImage
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastOffset: CGSize = .zero
    @State private var isDraggingToClose: Bool = false
    
    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .onTapGesture(count: 2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        if scale > minScale {
                            // Zoom out
                            scale = minScale
                            offset = .zero
                            lastScale = minScale
                            lastOffset = .zero
                        } else {
                            // Zoom in
                            scale = 2.0
                            lastScale = 2.0
                        }
                    }
                }
                .simultaneousGesture(
                    // Optimized magnification gesture
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(lastScale * value, minScale), maxScale)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            
                            // Snap to minimum if close
                            if scale <= minScale + 0.1 {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    scale = minScale
                                    offset = .zero
                                    lastScale = minScale
                                    lastOffset = .zero
                                }
                            } else {
                                // Constrain offset smoothly
                                let constrainedOffset = constrainOffset(offset, for: geometry)
                                if constrainedOffset != offset {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        offset = constrainedOffset
                                        lastOffset = constrainedOffset
                                    }
                                } else {
                                    lastOffset = offset
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    // Optimized drag gesture - Hızlı response
                    DragGesture()
                        .onChanged { value in
                            if scale > minScale {
                                // Zoomed in - allow free movement
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            } else {
                                // Not zoomed - only vertical drag for dismiss
                                if value.translation.height > 0 {
                                    isDraggingToClose = true
                                    offset = CGSize(width: 0, height: value.translation.height * 0.5) // Resistance effect
                                }
                            }
                        }
                        .onEnded { value in
                            if scale > minScale {
                                // Zoomed state - constrain and save offset
                                offset = constrainOffset(offset, for: geometry)
                                lastOffset = offset
                            } else {
                                // Check for dismiss
                                if isDraggingToClose && value.translation.height > 80 {
                                    onDismiss()
                                } else {
                                    // Quick snap back
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        offset = .zero
                                    }
                                    lastOffset = .zero
                                }
                                isDraggingToClose = false
                            }
                        }
                )
        }
    }
    
    // Optimized offset constraining
    private func constrainOffset(_ proposedOffset: CGSize, for geometry: GeometryProxy) -> CGSize {
        guard scale > minScale else { return .zero }
        
        // Quick calculation - avoid complex geometry
        let scaledWidth = geometry.size.width * scale
        let scaledHeight = geometry.size.height * scale
        
        let maxX = max(0, (scaledWidth - geometry.size.width) / 2)
        let maxY = max(0, (scaledHeight - geometry.size.height) / 2)
        
        return CGSize(
            width: max(-maxX, min(maxX, proposedOffset.width)),
            height: max(-maxY, min(maxY, proposedOffset.height))
        )
    }
}