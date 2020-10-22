//
//  AppError.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 22.10.20.
//

import SwiftUI

enum AppError: Error, Identifiable {
    var id: Int {
        switch self {
        case .notConnectedToInternet:
            return 1
        default:
            return 0
        }
    }
    
    case notConnectedToInternet
    case otherError(error: Error?)
    
    func makeAlert() -> Alert {
        let title: Text
        let message: Text?
        switch self {
        case .notConnectedToInternet:
            title = Text("An internet connection is required to proceed.")
            message = nil
        case .otherError(let error):
            title = Text("An unknown error occurred.")
            message = error != nil ? Text(error!.localizedDescription) : nil
        }
        
        return Alert(title: title, message: message, dismissButton: .default(Text("Ok")))
    }
}
