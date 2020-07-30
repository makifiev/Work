//
//  SettingsTableViewCell.swift
//  FSense
//
//  Created by Акифьев Максим  on 18/02/2020.
//  Copyright © 2020 Акифьев Максим . All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    var nameImage: UIImageView!
    var nameLabel: UILabel!
  
    
    func setCellView()
    {
        let screensize = UIScreen.main.bounds.width
        nameImage = setNameImage(imageName: "", frame: CGRect(x: 30, y: 15, width: 20, height: 20))
        self.contentView.addSubview(nameImage)
        nameLabel = setNameLabel(text: "", frame: CGRect(x: nameImage.frame.origin.x + nameImage.frame.width + 15, y: nameImage.frame.origin.y, width: screensize - screensize / 4, height: 20))
        self.contentView.addSubview(nameLabel)
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

extension SettingsTableViewCell
{
    
      func setNameImage(imageName: String, frame: CGRect) -> UIImageView
      {
          let imageView = UIImageView()
          imageView.image = UIImage(named: imageName)
          imageView.contentMode = .center
          imageView.backgroundColor = .clear
          imageView.frame = frame
          return imageView
      }
      
      func setNameLabel(text: String, frame: CGRect) -> UILabel
      {
          let label = UILabel()
          label.text = text
          label.font = UIFont(name: "Helvetice-neue", size: 20)
          label.frame = frame
          label.textColor = .systemGray
          
          return label
      }
}
