//
//  Drink.swift
//  DrinkTest
//
//  Created by Filip Ingr on 08/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import Foundation

enum DrinkType {
    case soft, beer, cider, wine, spiritsAndLiqueurs
    
    var name: String {
        switch self {
        case .soft:
            return "Soft"
        case .beer:
            return "Beer"
        case .cider:
            return "Cider"
        case .wine:
            return "Wine"
        case .spiritsAndLiqueurs:
            return "Spirits & Liqueurs"
        }
    }
    
    var price: Float {
        switch self {
        case .soft:
            return 0.99
        case .beer:
            return 3.99
        case .cider:
            return 2.99
        case .wine:
            return 5.99
        case .spiritsAndLiqueurs:
            return 7.99
        }
    }
    
    var extrasAvailable: [DrinkExtras] {
        switch self {
        case .soft:
            return [.double, .bottle]
        case .beer:
            return [.double, .bottle]
        case .cider:
            return [.double, .bottle]
        case .wine:
            return [.bottle]
        case .spiritsAndLiqueurs:
            return []
        }
    }
    
    var extrasApplicable: Bool {
        self.extrasAvailable.count > 0
    }
}

enum DrinkExtras {
    case none, double, bottle
    
    var name: String {
        switch self {
        case .none:
            return "Normal"
        case .double:
            return "Double"
        case .bottle:
            return "Bottle"
        }
    }
}

class Drink {
    var quantity: Int
    var drinkType: DrinkType
    var appliedExtra: DrinkExtras = .none
    var price: Price?
    
    var pricePerDrink: Float {
        switch appliedExtra {
        case .none:
            return drinkType.price
        case .double:
            return drinkType.price * 1.75
        case .bottle:
            return drinkType.price * 5.0
        }
    }
    
    var drinkTotalCost : Float {
        var basePrice = drinkType.price * Float(quantity)
        
        switch appliedExtra {
        case .none:
            break
        case .double:
            basePrice *= 1.75
        case .bottle:
            basePrice *= 5.0
        }

        if SpecialOffer.hasAny {
            for offer in SpecialOffer.validOngoingSpecialOffers {
                if offer == .TGIF6pm {
                    let numberOfFreeDrinks = quantity / 2
                    let savedOnFreeDrinks = Float(numberOfFreeDrinks) * (basePrice / Float(quantity))
                    basePrice -= savedOnFreeDrinks
                }
            }
        }
        
        return basePrice
    }
    
    var descriptionString: String {
        String(format: "%dx %@ (%@) for %@%.02f", quantity, drinkType.name, appliedExtra.name, CURRENCY_SYMBOL, drinkTotalCost)
    }
    
    init(drinkType: DrinkType, extra: DrinkExtras) {
        self.quantity = 1
        self.appliedExtra = extra
        self.drinkType = drinkType
    }
}
