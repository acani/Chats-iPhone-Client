import UIKit

let incomingTag = 0, outgoingTag = 1
let bubbleTag = 8

class MessageBubbleTableViewCell: UITableViewCell {
    let bubbleImageView: UIImageView
    static let bubbleImage: (incoming: UIImage, incomingHighlighed: UIImage, outgoing: UIImage, outgoingHighlighed: UIImage) = {
        let maskOutgoing = UIImage(named: "MessageBubble")!
        let maskIncoming = UIImage(CGImage: maskOutgoing.CGImage!, scale: 2, orientation: .UpMirrored)

        let capInsetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
        let capInsetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)

        let incoming = maskIncoming.imageWithRed(229/255, green: 229/255, blue: 234/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let incomingHighlighted = maskIncoming.imageWithRed(206/255, green: 206/255, blue: 210/255, alpha: 1).resizableImageWithCapInsets(capInsetsIncoming)
        let outgoing = maskOutgoing.imageWithRed(43/255, green: 119/255, blue: 250/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)
        let outgoingHighlighted = maskOutgoing.imageWithRed(32/255, green: 96/255, blue: 200/255, alpha: 1).resizableImageWithCapInsets(capInsetsOutgoing)

        return (incoming, incomingHighlighted, outgoing, outgoingHighlighted)
    }()
    let messageLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        bubbleImageView = UIImageView(image: MessageBubbleTableViewCell.bubbleImage.incoming, highlightedImage: MessageBubbleTableViewCell.bubbleImage.incomingHighlighed)
        bubbleImageView.tag = bubbleTag
        bubbleImageView.userInteractionEnabled = true // #CopyMesage

        messageLabel = UILabel(frame: CGRectZero)
        messageLabel.font = UIFont.systemFontOfSize(ChatViewController.chatMessageFontSize)
        messageLabel.numberOfLines = 0
        messageLabel.userInteractionEnabled = false   // #CopyMessage

        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None

        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)

        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 4.5))
        bubbleImageView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .Width, relatedBy: .Equal, toItem: messageLabel, attribute: .Width, multiplier: 1, constant: 30))
        contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -4.5))

        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .CenterX, relatedBy: .Equal, toItem: bubbleImageView, attribute: .CenterX, multiplier: 1, constant: 3))
        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: bubbleImageView, attribute: .CenterY, multiplier: 1, constant: -0.5))
        messageLabel.preferredMaxLayoutWidth = 218
        bubbleImageView.addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .Height, relatedBy: .Equal, toItem: bubbleImageView, attribute: .Height, multiplier: 1, constant: -15))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithMessage(message: Message) {
        messageLabel.text = message.text

        if message.incoming != (tag == incomingTag) {
            var layoutAttribute: NSLayoutAttribute
            var layoutConstant: CGFloat

            if message.incoming {
                tag = incomingTag
                bubbleImageView.image = MessageBubbleTableViewCell.bubbleImage.incoming
                bubbleImageView.highlightedImage = MessageBubbleTableViewCell.bubbleImage.incomingHighlighed
                messageLabel.textColor = .blackColor()
                layoutAttribute = .Left
                layoutConstant = 10
            } else { // outgoing
                tag = outgoingTag
                bubbleImageView.image = MessageBubbleTableViewCell.bubbleImage.outgoing
                bubbleImageView.highlightedImage = MessageBubbleTableViewCell.bubbleImage.outgoingHighlighed
                messageLabel.textColor = .whiteColor()
                layoutAttribute = .Right
                layoutConstant = -10
            }

            let layoutConstraint: NSLayoutConstraint = bubbleImageView.constraints[1] // `messageLabel` CenterX
            layoutConstraint.constant = -layoutConstraint.constant

            let constraints: NSArray = contentView.constraints
            let indexOfConstraint = constraints.indexOfObjectPassingTest { constraint, idx, stop in
                return (constraint.firstItem as! UIView).tag == bubbleTag && (constraint.firstAttribute == NSLayoutAttribute.Left || constraint.firstAttribute == NSLayoutAttribute.Right)
            }
            contentView.removeConstraint(constraints[indexOfConstraint] as! NSLayoutConstraint)
            contentView.addConstraint(NSLayoutConstraint(item: bubbleImageView, attribute: layoutAttribute, relatedBy: .Equal, toItem: contentView, attribute: layoutAttribute, multiplier: 1, constant: layoutConstant))
        }
    }

    // Highlight cell #CopyMessage
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleImageView.highlighted = selected
    }
}

extension UIImage {
    func imageWithRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        self.drawInRect(rect)
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        CGContextFillRect(context, rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}