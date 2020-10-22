//
//  AppError.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 22.10.20.
//

import UIKit

enum AppError: Error {
    case notConnectedToInternet
    case otherError(error: Error?)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            AppError.otherError(error: error).displayInViewController(viewController)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController, okHandler: ((UIAlertAction) -> ())? = nil, additionalActions: [UIAlertAction] = []) {
        let title: String?
        let message: String?
        switch self {
        case .notConnectedToInternet:
            title = "An internet connection is required to proceed."
            message = nil
        case .otherError(let error):
            title = "An unknown error occurred."
            message = error?.localizedDescription
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        additionalActions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: okHandler))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
