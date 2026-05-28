//
//  BudgetCategory.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//

import SwiftUI

enum BudgetCategory: String, CaseIterable, Codable {
    case transportation = "Transportation"
    case food           = "Food & Drinks"
    case activity       = "Activities"
    case accommodation  = "Accommodation"
    case shopping       = "Shopping"
    case other          = "Other"
 
    var icon: String {
        switch self {
        case .transportation: return "airplane"
        case .food:           return "fork.knife"
        case .activity:       return "figure.hiking"
        case .accommodation:  return "bed.double.fill"
        case .shopping:       return "bag.fill"
        case .other:          return "ellipsis.circle.fill"
        }
    }
 
    var color: String {
        switch self {
        case .transportation: return "categoryBlue"
        case .food:           return "categoryOrange"
        case .activity:       return "categoryGreen"
        case .accommodation:  return "categoryPurple"
        case .shopping:       return "categoryPink"
        case .other:          return "categoryGray"
        }
    }
}

extension BudgetCategory {
    var swiftUIColor: Color {
        switch self {
        case .transportation: return Color("categoryBlue",    bundle: nil).fallback(.blue)
        case .food:           return Color("categoryOrange",  bundle: nil).fallback(.orange)
        case .activity:       return Color("categoryGreen",   bundle: nil).fallback(.green)
        case .accommodation:  return Color("categoryPurple",  bundle: nil).fallback(.purple)
        case .shopping:       return Color("categoryPink",    bundle: nil).fallback(.pink)
        case .other:          return Color("categoryGray",    bundle: nil).fallback(.gray)
        }
    }
}
 
extension Color {
    func fallback(_ fallback: Color) -> Color { self }
}
