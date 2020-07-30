 //
 //  TableViewController.swift
 //  FSense
 //
 //  Created by Акифьев Максим  on 28/06/2019.
 //  Copyright © 2019 Акифьев Максим . All rights reserved.
 //

 import UIKit
 import Alamofire
 import CoreData

 class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ActivityIndicatorPresenter, NSFetchedResultsControllerDelegate, CameraListDrawerViewControllerDelegate {
     
     deinit {
         UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations:
            {
         self.settingsMenuView.alpha = 0
         self.blackView.alpha = 0
             })

     }
     @IBOutlet weak var warnLabel: UILabel!
     
     var categoryId: Int64!
     var activityIndicator = UIActivityIndicatorView()
     var window: UIWindow?
     var menuIsVisible = true
     var valueToPass:String!
     var itemId:Int16!
     var y:CGFloat = 0
     var YPos:CGFloat = 0
     let BellView = UIView()
     let ringImageView = UIImageView()
     let countLabel = UILabel()
     static var myPosts = [Post]()
     let placeCellId = "PlaceCell"
     let companyNameCellId = "CompanyCell"
     let settingsTableCellId = "SettingsCell"
     
     var blockOperations: [BlockOperation] = []
     let Pushlabel = UILabel()
     let button =  UIButton(type: .custom)
     let defaults = UserDefaults.standard
     
     var menuIsHidden = true
     
     let settingsNames = ["Настройки", "Камеры"]
     let settingsImages = ["settings", "cameraList"]
     
     var cameraListDrawerViewController:CameraListDrawerViewController!
     
     static var getArrIdSubs = [String]()
     let version: UILabel =
     {
         let label = UILabel()
         return label
     }()
     let blackView: UIView =
     {
         let view = UIView()
         return view
     }()
     let placesTableView: UITableView =
     {
         let tableView = UITableView()
         return tableView
     }()
     
     let companyNamesTableView: UITableView =
     {
         let tableView = UITableView()
         return tableView
     }()
     
     let settingsTableView: UITableView =
     {
        let tableView = UITableView()
        return tableView
     }()
     
     let companyNameView: UIView =
     {
         let view = UIView()
         return view
     }()
     
     let settingsMenuView: UIView =
     {
         let view = UIView()
         return view
     }()
     
     let logoImage: UIImageView =
     {
         let view = UIImageView()
         return view
     }()
     let ExitButton: UIButton =
     {
         let button = UIButton()
         return button
     }()
     var updateVersionButton = UIButton()
     
     var mainView: UIView = {
         let sceenSize = UIScreen.main.bounds.width
         let view = UIView()
         view.backgroundColor = .systemGray
         view.layer.shadowRadius = 8
         view.layer.shadowOffset = .zero
         view.layer.shadowColor = UIColor.black.cgColor
         view.layer.shadowOpacity = 1
         view.layer.cornerRadius = 10
         view.translatesAutoresizingMaskIntoConstraints = false
         view.frame = CGRect(x: sceenSize/8 - 0.5, y: 0 , width: sceenSize - sceenSize/4 + 0.5, height: 200 + 0.5)
         return view
         }()
     
     //MARK: FRC for TableView
     lazy var FRCPlacesName: NSFetchedResultsController<NSFetchRequestResult> =
         {
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: "PlacesInfo"))
             let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
             let entityDescription = NSEntityDescription.entity(forEntityName: "PlacesInfo", in: context)
             fetchRequest.entity = entityDescription
             fetchRequest.predicate = NSPredicate.init(format: "categoryID==\(categoryId ?? 0)")
             fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
             let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
             fetchedResultController.delegate = self
             do
             {
                 try  fetchedResultController.performFetch()
             }
             catch let error
             {
                 print("ERROR: \(error)")
             }
             return fetchedResultController
     }()
     
     lazy var FRCCompany: NSFetchedResultsController<NSFetchRequestResult> =
         {
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: "PlacesCompany"))
             let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
             let entityDescription = NSEntityDescription.entity(forEntityName: "PlacesCompany", in: context)
             fetchRequest.entity = entityDescription
             fetchRequest.sortDescriptors = [NSSortDescriptor(key: "companyName", ascending: true)]
             let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
             fetchedResultController.delegate = self
     
             do
             {
                 try  fetchedResultController.performFetch()
             }
             catch let error
             {
                 print("ERROR: \(error)")
             }
             return fetchedResultController
     }()
     
     //MARK: FRC for Counter
     lazy var FRCPush: NSFetchedResultsController<NSFetchRequestResult> =
         {
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PushList")
             let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
             let entityDescription = NSEntityDescription.entity(forEntityName: "PushList", in: context)
             fetchRequest.entity = entityDescription
             fetchRequest.predicate = NSPredicate.init(format: "looked==\(false)")
             fetchRequest.sortDescriptors = [NSSortDescriptor(key: "looked", ascending: true)]
             
             let fetchedResultControllerPush = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
             fetchedResultControllerPush.delegate = self
             do
             {
                 try  fetchedResultControllerPush.performFetch()
             }
             catch let error
             {
                 print("ERROR: \(error)")
             }
             return fetchedResultControllerPush
     }()
     func setPlaceTableView()
     {
         
         placesTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
         placesTableView.backgroundColor = UIColor.rgb(red: 37, green: 40, blue: 46)
         placesTableView.register(InfoPlacesTableViewCell.self, forCellReuseIdentifier: placeCellId)
         placesTableView.separatorColor = .rgb(red: 58, green: 62, blue: 68)
         placesTableView.allowsSelection = true
         placesTableView.separatorInset = UIEdgeInsets.zero
         placesTableView.tableFooterView = UIView()
         placesTableView.dataSource = self
         placesTableView.delegate = self
         let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureOpenSettings))
         swipeRight.direction = .right
         placesTableView.addGestureRecognizer(swipeRight)
         
         self.view.addSubview(placesTableView)
     }
     func setPlaceCompanyTableView()
     {
         companyNamesTableView.frame = CGRect(x: 0, y: 0, width: companyNameView.frame.width, height: companyNameView.frame.height)
         companyNamesTableView.backgroundColor = UIColor.rgb(red: 57, green: 60, blue: 66)
         companyNamesTableView.register(CompanyNamesTableViewCell.self, forCellReuseIdentifier: companyNameCellId)
         companyNamesTableView.separatorColor = .rgb(red: 78, green: 82, blue: 88)
         companyNamesTableView.allowsSelection = true
         companyNamesTableView.separatorInset = UIEdgeInsets.zero
         companyNamesTableView.tableFooterView = UIView()
         companyNamesTableView.bounces = false
         companyNamesTableView.dataSource = self
         companyNamesTableView.delegate = self
     }
     func configSettingfTableView()
     {
         settingsTableView.frame = CGRect(x: 0, y: logoImage.frame.height + 15, width: settingsMenuView.frame.width, height: 100)
         settingsTableView.backgroundColor = .rgb(red: 28, green: 32, blue: 37)
         settingsTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: settingsTableCellId)
         settingsTableView.separatorColor = .rgb(red: 8, green: 2, blue: 7)
         settingsTableView.allowsSelection = true
         settingsTableView.separatorInset = UIEdgeInsets.zero
         settingsTableView.tableFooterView = UIView()
         settingsTableView.bounces = false
         settingsTableView.dataSource = self
         settingsTableView.delegate = self
         
     }
     
     func setPlaceCompanyView()
     {
         let sceenSize = UIScreen.main.bounds.width
         companyNameView.backgroundColor = UIColor.rgb(red: 37, green: 40, blue: 46)
         self.view.addSubview(mainView)
         self.mainView.addSubview(companyNameView)
         self.companyNameView.addSubview(companyNamesTableView)
         self.companyNameView.frame = CGRect(x: 0.5, y: 0.5, width: sceenSize - sceenSize/4 - 0.5, height: 200 - 0.5)
         self.companyNameView.layer.cornerRadius = 10
         self.companyNameView.layer.masksToBounds = true
         self.companyNameView.translatesAutoresizingMaskIntoConstraints = false
         setPlaceCompanyTableView()
         addSettingView()
     }
     
     func closeMainMenu()
     {
         if self.mainView.alpha == 1
         {
             self.placesTableView.isUserInteractionEnabled = false
             self.setTextButton(StringUnicode: "\u{25BC} ")
             UIView.animate(withDuration: 0.3, animations: {
                 self.mainView.alpha = 0
                 
             }) { ( finished ) in
                 self.placesTableView.isUserInteractionEnabled = true
             }
         }
     }
     
     @objc func closeSettingMenu()
     {
         if self.settingsMenuView.alpha == 1
         {
            closeSetMenu()
         }
     }
     @objc func handleTap(){
         
         self.closeMainMenu()
     }
     
     @objc func SetTap(){
         
         self.closeMainMenu()
     }
     
     @objc func didTapNavBar() {
         print("user did tap navigation bar")
         if self.mainView.alpha == 1
         {
              self.setTextButton(StringUnicode: "\u{25BC} ")
             UIView.animate(withDuration: 0.3, animations: {
                
                 self.mainView.alpha = 0
             })
         }
         else
         {
               self.setTextButton(StringUnicode: "\u{25B2} ")
             UIView.animate(withDuration: 0.3, animations: {
               
                 self.mainView.alpha = 1
             })
             
         }
     }
     
     func setTextButton(StringUnicode: String)
     {
         if var companyString = self.defaults.string(forKey: "savedString") {
             print("defaults savedString: \(companyString)")
         self.button.setTitle(StringUnicode + "\(companyString)", for: .normal)
              button.contentHorizontalAlignment = .left
 //        self.button.sizeToFit()
         }
         else
         {
             let place =  self.FRCCompany.object(at: IndexPath(row: 0, section: 0))  as? PlacesCompany
         self.button.setTitle(StringUnicode + "\(place!.companyName!)", for: .normal)
              button.contentHorizontalAlignment = .left
                        self.button.sizeToFit()
             
         }
     }
    
     func addShadowForRoundedButton(view: UIView, getView: UIView, opacity: Float = 1) {
         let shadowView = UIView()
         shadowView.backgroundColor = UIColor.black
         shadowView.layer.opacity = opacity
         shadowView.layer.shadowRadius = 5
         shadowView.layer.shadowOpacity = 1
         shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
         shadowView.layer.cornerRadius = 10
         shadowView.frame = CGRect(x: 5, y: 5, width: getView.frame.width, height: getView.frame.height)
         getView.addSubview(shadowView)
         view.bringSubviewToFront(getView)
     }
     func setBlackView()
     {
         blackView.frame = self.view.frame
         blackView.backgroundColor = .black
         blackView.alpha = 0
         self.view.addSubview(blackView)
         let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
         swipeLeft.direction = .left
         blackView.addGestureRecognizer(swipeLeft)
     }
     override func viewDidLoad() {
         super.viewDidLoad()
         self.view.backgroundColor = UIColor.rgb(red: 37, green: 40, blue: 46)
         setBlackView()
         let screenSize = UIScreen.main.bounds.width
         
         button.frame = CGRect(x: 10, y: 0, width: screenSize - screenSize / 4 - 20, height: 40)
         button.backgroundColor = .clear
         button.contentHorizontalAlignment = .left
         button.addTarget(self, action: #selector(didTapNavBar), for: .touchUpInside)
         navigationItem.titleView = button
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(TableViewController.handleTap))
              tap.cancelsTouchesInView = false
              view.addGestureRecognizer(tap)
         let tapSettingsClose: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(TableViewController.closeSettingMenu))
         tapSettingsClose.cancelsTouchesInView = false
         self.blackView.addGestureRecognizer(tapSettingsClose)
         self.mainView.alpha = 0

         
         if  AppDelegate.TableViewDisplay == true
         {
             let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let homePage = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! PushViewController
             var pushVC: PushListController!
             pushVC = mainStoryboard.instantiateViewController(withIdentifier: "PushListController") as? PushListController
             self.present(homePage, animated: true, completion:
                 {
                     self.navigationController?.pushViewController(pushVC, animated: false)
             })
         }
         self.addPyshCountLabel()
         updateTableContent()
     }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.setNavigationBarHidden(false, animated: animated)
         AppDelegate.firstPushToDash = true
         pushCounters()
         
         getRights()
     }

     func getRights()
     {
         Networking.sharedInstance.getRights(completed:
             {
             (result) in
             switch result
             {
             case .Success(let data):
                 print("data")
             case .Error( _):
                 print("error")
             case .NetworkError( _):
                 print("Ошибка Сети")
                 self.presentLostConnectionAlertController()
             case .LostConnection( _):
                 self.presentAlertController()
             case .SessionTimeOut( _):
                 AppDelegate.reOpenSession(function: self.getRights())
             case .nilResponse( _):
                 print("nil")
             }
         })
     }
     
     func updateCameras()
     {
         Networking.sharedInstance.getCameras(companyId: categoryId, completed:
             {
             (result) in
             switch result
             {
             case .Success(let data):
                 if (self.cameraListDrawerViewController != nil)
                 {
                     self.cameraListDrawerViewController.update()
                 }
             case .Error( _):
                 print("error")
             case .NetworkError( _):
                 print("Ошибка Сети")
                 self.presentLostConnectionAlertController()
             case .LostConnection( _):
                 self.presentAlertController()
             case .SessionTimeOut( _):
                 AppDelegate.reOpenSession(function: self.updateCameras())
             case .nilResponse( _):
                 print("nil")
             }
         })
     }
 }

