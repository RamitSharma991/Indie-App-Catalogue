//
//  DataController.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "TechFizzModel")
    
    init() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
