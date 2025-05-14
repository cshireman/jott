//
//  ModelContainerHelper.swift
//  Jott
//
//  Created by Chris Shireman on 5/14/25.
//

import Foundation
import SwiftData

@MainActor
final class ModelContainerHelper {
    static let shared = ModelContainerHelper()
    
    var container: ModelContainer {
        do {
            let schema = Schema([Note.self, Category.self, Tag.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
