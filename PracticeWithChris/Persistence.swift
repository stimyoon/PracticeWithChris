//
//  Persistence.swift
//  CloudKitExample
//
//  Created by Tim Yoon on 5/10/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    let context : NSManagedObjectContext

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "CoreDataModel")
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        context = container.viewContext
    }
    func save(){
        do{
            try container.viewContext.save()
        }catch let error {
            print("Error saving Core Data. \(error.localizedDescription)")
        }
    }
}
