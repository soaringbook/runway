//
//  CommonMacros.swift
//  Soaring Book
//
//  Created by Jelle Vandenbeeck on 01/01/15.
//  Copyright (c) 2015 Fousa. All rights reserved.
//

import Foundation

// MARK: Errors

func printError(items: Any...) {
    print("🔥 \(items)")
}

func printVerbose(items: Any...) {
    print("🚃 \(items)")
}

// MARK: Dispatching

func dispatch_main_after(interval: NSTimeInterval, block: dispatch_block_t!) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), block)
}

func dispatch_main(block: dispatch_block_t!) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func localize(string: NSString) -> NSString {
    return NSLocalizedString(string as String, comment: string as String)
}

func isDebug() -> Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}