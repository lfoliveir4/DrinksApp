import UIKit
import CoreData

class MainViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dataController: DataController!
    var activityIndicator: UIActivityIndicatorView?

    let cellIdentifier = "cell"
    var fetchResultController: NSFetchedResultsController<DrinksData>!
    var drinks = [DrinksData]()

    // MARK: Lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(DrinksTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        showActivityIndicator()
        getDrinks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }

    // MARK: Table View Funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drinksData = fetchResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DrinksTableViewCell
        cell.titleDrink.text = drinksData.strDrink
        if let imageData = drinksData.data {
            cell.imageDrink.image = UIImage(data: imageData)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cliquei no item \(indexPath.row)")
    }

    // MARK: - Private Funcs
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<DrinksData> = DrinksData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "strDrink", ascending: true)

        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchResultController.delegate = self

        do {
            try? fetchResultController.performFetch()
        } catch {
            print("no fetch data \(error.localizedDescription)")
        }
    }

    private func getDrinks() {
        NetworkManager.shared.getDrinks { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.deleteData()
                for item in response {

                    let drinksData = DrinksData(context: self.dataController.viewContext)

                    drinksData.strDrink = item.strDrink
                    drinksData.strDrinkThumb = item.strDrinkThumb
                    drinksData.idDrink = item.idDrink

                    guard let imageURL = URL(string: item.strDrinkThumb) else { return }
                    guard let imageData = try? Data(contentsOf: imageURL) else { return }

                    drinksData.data = imageData
                    try? self.dataController.viewContext.save()
                }
            case .failure(let error):
                print("error: \(error)")
            }

            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.tableView.reloadData()
            }
        }
    }

    private func deleteData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = DrinksData.fetchRequest()

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        do {
            let context = dataController.viewContext
            let result = try context.execute(deleteRequest)

            guard let deleteResult = result as? NSBatchDeleteResult,
                  let ids = deleteResult.result as? [NSManagedObjectID] else {
                return
             }

            let changes = [NSDeletedObjectsKey: ids]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        } catch {
            print("error on delete storage: \(error.localizedDescription)")
        }

        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    private func showActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        guard let activityIndicator = activityIndicator else { return }

        self.view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 70),
            activityIndicator.heightAnchor.constraint(equalToConstant: 70),
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        guard let activityIndicator = activityIndicator else { return }

        activityIndicator.stopAnimating()
    }
}

extension MainViewController {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if newIndexPath != nil {
                tableView.insertRows(at: [newIndexPath!], with: .none)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            break;
        case .move, .update:
            break;
        }
    }
}
