//
//  SpecialOffer.swift
//  DrinkTest
//
//  Created by Filip Ingr on 08/03/2020.
//  Copyright © 2020 Filip Ingr. All rights reserved.
//

import Foundation

enum SpecialOffers {
    case none, TGIF6pm
}

class SpecialOffer {
    static var hasAny: Bool {
        return self.validOngoingSpecialOffers.count > 0
    }
    static let ongoingSpecialOffers: [SpecialOffers] = [.TGIF6pm]
    static var validOngoingSpecialOffers: [SpecialOffers] {
        var offers: [SpecialOffers] = []
        for offer in ongoingSpecialOffers {
            switch offer {
            case .TGIF6pm:
                let today = Date()
                let calendar = Calendar(identifier: .gregorian)
                let day = calendar.dateComponents([.weekday, .hour], from: today)

                if let weekDay = day.weekday, let hour = day.hour {
                    if weekDay == 6 && hour >= 18 && hour <= 23 {
                        offers.append(.TGIF6pm)
                    }
                }
                break
            default:
                // PLACE TO VALIDATE FUTURE SPECIAL OFFERS
                break
            }
        }
        
        return offers
    }
}
