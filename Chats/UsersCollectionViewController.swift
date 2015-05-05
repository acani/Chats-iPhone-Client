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

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
//        collectionView?.alwaysBounceHorizontal = true
        collectionView!.registerClass(UserCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(UserCollectionViewCell))
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.users.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(UserCollectionViewCell), forIndexPath: indexPath) as! UserCollectionViewCell
        let user = account.users[indexPath.item]
        cell.nameLabel.text = user.name
        (cell.backgroundView as! UIImageView).image = UIImage(named: user.pictureName())
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = account.users[indexPath.item]
        let chat = Chat(user: user, lastMessageText: "", lastMessageSentDate: NSDate()) // TODO: Pass nil for text & date
        let chatViewController = ChatViewController(chat: chat)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
