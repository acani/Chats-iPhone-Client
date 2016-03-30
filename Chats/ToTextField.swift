import UIKit

class ToTextField: UITextField {
    // MARK: - UIResponder

    // Don't begin editing textView when swiping down keyboard
    override func nextResponder() -> UIResponder? {
        return super.nextResponder()!.nextResponder()
    }

    // MARK: - UITextField

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocapitalizationType = .None
        autocorrectionType = .No
        autoresizingMask = .FlexibleWidth
        clearButtonMode = .WhileEditing
        font = UIFont.systemFontOfSize(15)
        returnKeyType = .Next  // TODO: Remove when allowing multiple recipients
        let toLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 26, height: 23))
        toLabel.font = UIFont.systemFontOfSize(15)
        toLabel.text = "To:"
        toLabel.textColor = UIColor(red: 142/255.0, green: 142/255.0, blue: 147/255.0, alpha: 1)
        leftView = toLabel
        leftViewMode = .Always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.leftViewRectForBounds(bounds)
        rect.origin.x += 15
        rect.origin.y -= 0.5
        return rect
    }
}
