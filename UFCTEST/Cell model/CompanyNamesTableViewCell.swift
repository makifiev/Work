//
//  CompanyNamesTableViewCell.swift
//  FSense
//
//  Created by Акифьев Максим  on 14/02/2020.
//  Copyright © 2020 Акифьев Максим . All rights reserved.
//

import UIKit

class CompanyNamesTableViewCell: UITableViewCell {
    
    var NameLabel: UILabel!
    var nameLabel:String!
    var y: CGFloat = 0
    var category:Int16!
    let screenSize = UIScreen.main.bounds.width
    
    
    func configureCell(model: PlacesCompany)
    {
        self.NameLabel.text = model.companyName!
        NameLabel.sizeToFit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCell()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompanyNamesTableViewCell
{
    func companyNameLabel(text: String, position: CGPoint) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.frame = CGRect(x: 0, y: 0, width: screenSize - screenSize/8 - 20, height: 20)
        label.frame.origin = position
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        label.textAlignment = .left
        return label
    }
    
    func setCell()
    {
        NameLabel = companyNameLabel(text: "", position: CGPoint(x: 10, y: 10))
        self.contentView.addSubview(NameLabel)
        fadeTextEmployee()
    }
    
    func fadeTextEmployee() {
        let gradient = CAGradientLayer()
        gradient.frame      = NameLabel.bounds
        gradient.colors     = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0.85, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.95, y: 0.0)
        NameLabel.lineBreakMode = .byClipping
        NameLabel.layer.mask = gradient
    }
}
