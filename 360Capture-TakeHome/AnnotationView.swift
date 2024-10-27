//
//  AnnotationView.swift
//  360Capture-TakeHome
//
//  Created by Steve Nimcheski on 10/23/24.
//

import SwiftUI
import PhotosUI

enum AnnotationViewAlertType {
    case imageLoadingError
    case changeTitle
}

struct AnnotationView: View {
    @EnvironmentObject var annotations: Annotations
    @Environment(\.dismiss) var dismiss
    
    @State var annotation: Annotation
    @State private var imageItem: PhotosPickerItem?
    
    @FocusState private var isEditingAnnotations: Bool
    
    // need this alert in case the image cannot be uploaded
    @State private var alertType: AnnotationViewAlertType = .imageLoadingError
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        ZStack {
            Color(red: 247.0 / 255, green: 243.0 / 255, blue: 237.0 / 255)
                .ignoresSafeArea(edges: .all)
            
            if let inputImage = annotation.inputImage {
                VStack(spacing: 13) {
                    PhotosPicker(selection: $imageItem, matching: .images) {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    TextField("Annotations/Comments", text: $annotation.annotation, axis: .vertical)
                        .focused($isEditingAnnotations)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
            } else {
                PhotosPicker("Upload Image", selection: $imageItem, matching: .images)
                    .font(.largeTitle)
            }
        }
        .tint(Color(red: 37.0 / 255, green: 95.0 / 255, blue: 1.0))
        .onChange(of: imageItem) {
            Task {
                // change alert values in case an error is thrown
                alertType = .imageLoadingError
                alertTitle = "Error Loading Image"
                alertMessage = "Sorry, there was an error loading the selected image. Please try another image instead."
                
                guard let imageData = try await imageItem?.loadTransferable(type: Data.self) else { 
                    isShowingAlert = true
                    return
                }
                
                annotation.imageData = imageData
                
                annotations.saveAnnotation(annotation)
            }
        }
        .alert(alertTitle, isPresented: $isShowingAlert) {
            if alertType == .changeTitle {
                TextField("Title", text: $annotation.title)
                
                Button("OK") {
                    // save the new title...
                    annotations.saveAnnotation(annotation)
                }
            }
        } message: {
            Text(alertMessage)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(annotation.title)
                    .font(.custom("MontserratRoman-Regular", size: 20))
                    .foregroundStyle(.white)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Rename") {
                        alertType = .changeTitle
                        alertTitle = "Rename Project"
                        alertMessage = "Please type the new name of your project below."
                        isShowingAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            
            // only show the done button if we're editing the annotation text itself
            if isEditingAnnotations {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        
                        Button("Done") {
                            // save the changes when the done button is pressed...
                            isEditingAnnotations = false
                            
                            annotations.saveAnnotation(annotation)
                        }
                    }
                    .tint(Color(red: 37.0 / 255, green: 95.0 / 255, blue: 1.0))
                }
            }
        }
        .toolbarBackground(Color(red: 0, green: 17.0 / 255, blue: 85.0 / 255), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    AnnotationView(annotation: Annotation())
}
