//
//  TalkTableViewCell.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 14.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit

class TalkTableViewCell: UITableViewCell {
    
    let label = UILabel()
    let viewRow = UIView()
    
    var leadingConst:NSLayoutConstraint!
    var trailingConst:NSLayoutConstraint!
    
    func messageTip(isInComing:Bool)
    {
        if isInComing
        {
            viewRow.backgroundColor = .orange
            leadingConst.isActive = true
            trailingConst.isActive = false
        }else
        {
            viewRow.backgroundColor = .blue
            leadingConst.isActive = false
            trailingConst.isActive = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(viewRow)
        viewRow.layer.cornerRadius = 20
        viewRow.layer.masksToBounds = true
        viewRow.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let const = [
            label.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            viewRow.topAnchor.constraint(equalTo: label.topAnchor, constant: -16),
            viewRow.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            viewRow.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            viewRow.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(const)
        
        leadingConst = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        leadingConst.isActive = true
        
        trailingConst = label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailingConst.isActive = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }
    
}
