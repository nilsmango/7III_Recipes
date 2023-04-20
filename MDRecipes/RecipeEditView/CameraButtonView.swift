//
//  CameraButtonView.swift
//  MDRecipes
//
//  Created by Simon Lang on 20.04.23.
//

import SwiftUI

struct CameraButtonView: View {
    @Binding var showCamera: Bool
    @Binding var dataImages: [RecipeImageData]
    
    var body: some View {
        Button {
            self.showCamera = true
        } label: {
            Label("Take a Photo", systemImage: "camera")
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                dataImages.append(RecipeImageData(image: image, caption: "", isOldImage: false))
                showCamera = false
            }
            .ignoresSafeArea()
            .background(.black)
        }
    }
}
private struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias UIImageType = UIImage
    
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImageType) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        imagePicker.modalPresentationStyle = .fullScreen
        return imagePicker
    }
    class CustomImagePickerController: UIImagePickerController {
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait]
        }
    }
    
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // no-op
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onImagePicked: (UIImageType) -> Void
        
        init(onImagePicked: @escaping (UIImageType) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImageType {
                onImagePicked(image)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}


struct CameraButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CameraButtonView(showCamera: .constant(false), dataImages: .constant([]))
    }
}
