import Foundation
import CoreData

public final class DataController {
    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }

    func loadCoreData(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                print("Ocorreu um erro no core data: \(String(describing: error?.localizedDescription))")
                return
            }

            completion?()
        }
    }
}
