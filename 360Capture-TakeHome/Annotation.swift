//
//  Annotation.swift
//  360Capture-TakeHome
//
//  Created by Steve Nimcheski on 10/23/24.
//

import SwiftUI

struct Annotation: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var annotation: String
    var imageData: Data?
    
    var inputImage: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    init(id: UUID = UUID(), title: String = "", annotation: String = "", imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.annotation = annotation
        self.imageData = imageData
    }
}

@MainActor class Annotations: ObservableObject {
    @Published var annotations: [Annotation] = []
    
    let savePath = URL.documentsDirectory.appending(path: "annotations")
    
    func saveAnnotation(_ annotation: Annotation) {
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            // update existing annotation
            annotations.remove(at: index)
        }
        
        annotations.insert(annotation, at: 0)
        
        // save the new annotations array to documents directory for persistent storage
        save()
    }
    
    func removeRows(at offsets: IndexSet) {
        annotations.remove(atOffsets: offsets)
        
        // save the new annotations list to documents directory for persistent storage
        save()
    }
    
    func save() {
        do {
            let encoded = try JSONEncoder().encode(annotations)
            try encoded.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save annotations...")
        }
    }
    
    init() {
        // grab the annotations from documents directory...
        do {
            let data = try Data(contentsOf: savePath)
            annotations = try JSONDecoder().decode([Annotation].self, from: data)
        } catch {
            annotations = []
        }
    }
}
