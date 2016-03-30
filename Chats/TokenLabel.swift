import UIKit

class TokenLabel: UILabel, UIKeyInput {
    weak var delegate: TokenLabelDelegate?

    override var text: String? {
        didSet {
            if let text = text where text.strip() != "" {
                let textSize = text.sizeWithAttributes([NSFontAttributeName: font])
                frame.size = CGSize(width: textSize.width+8, height: textSize.height+6)
            } else {
                frame.size = .zero
            }
        }
    }

    override var highlighted: Bool {
        didSet {
            backgroundColor = highlighted ? textColor : .clearColor()
        }
    }

    convenience init(origin: CGPoint) {
        self.init(frame: CGRect(origin: origin, size: .zero))
        font = UIFont.systemFontOfSize(15)
        highlightedTextColor = .whiteColor()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        textAlignment = .Center
        textColor = UIColor(red: 18/255.0, green: 106/255.0, blue: 255/255.0, alpha: 1)
        userInteractionEnabled = true
        highlighted = false // sets background color
    }

    // MARK: - UIResponder

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            highlighted = true
            return true
        }
        return false
    }

    override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            highlighted = false
            return true
        }
        return false
    }

    // MARK: - UIResponder: Touch Events

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        highlighted = true
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPoint = touches.first!.locationInView(self)
        if !isFirstResponder() && !frame.contains(touchPoint) {
            highlighted = false
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if highlighted {
            becomeFirstResponder()
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        highlighted = isFirstResponder()
    }

    // MARK: - UIKeyInput

    func hasText() -> Bool {
        return text != nil && text != ""
    }

    func insertText(text: String) {
        if delegate != nil {
            delegate!.tokenLabel(self, didInsertText: text)
        }
    }

    func deleteBackward() {
        if delegate != nil {
            delegate!.tokenLabelDidDeleteBackward(self)
        }
    }

    // MARK: - UITextInputTraits

    var autocapitalizationType: UITextAutocapitalizationType {
        get { return .None } set { }
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { return .No } set { }
    }

    var returnKeyType: UIReturnKeyType {
        get { return .Next } set { }
    }
}

protocol TokenLabelDelegate: class {
    func tokenLabel(tokenLabel: TokenLabel, didInsertText text: String)
    func tokenLabelDidDeleteBackward(tokenLabel: TokenLabel)
}
