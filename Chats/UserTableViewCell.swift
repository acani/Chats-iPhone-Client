import UIKit

let userTableViewCellHeight: CGFloat = 56

class UserTableViewCell: UITableViewCell {
    let pictureImageView: UserPictureImageView
    let nameLabel: UILabel
    let usernameLabel: UILabel

    // MARK: - UITableViewCell

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let pictureSize = userTableViewCellHeight - 6
        pictureImageView = UserPictureImageView(frame: CGRect(x: 15, y: 3, width: pictureSize, height: pictureSize))

        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.autoresizingMask = .FlexibleWidth
        nameLabel.font = UIFont.systemFontOfSize(17)

        usernameLabel = UILabel(frame: CGRectZero)
        usernameLabel.autoresizingMask = .FlexibleWidth
        usernameLabel.font = UIFont.systemFontOfSize(15)
        usernameLabel.textColor = UIColor(white: 143/255, alpha: 1)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        separatorInset.left = 15 + pictureSize + 10

        nameLabel.frame = CGRect(x: 15+pictureSize+10, y: 7, width: contentView.frame.width, height: 22)
        usernameLabel.frame = CGRect(x: 15+pictureSize+10, y: 29, width: contentView.frame.width, height: 20)
        self.addSubview(pictureImageView)
        self.addSubview(nameLabel)
        self.addSubview(usernameLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
