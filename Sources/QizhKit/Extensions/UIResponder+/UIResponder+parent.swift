//
//  UIResponder+parent.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import UIKit

public extension UIResponder {
	var parentViewController: UIViewController? {
		next as? UIViewController ?? next?.parentViewController
	}
	
	var parentNavigationController: UINavigationController? {
		next as? UINavigationController ?? next?.parentNavigationController
	}
}
