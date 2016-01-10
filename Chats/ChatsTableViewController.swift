import UIKit

class ChatsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var chats: [Chat] { return account.chats }
    
    //EDITED
    var resultSearchController: UISearchController = UISearchController()
    
    //EDITED
    var filterUsers = [Chat]()
    
    
    convenience init() {
        self.init(style: .Plain)
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "composeAction")
        
        
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //EDITED
        self.definesPresentationContext = true
        
        
        navigationItem.leftBarButtonItem = editButtonItem() // TODO: KVO
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.rowHeight = chatTableViewCellHeight
        tableView.separatorInset.left = chatTableViewCellInsetLeft
        tableView.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ChatTableViewCell))
        
        
        //EDITED
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        self.tableView.reloadData()
        
        
    }
    
    
    
    // MARK: - UITableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //EDITED
        if self.resultSearchController.active
        {
            return self.filterUsers.count
            
        }else
        {
            
            return chats.count
            
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatTableViewCell), forIndexPath: indexPath) as! ChatTableViewCell
        
        //EDITED
        if self.resultSearchController.active{
            
            
            cell.configureWithChat(self.filterUsers[indexPath.row])
            
        }
            
        else
        {
            
            cell.configureWithChat(account.chats[indexPath.row])
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            account.chats.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if account.chats.count == 0 {
                navigationItem.leftBarButtonItem = nil  // TODO: KVO
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        //EDITED
        if self.resultSearchController.active{
            
            let chat = filterUsers[indexPath.row]
            
            dump(chat)
            let chatViewController = ChatViewController(chat: chat)
            navigationController?.pushViewController(chatViewController, animated: true)
            
            //recommended but does not work for me
            //self.resultSearchController.definesPresentationContext = true;
            //self.resultSearchController.active = false
            
        }
            
        else
        {
            
            
            let chat = chats[indexPath.row]
            dump(chat)
            let chatViewController = ChatViewController(chat: chat)
            navigationController?.pushViewController(chatViewController, animated: true)
            
            
            
        }
        
        
    }
    
    // MARK: - Actions
    
    func composeAction() {
        let navigationController = UINavigationController(rootViewController: ComposeViewController())
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    //EDITED
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.filterUsers.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "user.name beginswith[c] %@", searchController.searchBar.text!)
        
        let array = (account.chats as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filterUsers = array as! [Chat]
        
        self.tableView.reloadData()
        
        
    }
    
}
