//
//  SmartNumber.swift
//  Clicker
//
//  Created by Матвей Анисович on 3/30/21.
//

import Foundation


struct SmartNumber {
    var numberOfSections = 0.0 {
        didSet {
            while updateNumber() {}
        }
    }
    var currentSection: NumberName = .one
    
    func string(short: Bool = false) -> String {
        if currentSection != .one && currentSection != .thousand {
            let rounded = numberOfSections.rounded(toPlaces: 3)
            if short {
                return rounded.clean + NumberShortName.allCases[currentSection.ordinal()].rawValue
            } else {
                return rounded.clean + " " + currentSection.rawValue
            }
        } else {
            var rounded = numberOfSections.rounded(toPlaces: 3)
            
            if short && currentSection != .one {
                return rounded.clean + NumberShortName.allCases[currentSection.ordinal()].rawValue
            } else {
                if currentSection == .thousand {
                    rounded *= 1000
                    rounded = rounded.rounded(toPlaces: 2)
                }
                return rounded.clean
            }
        }
        
    }
    
    mutating func updateNumber() -> Bool {
        if numberOfSections >= 1000 {
            currentSection = currentSection.next()
            numberOfSections = numberOfSections / 1000
            return true
        } else if numberOfSections < 1, currentSection != .one {
            currentSection = currentSection.previous()
            numberOfSections = numberOfSections * 1000
            return true // Might
        }
        return false
    }
    func double() -> Double {
        return numberOfSections * (1000**currentSection.ordinal())
    }
}
extension SmartNumber {
    static func >=(lhs: inout SmartNumber, rhs: SmartNumber) -> Bool {
        if lhs.currentSection.ordinal() > rhs.currentSection.ordinal() {
            return true
        } else if lhs.currentSection.ordinal() == rhs.currentSection.ordinal() {
            return lhs.numberOfSections > rhs.numberOfSections
        } else {
            return false
        }
    }
    static func +=(lhs: inout SmartNumber, rhs: SmartNumber) {
        let differenceInSections = lhs.currentSection.ordinal() - rhs.currentSection.ordinal()
        let numberToAppend = rhs.numberOfSections.rounded(toPlaces: 6) / (1000.0 ** Double(differenceInSections))
        lhs.numberOfSections += numberToAppend
        lhs.numberOfSections = lhs.numberOfSections.rounded(toPlaces: 6)
    }
    static func -=(lhs: inout SmartNumber, rhs: SmartNumber) {
        let differenceInSections = lhs.currentSection.ordinal() - rhs.currentSection.ordinal()
        let numberToSubtract = rhs.numberOfSections.rounded(toPlaces: 6) / (1000.0 ** Double(differenceInSections))
        lhs.numberOfSections -= numberToSubtract
        lhs.numberOfSections = lhs.numberOfSections.rounded(toPlaces: 6)
    }
    static func *(lhs: inout SmartNumber, rhs: SmartNumber) -> SmartNumber {
        let sumOfSections = lhs.currentSection.ordinal() + rhs.currentSection.ordinal()
        var new = lhs
        new.currentSection = NumberName.allCases[sumOfSections]
        new.numberOfSections *= rhs.numberOfSections.rounded(toPlaces: 6)
        
        return new
    }
    static func *=(lhs: inout SmartNumber, rhs: SmartNumber) {
        lhs = lhs * rhs
    }
}


enum NumberName: String, CaseIterable {
    case one,thousand,million,billion,trillion,quadrillion,quintillion,sextillion,septillion,octillion,nonillion,decillion,undecillion,duodecillion,tredecillion,quattuordecillion,quindecillion,sexdecillion,septendecillion,octodecillion,novemdecillion,vigintillion,unvigintillion,duovigintillion,tresvigintillion,quatvigintillion,quinvigintillion,sesvigintillion,septvigintillion,octovigintillion,novemvigintillion,trigintillion
    
}

enum NumberShortName: String, CaseIterable {
    case one,K,M,B,T,q,Q,s,S,o,N,d,U,D,Td,qd,sd,Sd,Od,Nd,V,uV,dV,tV,qV,QV,sV,SV,OV,NV,tT
}
/*
 
       Quattuordecillion
 Qd    Quindecillion
 sd    Sexdecillion
 Sd    Septendecillion
 Od    Octodecillion
 Nd    Novemdecillion
 V     Vigintillion
 uV    Unvigintillion
 dV    Duovigintillion
 tV    Tresvigintillion
 qV    Quatvigintillion
 QV    Quinvigintillion
 sV    Sesvigintillion
 SV    Septvigintillion
 OV    Octovigintillion
 NV    Novemvigintillion
 tT    Trigintillion
 
 */

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
    func previous() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let before = all.index(idx, offsetBy: -1)
        return all[before == all.endIndex ? all.startIndex : before]
    }
    public func ordinal() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence
func ** (radix: Double, power: Double) -> Double { return pow(radix, power) }
func ** (radix: Int,    power: Int   ) -> Double { return pow(Double(radix), Double(power)) }
func ** (radix: Float,  power: Float ) -> Double { return pow(Double(radix), Double(power)) }

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
