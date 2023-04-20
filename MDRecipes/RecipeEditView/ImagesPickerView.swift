//
//  ImagesPickerView.swift
//  MDRecipes
//
//  Created by Simon Lang on 11.04.23.
//

import PhotosUI
import SwiftUI

struct ImagesPickerView: View {
    
    // Images
    @Binding var dataImages: [RecipeImageData]
    
    
    // Pickers
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var showCamera = false
    
    

    var body: some View {
        if dataImages.count > 0 {
        Section("Images") {
            
                ForEach(dataImages) { image in
                    ImageDetailView(image: Image(uiImage: image.image), caption: dataBinding(for: image).caption)
                }
                .onDelete { indexSet in
                    dataImages.remove(atOffsets: indexSet)
                }
                
                .onMove { indexSet, newPlace in
                    dataImages.move(fromOffsets: indexSet, toOffset: newPlace)
                }
            }
        
                Section {
                    PhotosPicker(selection: $selectedItems, matching: .any(of: [.panoramas, .screenshots, .images])) {
                        Label("Select Photos from Library", systemImage: "photo.stack")
                    }
                    
                    CameraButtonView(showCamera: $showCamera, dataImages: $dataImages)
                    
                    .onChange(of: selectedItems) { _ in
                        Task {
                            for item in selectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    if let uiImage = UIImage(data: data) {
                                        dataImages.append(RecipeImageData(image: uiImage, caption: "", isOldImage: false))
                                    }
                                }
                            }
                            selectedItems.removeAll()
                        }
                    }
                    
                }
        } else {
            Section("Add Images") {
                PhotosPicker(selection: $selectedItems, matching: .any(of: [.panoramas, .screenshots, .images])) {
                    Label("Select Photos from Library", systemImage: "photo.stack")
                }
                
                CameraButtonView(showCamera: $showCamera, dataImages: $dataImages)
                
            }
            .onChange(of: selectedItems) { _ in
                Task {
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                dataImages.append(RecipeImageData(image: uiImage, caption: "", isOldImage: false))
                            }
                        }
                    }
                    selectedItems.removeAll()
                }
            }
        }
           
    
        
    }
    
    
    
 
   
    private func dataBinding(for image: RecipeImageData) -> Binding<RecipeImageData> {
        guard let imageIndex = dataImages.firstIndex(where:  { $0.image == image.image }) else {
            fatalError("Can't find the stupid DATA IMAGE in array")
        }
        return $dataImages[imageIndex]
    }
}



struct ImagesPickerView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ImagesPickerView(dataImages: .constant([RecipeImageData(image: UIImage(contentsOfFile: "example.png") ?? UIImage(systemName: "lasso.and.sparkles")!, caption: "Just an example", isOldImage: true)]))
        }
        
    }
}
