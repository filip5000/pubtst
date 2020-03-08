//
//  ViewController.swift
//  DrinkTest
//
//  Created by Filip Ingr on 06/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ToOrderDrinkTableViewCellDelegate, OrderManagerDelegate {
    
    // MARK: PROPERTIES
    @IBOutlet var totalSavedLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var specialOfferViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var drinkExtrasSegmentedControl: UISegmentedControl!
    @IBOutlet var orderButton: UIButton!
    
    var orderManager: OrderManager = OrderManager()
    
    let itemIdentifier = "DrinkCollectionViewCell"
    let cellIdentifier = "ToOrderDrinkTableViewCell"
        
    // MARK: CONTROLLER LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupCollectionView()
        setupManager()
        checkOrderButtonAvailability()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        orderManager.processSpecialOffers()
    }
    
    // MARK: CONTROLLER METHODS
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name:UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name:UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func didEnterBackground() {
        orderManager.stopTimer()
    }
    
    @objc func didBecomeActive() {
        if orderManager.specialOffersTimer == nil {
            orderManager.processSpecialOffers()            
        }
    }
    
    @IBAction func orderButtonAction() {
        orderManager.orderDrinks()
    }
    
    @IBAction func drinkExtrasValueChanged(_ sender: Any) {
        if drinkExtrasSegmentedControl.selectedSegmentIndex == 0 {
            orderManager.selectedExtra = .none
        } else if drinkExtrasSegmentedControl.selectedSegmentIndex == 1 {
            orderManager.selectedExtra = .double
        } else if drinkExtrasSegmentedControl.selectedSegmentIndex == 2 {
            orderManager.selectedExtra = .bottle
        }
    }
    
    func setupManager() {
        orderManager.delegate = self
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: itemIdentifier, bundle: nil), forCellWithReuseIdentifier: itemIdentifier)
        setupCollecitonViewLayout(animated: true)
    }
    
    func setupCollecitonViewLayout(animated: Bool) {
        let layout = customLayout(size: self.collectionView.frame.size)
        collectionView.setCollectionViewLayout(layout, animated: animated)
    }
    
    func customLayout(size: CGSize) -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: size.width / 2, height: size.width / 4)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }
    
    func animateAdditionOfDrink() {
        let height = CGFloat(orderManager.drinksToOrder.count * 50)
        self.tableView.reloadData()
        self.tableViewHeightConstraint.constant = height > 200 ? 225 : height
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func animateRemovalOfDrink() {
        let height = CGFloat(orderManager.drinksToOrder.count * 50)
        self.tableViewHeightConstraint.constant = height > 200 ? 200 : height
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) {(finished) in
            self.tableView.reloadData()
        }
    }
    
    func animateSpecialOfferShow(show: Bool) {
        self.specialOfferViewHeightConstraint.constant = show ? 30 : 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func checkOrderButtonAvailability() {
        if orderManager.drinksToOrder.count < 2 {
            self.orderButton.isUserInteractionEnabled = orderManager.drinksToOrder.count > 0 ? true : false
            self.orderButton.backgroundColor = orderManager.drinksToOrder.count > 0 ? UIColor.systemGreen : UIColor.lightGray
        }
    }
    
    // MARK: COLLECTIONVEW DELEGATE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderManager.typesToOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath) as! DrinkCollectionViewCell
        cell.drinkNameLabel.text = orderManager.typesToOrder[indexPath.row].name
        cell.setFreeLabel(visible: !orderManager.getNextFree().contains(orderManager.typesToOrder[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        orderManager.addDrink(Drink(drinkType: orderManager.typesToOrder[indexPath.row],extra: orderManager.selectedExtra))
        collectionView.reloadItems(at: [indexPath])
    }
    
    // MARK: TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderManager.drinksToOrder.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ToOrderDrinkTableViewCell
        cell.drinkNameLabel?.text = orderManager.drinksToOrder[indexPath.row].descriptionString
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let halfWidth = view.frame.size.width / 2
        return CGSize(width: halfWidth, height: halfWidth / 2)
    }
    
    // MARK: ToOrderDrinkTableViewCellDelegate
    func remove(at index: Int) {
        orderManager.removeDrink(at: index)
    }
    
    // MARK: ORDER MANAGER DELEGATE
    
    func selectedExtraChanged() {
        collectionView.reloadSections([0])
    }
    
    func addedToToOrderList() {
        animateAdditionOfDrink()
        checkOrderButtonAvailability()
    }
    
    func removedFromToOrderList() {
        animateRemovalOfDrink()
        checkOrderButtonAvailability()
        collectionView.reloadSections([0])
    }
    
    func drinksOrdered() {
        totalPriceLabel.text = orderManager.priceString
        totalSavedLabel.text = orderManager.savedString
        animateRemovalOfDrink()
        checkOrderButtonAvailability()
        collectionView.reloadSections([0])
    }
    
    func ongoingSpecialOffers(offers: [SpecialOffers]) {
        for offer in offers {
            switch offer {
            case .TGIF6pm:
                animateSpecialOfferShow(show: true)
                break
            default:
                break
            }
        }
        
        if offers.isEmpty {
            animateSpecialOfferShow(show: false)
        }
    }    
}

