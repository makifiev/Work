//
//  InfoPlacesTableViewCell.swift
//  FSense
//
//  Created by Акифьев Максим  on 27/06/2019.
//  Copyright © 2019 Акифьев Максим . All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import Alamofire

class InfoPlacesTableViewCell: UITableViewCell {
    
    var ImageOfPlace: UIImageView!
    var NameLabel: UILabel!
    var TypeLabel: UILabel!
    
    var y: CGFloat = 0
    var Id:Int16!
    var category:Int16!
    var nameLabel:String!
    let screenSize = UIScreen.main.bounds.width
    func setImageFromURl(photoId: String)
    {
        let currentURL = URL(string: Networking.PhotoURL + "photos/" + photoId + "/120")
        DispatchQueue.global(qos: .default).async
            {
                DispatchQueue.main.async
                    {
                        self.ImageOfPlace.kf.setImage(with: currentURL, options: [.transition(.fade(0.2))])
                        self.ImageOfPlace.kf.indicatorType = .activity
                }
        }
    }
    
    
    func setPLaceCellWith(model: PlacesInfo) {
        self.Id = model.id
        self.category = model.categoryID
        self.NameLabel.text = model.name
        self.TypeLabel.text = model.info
        self.TypeLabel.sizeToFit()
        self.NameLabel.sizeToFit()
        self.nameLabel = model.name
        if model.logoId != 0
        {
            setImageFromURl(photoId: "\(model.logoId)")
        }
        else
        {
            ImageOfPlace.image = UIImage(named: "logoForTableView")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension InfoPlacesTableViewCell
{
    func pointNameLabel(text: String, position: CGPoint) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.frame = CGRect(x: 0, y: 0, width: screenSize - 45 - 64, height: 30)
        label.frame.origin = position
        label.font = UIFont(name: "HelveticaNeue", size: 18)
        label.textAlignment = .left
        y = label.frame.origin.y + label.frame.size.height
        return label
    }
    
    func pointTypeLabel(text: String, position: CGPoint) -> UILabel
    {
        let label = UILabel()
        label.text = text
        label.frame = CGRect(x: 0, y: 0, width: screenSize - 45 - 64, height: 30)
        label.textColor = .systemGray
        label.frame.origin = position
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textAlignment = .left
        y = label.frame.origin.y + label.frame.size.height
        return label
    }
    func pointImageView(position:CGPoint) -> UIImageView
    {
        let imageView = UIImageView()
        imageView.frame = CGRect(x:15, y: 15, width: 64 , height:  64)
        imageView.frame.origin = position
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.masksToBounds = true
        return imageView
    }
    
    func setCellView()
    {
        y = 0
        ImageOfPlace =  pointImageView(position: CGPoint(x: 15, y:  10))
        self.contentView.addSubview(ImageOfPlace)
        NameLabel = pointNameLabel(text: "", position: CGPoint(x: ImageOfPlace.frame.origin.x + ImageOfPlace.frame.width + 15, y: y + 10))
        self.contentView.addSubview(NameLabel)
        print(NameLabel.frame)
        TypeLabel = pointTypeLabel(text: "", position: CGPoint(x: NameLabel.frame.origin.x, y: y + 5))
        self.contentView.addSubview(TypeLabel)
    }
}

