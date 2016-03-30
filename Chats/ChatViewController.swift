import AudioToolbox
import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    static let chatMessageFontSize: CGFloat = 17
    private static let toolBarMinHeight: CGFloat = 44
    private static let textViewMaxHeight: (portrait: CGFloat, landscape: CGFloat) = (portrait: 272, landscape: 90)
    private static let messageSoundOutgoing: SystemSoundID = {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "MessageOutgoing", "aiff", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }()

    let chat: Chat
    var tableView: UITableView!
    var toolBar: UIToolbar!
    var textView: UITextView!
    var sendButton: UIButton!
    var rotating = false

    override var inputAccessoryView: UIView! {
        get {
            if toolBar == nil {
                toolBar = UIToolbar(frame: CGRectMake(0, 0, 0, ChatViewController.toolBarMinHeight-0.5))

                textView = InputTextView(frame: CGRectZero)
                textView.backgroundColor = UIColor(white: 250/255, alpha: 1)
                textView.delegate = self
                textView.font = UIFont.systemFontOfSize(ChatViewController.chatMessageFontSize)
                textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
                textView.layer.borderWidth = 0.5
                textView.layer.cornerRadius = 5
                //            textView.placeholder = "Message"
                textView.scrollsToTop = false
                textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
                toolBar.addSubview(textView)

                sendButton = UIButton(type: .System)
                sendButton.enabled = false
                sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
                sendButton.setTitle("Send", forState: .Normal)
                sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
                sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), forState: .Normal)
                sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
                sendButton.addTarget(self, action: #selector(ChatViewController.sendMessageAction), forControlEvents: UIControlEvents.TouchUpInside)
                toolBar.addSubview(sendButton)

                // Auto Layout allows `sendButton` to change width, e.g., for localization.
                textView.translatesAutoresizingMaskIntoConstraints = false
                sendButton.translatesAutoresizingMaskIntoConstraints = false
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: toolBar, attribute: .Left, multiplier: 1, constant: 8))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: toolBar, attribute: .Top, multiplier: 1, constant: 7.5))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: sendButton, attribute: .Left, multiplier: 1, constant: -2))
                toolBar.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -8))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Right, relatedBy: .Equal, toItem: toolBar, attribute: .Right, multiplier: 1, constant: 0))
                toolBar.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -4.5))
            }
            return toolBar
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
        title = chat.user.name
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIResponder

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor() // smooths push animation

        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: ChatViewController.toolBarMinHeight, right: 0)
        tableView.contentInset = edgeInsets
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .Interactive
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .None
        tableView.registerClass(MessageSentDateTableViewCell.self, forCellReuseIdentifier: "SentDateCell")
        view.addSubview(tableView)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ChatViewController.menuControllerWillHide(_:)), name: UIMenuControllerWillHideMenuNotification, object: nil) // #CopyMessage

        // tableViewScrollToBottomAnimated(false) // doesn't work
    }

    override func viewDidAppear(animated: Bool)  {
        super.viewDidAppear(animated)
        tableView.flashScrollIndicators()
    }

    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        chat.draft = textView.text
    }

    // This gets called a lot. Perhaps there's a better way to know when `view.window` has been set?
    override func viewDidLayoutSubviews()  {
        super.viewDidLayoutSubviews()

        if !chat.draft.isEmpty {
            textView.text = chat.draft
            chat.draft = ""
            textViewDidChange(textView)
            textView.becomeFirstResponder()
        }
    }

//    // #iOS7.1
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)

        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            if toolBar.frame.height > ChatViewController.textViewMaxHeight.landscape {
                toolBar.frame.size.height = ChatViewController.textViewMaxHeight.landscape+8*2-0.5
            }
        } else { // portrait
            updateTextViewHeight()
        }
    }
//    // #iOS8
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return chat.loadedMessages.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.loadedMessages[section].count + 1 // for sent-date cell
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SentDateCell", forIndexPath: indexPath) as! MessageSentDateTableViewCell
            let message = chat.loadedMessages[indexPath.section][0]
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            cell.sentDateLabel.text = dateFormatter.stringFromDate(message.sentDate)
            return cell
        } else {
            let cellIdentifier = "BubbleCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MessageBubbleTableViewCell!
            if cell == nil {
                cell = MessageBubbleTableViewCell(style: .Default, reuseIdentifier: cellIdentifier)

                // Add gesture recognizers #CopyMessage
                let action: Selector = #selector(ChatViewController.messageShowMenuAction(_:))
                let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: action)
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
                cell.bubbleImageView.addGestureRecognizer(doubleTapGestureRecognizer)
                cell.bubbleImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: action))
            }
            let message = chat.loadedMessages[indexPath.section][indexPath.row-1]
            cell.configureWithMessage(message)
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    // Reserve row selection #CopyMessage
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }

    func tableViewScrollToBottomAnimated(animated: Bool) {
        let numberOfRows = tableView.numberOfRowsInSection(0)
        if numberOfRows > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: numberOfRows-1, inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(textView: UITextView) {
        updateTextViewHeight()
        sendButton.enabled = textView.hasText()
    }

    func updateTextViewHeight() {
        let oldHeight = textView.frame.height
        let maxHeight = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? ChatViewController.textViewMaxHeight.portrait : ChatViewController.textViewMaxHeight.landscape
        var newHeight = min(textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height, maxHeight)
        #if arch(x86_64) || arch(arm64)
            newHeight = ceil(newHeight)
        #else
            newHeight = CGFloat(ceilf(newHeight.native))
        #endif
        if newHeight != oldHeight {
            toolBar.frame.size.height = newHeight+8*2-0.5
        }
    }

    // MARK: - UIKeyboard Notifications

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height
        let insetOld = tableView.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = tableView.contentSize.height - (tableView.frame.height-insetOld.top-insetOld.bottom)

        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.tableView.tracking || self.tableView.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.tableView.contentOffset.y += insetChange
                    if self.tableView.contentOffset.y < -insetOld.top {
                        self.tableView.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.tableView.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16)) // http://stackoverflow.com/a/18873820/242933
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }

    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let insetNewBottom = tableView.convertRect(frameNew, fromView: nil).height

        // Inset `tableView` with keyboard
        let contentOffsetY = tableView.contentOffset.y
        tableView.contentInset.bottom = insetNewBottom
        tableView.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.tableView.tracking || self.tableView.decelerating {
            tableView.contentOffset.y = contentOffsetY
        }
    }

    // MARK: - Actions

    func sendMessageAction() {
        // Autocomplete text before sending #hack
        textView.resignFirstResponder()
        textView.becomeFirstResponder()

        
        let messageText = textView.text.strip()
        let date = NSDate()
        chat.loadedMessages.append([Message(incoming: false, text: messageText, sentDate: date)])
        chat.lastMessageText = messageText
        chat.lastMessageSentDate = date
        NSNotificationCenter.defaultCenter().postNotificationName(AccountDidSendMessageNotification, object: chat)

        textView.text = nil
        updateTextViewHeight()
        sendButton.enabled = false

        let lastSection = tableView.numberOfSections
        tableView.beginUpdates()
        tableView.insertSections(NSIndexSet(index: lastSection), withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 0, inSection: lastSection),
            NSIndexPath(forRow: 1, inSection: lastSection)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates()
        tableViewScrollToBottomAnimated(true)
        AudioServicesPlaySystemSound(ChatViewController.messageSoundOutgoing)
    }

    // Handle actions #CopyMessage
    // 1. Select row and show "Copy" menu
    func messageShowMenuAction(gestureRecognizer: UITapGestureRecognizer) {
        let twoTaps = (gestureRecognizer.numberOfTapsRequired == 2)
        let doubleTap = (twoTaps && gestureRecognizer.state == .Ended)
        let longPress = (!twoTaps && gestureRecognizer.state == .Began)
        if doubleTap || longPress {
            let pressedIndexPath = tableView.indexPathForRowAtPoint(gestureRecognizer.locationInView(tableView))!
            tableView.selectRowAtIndexPath(pressedIndexPath, animated: false, scrollPosition: .None)

            let menuController = UIMenuController.sharedMenuController()
            let bubbleImageView = gestureRecognizer.view!
            menuController.setTargetRect(bubbleImageView.frame, inView: bubbleImageView.superview!)
            menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(ChatViewController.messageCopyTextAction(_:)))]
            menuController.setMenuVisible(true, animated: true)
        }
    }
    // 2. Copy text to pasteboard
    func messageCopyTextAction(menuController: UIMenuController) {
        let selectedIndexPath = tableView.indexPathForSelectedRow
        let selectedMessage = chat.loadedMessages[selectedIndexPath!.section][selectedIndexPath!.row-1]
        UIPasteboard.generalPasteboard().string = selectedMessage.text
    }
    // 3. Deselect row
    func menuControllerWillHide(notification: NSNotification) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
        }
        (notification.object as! UIMenuController).menuItems = nil
    }
}

class InputTextView: UITextView {
    // Only show "Copy" when selecting a row while `textView` is first responder #CopyMessage
    override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        if (delegate as! ChatViewController).tableView.indexPathForSelectedRow != nil {
            return action == #selector(ChatViewController.messageCopyTextAction(_:))
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }

    // More specific than implementing `nextResponder` to return `delegate`, which might cause side effects?
    func messageCopyTextAction(menuController: UIMenuController) {
        (delegate as! ChatViewController).messageCopyTextAction(menuController)
    }
}
