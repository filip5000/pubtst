//
//  OrderManager.swift
//  DrinkTest
//
//  Created by Filip Ingr on 06/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import Foundation
import UIKit

let CURRENCY_SYMBOL = "£"

protocol OrderManagerDelegate {
    func selectedExtraChanged()
    func addedToToOrderList()
    func removedFromToOrderList()
    func drinksOrdered()
    func ongoingSpecialOffers(offers: [SpecialOffers])
}

class OrderManager {
    var delegate: OrderManagerDelegate?
    var orderedDrinks: [Drink] = []
    var specialOffersTimer: Timer?
    
    var totalCost: Float {
        orderedDrinks.compactMap{ $0.price?.price }.reduce(0, +)
    }
    var totalSavings: Float {
        orderedDrinks.compactMap{ $0.price?.saved }.reduce(0, +)
    }
    
    var priceString: String {
        String(format: "Total: %@%.02f", CURRENCY_SYMBOL, totalCost)
    }
    
    var savedString: String {
        String(format: "Saved: %@%.02f", CURRENCY_SYMBOL, totalSavings)
    }
    
    func orderDrink(_ drink: Drink) {
        
        if SpecialOffer.validOngoingSpecialOffers.count > 0 {
            for offer in SpecialOffer.validOngoingSpecialOffers {
                switch offer {
                case .TGIF6pm:
                    let numberOfFreeDrinks = drink.quantity / 2
                    let saved = Float(numberOfFreeDrinks) * drink.pricePerDrink
                    let currentPrice = drink.drinkTotalCost
                    let price = Price(specialOffer: offer, price: currentPrice, saved: saved)
                    drink.price = price
                    orderedDrinks.append(drink)
                    break
                default:
                    // PLACE TO HANDLE FUTURE SPECIAL OFFERS
                    break
                }
            }
        } else {
            let price = Price(price: drink.drinkTotalCost)
            drink.price = price
            orderedDrinks.append(drink)
        }
    }
    
    func getCurrentSavingsOnToOrderList() -> Float {
        if SpecialOffer.validOngoingSpecialOffers.count > 0 {
            for offer in SpecialOffer.validOngoingSpecialOffers {
                switch offer {
                case .TGIF6pm:
                    var totalToOrderSavings: Float = 0.0
                    for drink in drinksToOrder {
                        if drink.quantity > 1 {
                            let numberOfFreeDrinks = drink.quantity / 2
                            let saved = Float(numberOfFreeDrinks) * drink.drinkType.price
                            totalToOrderSavings += saved
                        }
                    }
                    
                    return totalToOrderSavings
                default:
                    // PLACE TO CALCULATE FUTURE SPECIAL OFFERS
                    return 0.0
                }
            }
        }
        
        return 0.0
    }
    
    func getCurrentPriceOnToOrderList() -> Float {
        var price: Float = 0.0
        for drink in drinksToOrder {
            price += drink.drinkType.price * Float(drink.quantity)
        }
        return price
    }
    
    func orderDrinks() {
        for drink in self.drinksToOrder.filter({ $0.price == nil}) {
            orderDrink(drink)
            self.drinksToOrder.removeFirst()
        }
        
        delegate?.drinksOrdered()
    }
    
    var selectedExtra: DrinkExtras = .none {
        didSet {
            delegate?.selectedExtraChanged()
        }
    }
    
    var drinksToOrder: [Drink] = []
    
    var typesToOrder: [DrinkType] {
        let allTypes: [DrinkType] = [.soft, .beer, .cider, .wine, .spiritsAndLiqueurs]
        if selectedExtra == .none {
            return allTypes
        }
        return allTypes.filter({ $0.extrasAvailable.contains(selectedExtra)})
    }
    
    func addDrink(_ drink: Drink) {
        for drinq in self.drinksToOrder {
            if drinq.drinkType == drink.drinkType && drinq.appliedExtra == drink.appliedExtra {
                drinq.quantity += drink.quantity
                delegate?.addedToToOrderList()
                return
            }
        }
        
        drinksToOrder.append(drink)
        delegate?.addedToToOrderList()
    }
    
    func removeDrink(at index: Int) {
        self.drinksToOrder.remove(at: index)
        delegate?.removedFromToOrderList()
    }
    
    func getNextFree() -> [DrinkType] {
        var nextFree: [DrinkType] = []
        
        if SpecialOffer.hasAny {
            for offer in SpecialOffer.validOngoingSpecialOffers {
                switch offer {
                case .TGIF6pm:
                    for drink in drinksToOrder.filter({ $0.appliedExtra == selectedExtra}) {
                        if drink.quantity % 2 != 0 {
                            nextFree.append(drink.drinkType)
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        
        return nextFree
    }
    
    func processSpecialOffers() {
        if SpecialOffer.hasAny {
            delegate?.ongoingSpecialOffers(offers: SpecialOffer.validOngoingSpecialOffers)
            stopTimer()
        } else {
            // since it didnt fell into validOngoingSpecialOffers its before 6pm
            // setup timer that checks again at time when it should be active
            
            let today = Date()
            let calendar = Calendar.current
            let day = calendar.dateComponents([.year, .timeZone, .month, .weekOfYear, .weekday, .hour, .minute, .second], from: today)
            
            if day.weekday != 6 {
                delegate?.ongoingSpecialOffers(offers: SpecialOffer.validOngoingSpecialOffers)
            }
            
            var tgifDateComponent = day
            tgifDateComponent.hour = 18
            tgifDateComponent.minute = 0
            tgifDateComponent.second = 1
            
            if let tgifDate = calendar.date(from: tgifDateComponent), let seconds = calendar.dateComponents([.second], from: today, to: tgifDate).second {
                setupTimer(after: seconds)
            }
            
        }
    }
    
    func setupTimer(after seconds: Int) {
        specialOffersTimer = Timer.scheduledTimer(timeInterval: TimeInterval(seconds), target: self, selector: #selector(checkForSpecialOffers), userInfo: nil, repeats: false)
    }
    
    @objc func checkForSpecialOffers() {
        processSpecialOffers()
    }
    
    func stopTimer() {
        self.specialOffersTimer?.invalidate()
        self.specialOffersTimer = nil
    }
}
