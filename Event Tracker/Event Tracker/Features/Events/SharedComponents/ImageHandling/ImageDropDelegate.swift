import SwiftUI

struct ImageDropDelegate: DropDelegate {
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