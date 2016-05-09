import UIKit
import Networking

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
        collectionView!.backgroundColor = .whiteColor()
        collectionView!.registerClass(UserCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UserCollectionViewCell))
        account.addObserver(self, forKeyPath: "users", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
        if account.accessToken == "guest_access_token" { return }
        getUsers()
    }

    func getUsers() -> NSURLSessionDataTask {
        var accountUserName: (first: String, last: String)?
        var users = [User]()

        let request = api.request("GET", "/users")
        let dataTask = Net.dataTaskWithRequest(request, self, loadingViewType: .View,
            backgroundSuccessHandler: { JSONObject in
                for item in JSONObject as! Array<Dictionary<String, AnyObject>> {
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
            }, mainSuccessHandler: { _ in
                if let accountUserName = accountUserName {
                    account.user.firstName = accountUserName.first
                    account.user.lastName = accountUserName.last
                }
                account.users = users
            })
        dataTask.resume()
        return dataTask
    }

    // MARK: - NSKeyValueObserving

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        collectionView!.reloadData()
    }

    // MARK: - UICollectionViewDataSource

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

    // MARK: - UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = account.users[indexPath.item]
        navigationController!.pushViewController(ProfileTableViewController(user: user), animated: true)
    }
}
