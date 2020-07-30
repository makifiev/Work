//
//  TableViewMethods.swift
//  FSense
//
//  Created by Акифьев Максим  on 20/12/2019.
//  Copyright © 2019 Акифьев Максим . All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import KWDrawerController

extension TableViewController {
    //MARK: NumberOfRowInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == placesTableView
        {
            if FRCPlacesName == nil
            {
                return 0
            }
            else
            {
                if let sections = FRCPlacesName.sections
                {
                    let sectionInfo = sections[section]
                    return sectionInfo.numberOfObjects
                }
            }
        }
        else if  tableView == companyNamesTableView
        {
            if FRCCompany == nil
            {
                return 0
            }
            else
            {
                if let sections = FRCCompany.sections
                {
                    let sectionInfo = sections[section]
                    return sectionInfo.numberOfObjects
                }
            }
        }
        else
        {
            return settingsNames.count
        }
        return 0
    }
    //MARK: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == self.placesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: placeCellId, for: indexPath) as! InfoPlacesTableViewCell
            if let place =  FRCPlacesName.object(at: indexPath)  as? PlacesInfo
            {
                cell.setPLaceCellWith(model: place)
            }
            
            cell.backgroundColor = UIColor.rgb(red: 37, green: 40, blue: 46)
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.rgb(red: 68, green: 71, blue: 77)
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
        else if tableView == self.companyNamesTableView
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: companyNameCellId, for: indexPath) as! CompanyNamesTableViewCell
            if let place =  FRCCompany.object(at: indexPath)  as? PlacesCompany
            {
                cell.configureCell(model: place)
            }
            
            cell.backgroundColor = UIColor.rgb(red: 58, green: 62, blue: 68)
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.rgb(red: 78, green: 81, blue: 87)
            cell.selectedBackgroundView = bgColorView
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: settingsTableCellId, for: indexPath) as! SettingsTableViewCell
            cell.backgroundColor = .rgb(red: 28, green: 32, blue: 37)
            cell.nameLabel.text = settingsNames[indexPath.row]
            cell.nameImage.image = UIImage(named: settingsImages[indexPath.row])
            let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 0.3))
            v.backgroundColor = .rgb(red: 8, green: 2, blue: 7)
            cell.addSubview(v)
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.rgb(red: 78, green: 81, blue: 87)
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }
    //MARK: DidSelect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if tableView == placesTableView {
            performSegue(withIdentifier: "showDetail", sender: indexPath.row)
            self.placesTableView.deselectRow(at: indexPath, animated: true)
        }
        else if tableView == companyNamesTableView
        {
            
            let place =  FRCCompany.object(at: indexPath)  as? PlacesCompany
            
            place?.first += 1
            CoreDataStack.sharedInstance.saveContext()
            
            let firstName = "\u{25BC} " + place!.companyName!
            self.button.setTitle(firstName, for: .normal)
            //            self.button.sizeToFit()
            defaults.set( place!.companyName!, forKey: "savedString")
            defaults.set(place!.categoryId, forKey: "categoryId")
            self.categoryId = place?.categoryId
            
            getSubs()
            let fetchRequest = FRCPlacesName.fetchRequest
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let entityDescription = NSEntityDescription.entity(forEntityName: "PlacesInfo", in: context)
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate.init(format: "categoryID==\(categoryId!)")
            let sort = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            do {
                try  FRCPlacesName.performFetch()
            }
            catch let error
            {
                print("ERROR: \(error)")
            }
            self.placesTableView.reloadData()
            
            UIView.animate(withDuration: 0.3, animations: {
                self.mainView.alpha = 0
            })
            
            print("company cell tapped")
        }
        else
        {
            if (indexPath.row == 0)
            {
                CoreDataStack.sharedInstance.deleteCompanuInfo()
                print(self.categoryId)
                Networking.sharedInstance.getCompanySubs(parameters: ["COMPANY_ID" : self.categoryId ?? 0]) {(result) in
                    switch result {
                    case .Success(let data):
                        
                        TableViewController.getArrIdSubs = []
                        _ = data.map{CoreDataStack.sharedInstance.createCompanyInfoEntityFrom(dictionary: $0)}
                        CoreDataStack.sharedInstance.saveContext()
                        
                        self.getUserSubs()
                        self.performSegue(withIdentifier: "segueToSettings", sender: indexPath.row)
                        self.settingsTableView.deselectRow(at: indexPath, animated: true)
                    case .Error( _):
                        self.warnLabel.alpha = 1
                    case .NetworkError( _):
                        print("Ошибка Сети")
                        self.presentLostConnectionAlertController()
                    case .LostConnection( _):
                        self.presentAlertController()
                    case .SessionTimeOut( _):
                        AppDelegate.reOpenSession(function: self.updateTableContent())
                    case .nilResponse( _):
                        print("nil")
                        self.hideActivityIndicator()
                    }
                }
                
            }
            else
            {
                performSegue(withIdentifier: "showCameraList", sender: indexPath.row)
            }
        }
        
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //MARK: SegueParam
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            CoreDataStack.sharedInstance.deletePersonGroupData()
            let indexPath = placesTableView.indexPathForSelectedRow
            let currentCell = placesTableView.cellForRow(at: indexPath!) as! InfoPlacesTableViewCell
            let valueToPass = currentCell.nameLabel
            let IdToPass = currentCell.Id
            let CategoryToPass = currentCell.category
            
            let filterDrawerController = segue.destination as! FilterDrawerViewController
            filterDrawerController.myTitle = valueToPass
            filterDrawerController.infoId = Int(IdToPass!)
            filterDrawerController.categoryId = Int(CategoryToPass!)
        }
        else if  segue.identifier == "segueToSettings"
        {
            let indexPath = settingsTableView.indexPathForSelectedRow
            let currentCell = settingsTableView.cellForRow(at: indexPath!) as! SettingsTableViewCell
            let title = currentCell.nameLabel.text
            let infoPlaceController = segue.destination as! SettingViewController
            
            infoPlaceController.navTitle = title ?? ""
            infoPlaceController.attrId = self.categoryId ?? 0
            if let companyString = self.defaults.string(forKey: "savedString") {
                infoPlaceController.placeName = companyString
            }
            else
            {
                let place =  self.FRCCompany.object(at: IndexPath(row: 0, section: 0))  as? PlacesCompany
                infoPlaceController.placeName =  "\(place!.companyName!)"
            }
            
        }
        else if segue.identifier == "showCameraList"
        {
            cameraListDrawerViewController = segue.destination as? CameraListDrawerViewController
            cameraListDrawerViewController.companyId = Int(categoryId)
            cameraListDrawerViewController.cameraListDelegate = self
        }
    }
    
    //MARK:HeightForRow
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == placesTableView
        {
            return 85
        }
        else if tableView == companyNamesTableView
        {
            return 40
        }
        else
        {
            return 50
        }
    }
    
    func setFirstTextButton(text: String, data: [[String:AnyObject]])
    {
        if let companyString = self.defaults.string(forKey: "savedString") {
            print("defaults savedString: \(companyString)")
            
            self.button.setTitle(text + "\(companyString)", for: .normal)
            if self.defaults.integer(forKey: "categoryId") == 0
            {
                let place =  self.FRCCompany.object(at: IndexPath(row: 0, section: 0))  as? PlacesCompany
                self.categoryId = place?.categoryId
            }
            self.categoryId = Int64(self.defaults.integer(forKey: "categoryId"))
            print("defaults categoryId: \(self.defaults.integer(forKey: "categoryId"))")
        }
        else
        {
            let firstName = data.first!
            let firstNameString = firstName["COMPANY_NAME"]!
            self.button.setTitle(text + "\(firstNameString)", for: .normal)
            let place =  self.FRCCompany.object(at: IndexPath(row: 0, section: 0))  as? PlacesCompany
            self.categoryId = place?.categoryId
            
        }
    }
    
    //MARK: PlaceRequest
    func updateTableContent() {
        Networking.sharedInstance.GetPlaces {(result) in
            switch result {
            case .Success(let data):
                
                
                _ = data.map{CoreDataStack.sharedInstance.createPlaceCompanyEntityFrom(dictionary: $0)}
                CoreDataStack.sharedInstance.saveContext()
                
                let place =  self.FRCCompany.object(at: IndexPath(row: 0, section: 0))  as? PlacesCompany
                self.categoryId = place?.categoryId
                
                
                self.setFirstTextButton(text: "\u{25BC} ", data: data)
                self.getSubs()
                self.setPlaceTableView()
                self.view.bringSubviewToFront(self.mainView)
                
                _ = data.map{CoreDataStack.sharedInstance.createPlaceEntityFrom(dictionary: $0)}
                CoreDataStack.sharedInstance.saveContext()
                CoreDataStack.sharedInstance.clearEmployeeGraphList()
                
                self.setSettingsMenuView()
                self.setPlaceCompanyView()
                self.setBlackView()
                //                self.warnLabel.alpha = 0
                
            case .Error( _):
                self.warnLabel.alpha = 1
            case .NetworkError( _):
                print("Ошибка Сети")
                self.presentLostConnectionAlertController()
            case .LostConnection( _):
                self.presentAlertController()
            case .SessionTimeOut( _):
                AppDelegate.reOpenSession(function: self.updateTableContent())
            case .nilResponse( _):
                print("nil")
                self.hideActivityIndicator()
            }
        }
    }
    func getUserSubs()
    {
        let userID = UserDefaults.standard.integer(forKey: "USER_ID")
        Networking.sharedInstance.getPersonSubs(parameters: ["USER_ID" : userID ]) {(result) in
            switch result {
            case .Success(let data):
                TableViewController.getArrIdSubs = []
                for itm in data
                {
                    let item = itm["ATTR_ID"] as! Int
                    
                    TableViewController.getArrIdSubs.append("\(item)")
                }
                print(TableViewController.getArrIdSubs)
            case .Error( _):
                self.warnLabel.alpha = 1
            case .NetworkError( _):
                print("Ошибка Сети")
                self.presentLostConnectionAlertController()
            case .LostConnection( _):
                self.presentAlertController()
            case .SessionTimeOut( _):
                AppDelegate.reOpenSession(function: self.updateTableContent())
            case .nilResponse( _):
                print("nil")
                self.hideActivityIndicator()
            }
        }
    }
    func getSubs()
    {
        CoreDataStack.sharedInstance.deleteCompanuInfo()
        print(self.categoryId)

        Networking.sharedInstance.getCompanySubs(parameters: ["COMPANY_ID" : self.categoryId ?? 0]) {(result) in
            switch result {
            case .Success(let data):
                
                TableViewController.getArrIdSubs = []
                _ = data.map{CoreDataStack.sharedInstance.createCompanyInfoEntityFrom(dictionary: $0)}
                CoreDataStack.sharedInstance.saveContext()
                
                self.getUserSubs()
                
            case .Error( _):
                self.warnLabel.alpha = 1
            case .NetworkError( _):
                print("Ошибка Сети")
                self.presentLostConnectionAlertController()
            case .LostConnection( _):
                self.presentAlertController()
            case .SessionTimeOut( _):
                AppDelegate.reOpenSession(function: self.updateTableContent())
            case .nilResponse( _):
                print("nil")
                self.hideActivityIndicator()
            }
        }
        
        updateCameras()
    }
    @objc func checkAction(sender : UITapGestureRecognizer)
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.closeSetMenu()
        self.closeMainMenu()
        performSegue(withIdentifier: "pushSegue", sender: nil)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
