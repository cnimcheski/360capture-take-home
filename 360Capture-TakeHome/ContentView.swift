//
//  ContentView.swift
//  360Capture-TakeHome
//
//  Created by Steve Nimcheski on 10/22/24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var annotations = Annotations()
    @State var path = NavigationPath()
    @State var newAnnotationTitle = ""
    
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 247.0 / 255, green: 243.0 / 255, blue: 237.0 / 255)
                    .ignoresSafeArea(edges: .all)
                
                if annotations.annotations.isEmpty {
                    Text("Create your first annotation project!")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                } else {
                    List {
                        ForEach(annotations.annotations) { annotation in
                            NavigationLink(value: annotation) {
                                Text(annotation.title)
                                    .font(.headline)
                            }
                            .padding(10)
                        }
                        .onDelete(perform: annotations.removeRows)
                    }
                    .listStyle(.plain)
                }
            }
            .alert("New Annotation", isPresented: $isShowingAlert) {
                TextField("Title", text: $newAnnotationTitle)
                    .onChange(of: newAnnotationTitle) { _, new in
                        print(new)
                    }
                
                Button("Continue") {
                    // need to programmatically show the new annotation so that title is applied
                    path.append(Annotation(title: newAnnotationTitle.isEmpty ? "Untitled" : newAnnotationTitle))
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please provide a title for your new annotation project.")
            }
            .navigationDestination(for: Annotation.self) { annotation in
                AnnotationView(annotation: annotation)
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("360capture")
                        .font(.custom("MontserratRoman-Regular", size: 20))
                        .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAlert = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color(red: 247.0 / 255, green: 243.0 / 255, blue: 237.0 / 255))
                    }
                }
            }
            // adding navigation bar color
            // converted from hex to rgb between 0-255, divide by 255 to get swift 0-1 Color values
            .toolbarBackground(Color(red: 0, green: 17.0 / 255, blue: 85.0 / 255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .environmentObject(annotations)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
