//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ryan Barrett on 2/2/16.
//  Copyright © 2016 Ryan Barrett. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    //stack of entered Ops
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var vars = [String: Double]()
    
    var program: AnyObject { //guarenteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                            newOpStack.append(.Operand(operand))
                    }
                }
            }
        }
    }
    
    //overrides the description method so that Ops can be printed
    private enum Op : CustomStringConvertible {  // I implement the CustomDebug protocol
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let vari):
                    return vari
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    //called when the CalculatorBrain object is created (like a constructor)
    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("x", *))
        knownOps["/"] = Op.BinaryOperation("/") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
    }
    
    //function used to actually evaluate an arithmetic expression.  it uses the Ops in the operand
    //stack
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) { //Tuple
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result{
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
            case .Variable(let vari):
                return (vars[vari], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    //calls opStack
    func evaluate() -> Double? {
        let(result, _) = evaluate(opStack)
        return result
    }
    
    //pushes an operand to the stack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    //calls evaluate to evaluate the the most recent ops on the stack
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
            print("\(opStack)")
            return evaluate()
        }
        return nil
    }
    
    //recursively print the history
    private func getString(var wrd: String, var arr: [Op]) -> String {
        if !arr.isEmpty {
            let op = arr.removeLast()
            switch op {
            case .Operand:
                wrd += op.description
                //do nothing
            case .UnaryOperation:
                wrd += op.description + "(" + getString("", arr: arr) + ")"
            case .BinaryOperation:
                wrd += "(" + getString("", arr: arr) + op.description
                arr.removeLast()
                wrd += getString("", arr: arr) + ")"
            case .Variable:
                wrd += op.description
            }
            
        }

        return wrd
    }
    
    //returns a string of Ops to be displayed in the history box
    func getString() -> String? {
        var copy = opStack
        return getString("", arr: copy)
    }
    
    func storeVar (key: String, value: Double) {
        vars[key] = value
        print(vars[key]!)
    }
    
    func getVar(key: String) -> Double? {
        return vars[key]
    }
    
    //called when the clear button in pressed
    func clearStack() {
        opStack.removeAll()
        vars.removeAll()
    }
}