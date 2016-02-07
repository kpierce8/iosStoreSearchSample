//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by UberDominator on 2/6/16.
//  Copyright © 2016 Frantic Goose Applications. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
