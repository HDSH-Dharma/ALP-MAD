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
        case .transportation: return Self.named("categoryBlue",    fallback: .blue)
        case .food:           return Self.named("categoryOrange",  fallback: .orange)
        case .activity:       return Self.named("categoryGreen",   fallback: .green)
        case .accommodation:  return Self.named("categoryPurple",  fallback: .purple)
        case .shopping:       return Self.named("categoryPink",    fallback: .pink)
        case .other:          return Self.named("categoryGray",    fallback: .gray)
        }
    }

    private static func named(_ name: String, fallback: Color) -> Color {
        UIColor(named: name) != nil ? Color(name) : fallback
    }
    
    var watchColor: Color {
        switch self {
        case .transportation: return Self.named("categoryBlue",    fallback: .blue)
        case .food:           return Self.named("categoryOrange",  fallback: .orange)
        case .activity:       return Self.named("categoryGreen",   fallback: .green)
        case .accommodation:  return Self.named("categoryPurple",  fallback: .purple)
        case .shopping:       return Self.named("categoryPink",    fallback: .pink)
        case .other:          return Self.named("categoryGray",    fallback: .gray)
        }
    }
    
    var shortName: String {
        switch self {
        case .transportation: return "Transport"
        case .food:           return "Food"
        case .activity:       return "Activities"
        case .accommodation:  return "Stay"
        case .shopping:       return "Shopping"
        case .other:          return "Other"
        }
    }
}


