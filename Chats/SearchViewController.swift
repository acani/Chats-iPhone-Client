import UIKit

class SearchViewController: UIViewController {
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let noticeLabel = UILabel(frame: CGRectZero)
        noticeLabel.numberOfLines = 2
        noticeLabel.text = "Search for users by name, email, or username."
        noticeLabel.textAlignment = .Center
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: noticeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: noticeLabel, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: noticeLabel, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: -20)
        ])

        let searchResultsTableViewController = SearchResultsTableViewController(style: .Plain)
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        searchController.searchResultsUpdater = searchResultsTableViewController

        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .Minimal

        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar

        definesPresentationContext = true
    }
}

class SearchResultsTableViewController: UITableViewController, UISearchResultsUpdating {
    var visibleResults = account.users

    /// A `nil` / empty filter string means show all results. Otherwise, show only results containing the filter.
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.isEmpty {
                visibleResults.removeAll()
            } else {
//                let filterPredicate = NSPredicate(format: "self contains[c] %@", argumentArray: [filterString!])
//                visibleResults = account.users.filter { filterPredicate.evaluateWithObject($0) }

                visibleResults = account.users.filter() { user in
                    return (user.firstName.hasPrefix(filterString!) ||
                        user.lastName.hasPrefix(filterString!) ||
                        user.username.hasPrefix(filterString!))
                }

            }
            tableView.reloadData()
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleResults.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue or create cell with style & identifier
        let identifier = "reuseIdentifier"
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: identifier)
            cell.textLabel?.font = UIFont.systemFontOfSize(18)
        }

        // Customize cell
        let user = visibleResults[indexPath.row]
        cell.textLabel!.text = user.name
        cell.detailTextLabel!.text = user.username

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = visibleResults[indexPath.item]
        presentingViewController!.navigationController!.pushViewController(ProfileTableViewController(user: user), animated: true)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard searchController.active else { return }
        filterString = searchController.searchBar.text
    }
}
