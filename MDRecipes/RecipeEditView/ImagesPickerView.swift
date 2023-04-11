//
//  ImagesPickerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import PhotosUI
import SwiftUI

struct ImagesPickerView: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    @State private var showCamera = false
    @State private var imageData: Data?

    var body: some View {
//        List {
        
            Section("Images") {
                PhotosPicker(selection: $selectedItems, matching: .any(of: [.panoramas, .screenshots, .images])) {
                    Label("Select Photos", systemImage: "photo.stack")
                }

                Button {
                    self.showCamera = true
                } label: {
                    Label("Take Photos", systemImage: "camera")
                }
                .sheet(isPresented: $showCamera) {
                    ImageThingy(sourceType: .camera, completionHandler: { image in
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            self.imageData = data
                        }
                    })
                }
            }

            Section {
                ForEach(0..<selectedImages.count, id: \.self) { i in
                    ImageDetailView(image: selectedImages[i])
                }
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    TextField("Description", text: .constant(""))
                }
            }
//        }
        .onChange(of: selectedItems) { _ in
            Task {
                selectedImages.removeAll()

                for item in selectedItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            let image = Image(uiImage: uiImage)
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
}

struct ImageThingy: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias CompletionHandler = (UIImage) -> Void

    let sourceType: UIImagePickerController.SourceType
    let completionHandler: CompletionHandler

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completionHandler: CompletionHandler

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                completionHandler(image)
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
struct ImagesPickerView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ImagesPickerView()
        }
        
    }
}
