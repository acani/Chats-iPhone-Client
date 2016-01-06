import UIKit

class UsersCollectionViewController: UICollectionViewController {
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: userCollectionViewCellHeight, height: userCollectionViewCellHeight)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 0)
        self.init(collectionViewLayout: layout)
        title = "Users"
    }

    deinit {
        if isViewLoaded() {
            account.removeObserver(self, forKeyPath: "users")
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.alwaysBounceVertical = true
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerClass(UserCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UserCollectionViewCell))
        account.addObserver(self, forKeyPath: "users", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

        if account.accessToken != "guest_access_token" {
            getUsers()
        }
    }

    func getUsers() -> NSURLSessionDataTask {
        let loadingView = LoadingView()
        loadingView.showInViewController(self)

        let request = NSMutableURLRequest(URL: api.URLWithPath("/users"))
        request.setValue("Bearer "+account.accessToken, forHTTPHeaderField: "Authorization")
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if response != nil {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                let collection: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))

                var accountUserName: (first: String, last: String)?
                var users = [User]()
                if statusCode == 200 {
                    for item in collection as! Array<Dictionary<String, AnyObject>> {
                        let ID = item["id"] as! UInt
                        let name = item["name"] as! Dictionary<String, String>
                        let firstName = name["first"]!
                        let lastName = name["last"]!

                        if ID == account.user.ID {
                            accountUserName = (firstName, lastName)
                        } else {
                            let user = User(ID: ID, username: "", firstName: firstName, lastName: lastName)
                            users.append(user)
                        }
                    }
                }

                dispatch_async(dispatch_get_main_queue(), {
                    loadingView.dismissAnimated(true)
                    if statusCode == 200 {
                        if let accountUserName = accountUserName {
                            account.user.firstName = accountUserName.first
                            account.user.lastName = accountUserName.last
                        }
                        account.users = users
                    } else {
                        let alert = UIAlertController(dictionary: (collection as! Dictionary), error: error, handler: nil)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    loadingView.dismissAnimated(true)
                    let alert = UIAlertController(dictionary: nil, error: error, handler: nil)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        })
        dataTask.resume()
        return dataTask
    }

    // MARK: - NSKeyValueObserving

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        collectionView!.reloadData()
    }

    // MARK: - UICollectionView

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.users.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(UserCollectionViewCell), forIndexPath: indexPath) as! UserCollectionViewCell
        let user = account.users[indexPath.item]
        cell.nameLabel.text = user.name
        if let pictureName = user.pictureName() {
            (cell.backgroundView as! UIImageView).image = UIImage(named: pictureName)
        } else {
            (cell.backgroundView as! UIImageView).image = nil
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = account.users[indexPath.item]
        navigationController?.pushViewController(ProfileTableViewController(user: user), animated: true)
    }
}
