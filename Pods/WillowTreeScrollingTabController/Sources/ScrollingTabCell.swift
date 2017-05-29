//
//  ScrollingTabCell.swift
//
//  Copyright (c) 2016 WillowTree, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


import UIKit

/**
 * Default tab cell implementation for the tab controller
 */
open class ScrollingTabCell: UICollectionViewCell {
    
    /// Title label shown in the cell.
    open var titleLabel: UILabel!

    open var theme: ScrollingTabController.CellTheme? {
        didSet {
            guard let theme = theme else { return }
            titleLabel.font = theme.font
            defaultColor = theme.defaultColor
            selectedColor = theme.selectedColor
        }
    }

    open var defaultColor: UIColor = .darkText {
        didSet {
            if !isSelected {
                titleLabel.textColor = defaultColor
            }
        }
    }

    open var selectedColor: UIColor = .blue {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedColor
            }
        }
    }

    open var font: UIFont?
    
    open var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedColor
            } else {
                titleLabel.textColor = defaultColor
            }
        }
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                titleLabel.textColor = selectedColor
            } else {
                titleLabel.textColor = defaultColor
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[view]-|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: ["view": titleLabel])

        let titleContraints = [
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .lessThanOrEqual,
                                                      toItem: self, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
        ]

        titleLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)

        NSLayoutConstraint.activate(horizontalConstraints + titleContraints)
    }
}
