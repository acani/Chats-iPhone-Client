import UIKit

class SearchViewController: UIViewController {
    var searchController: UISearchController!

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Search"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()

        let noticeLabel = UILabel(frame: CGRectZero)
        noticeLabel.numberOfLines = 2
        noticeLabel.text = "Search for users by name or username."
        noticeLabel.textAlignment = .Center
        view.addSubview(noticeLabel)
        noticeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: noticeLabel, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: noticeLabel, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: noticeLabel, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: -20)
        ])

        let searchResultsTableViewController = SearchResultsTableViewController(style: .Plain)
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        searchController.searchResultsUpdater = searchResultsTableViewController

        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.searchBarStyle = .Minimal

        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false

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
                visibleResults = account.users.filter() { user in
                    return (user.name + " " + user.username).matchesFilterString(filterString!)
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
        let cellIdentifier = "UserCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
            cell.textLabel!.font = UIFont.systemFontOfSize(18)
        }

        let user = visibleResults[indexPath.row]
        let imageView = cell.imageView!
        if let pictureName = user.pictureName() {
            imageView.image = UIImage(named: pictureName)
            // imageView.layer.cornerRadius = imageView.frame.width / 2
            // imageView.layer.masksToBounds = true
        } else {
            imageView.image = nil
        }
        cell.textLabel!.text = user.name
        cell.detailTextLabel!.text = user.username

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = visibleResults[indexPath.row]
        presentingViewController!.navigationController!.pushViewController(ProfileTableViewController(user: user), animated: true)
    }

    // MARK: - UISearchResultsUpdating

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard searchController.active else { return }
        filterString = searchController.searchBar.text
    }
}

extension String {
    func words() -> Array<String> {
        var words = [String]()
        let nonAlphanumericCharacterSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let scanner = NSScanner(string: self)
        scanner.charactersToBeSkipped = nonAlphanumericCharacterSet
        var result: NSString?
        while scanner.scanUpToCharactersFromSet(nonAlphanumericCharacterSet, intoString: &result) {
            words.append(result as! String)
        }
        return words
        // // The following implementation is twice as slow than the one above.
        // return componentsSeparatedByCharactersInSet(nonAlphanumericCharacterSet).filter { $0 != "" }
    }

    //  http://stackoverflow.com/a/29006884/242933
    // let filterPredicate = NSPredicate(format: "self contains[c] %@", argumentArray: [filterString!])
    // visibleResults = account.users.filter { filterPredicate.evaluateWithObject($0) }
    func matchesFilterString(filterString: String) -> Bool {
        for filterWord in filterString.words() {
            func wordsHasMatch() -> Bool {
                for word in words() {
                    if word.hasCDWPrefix(filterWord) {
                        return true
                    }
                }
                return false
            }
            if !wordsHasMatch() { return false }
        }
        return true
    }

    func hasCDWPrefix(prefix: String) -> Bool {
        let options: NSStringCompareOptions = [.AnchoredSearch, .CaseInsensitiveSearch, .DiacriticInsensitiveSearch, .WidthInsensitiveSearch]
        return rangeOfString(prefix, options: options) != nil
    }
}
