import UIKit

class TextViewController: UIViewController {
    var textView: UITextView! { return (view as! UITextView) }

    override func loadView() {
        let textView = UITextView(frame: UIScreen.mainScreen().bounds, textContainer: nil)
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .Interactive
        view = textView
    }

    // MARK: - Keyboard Inset

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TextViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }

    // Inset scroll views above keyboard
    func keyboardWillShow(notification: NSNotification) {
        let frameEnd = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeightEnd = view.convertRect(frameEnd, fromView: nil).size.height
        setTextViewBottomInset(keyboardHeightEnd)
    }

    func setTextViewBottomInset(insetBottom: CGFloat) {
        textView.contentInset.bottom = insetBottom
        textView.scrollIndicatorInsets.bottom = insetBottom
    }
}
