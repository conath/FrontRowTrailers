//
//  SortingMode.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 21.10.20.
//

import Foundation

enum SortingMode: String {
    case ReleaseAscending = "Release date"
    case ReleaseDescending = "Release (reversed)"
    case TitleAscending = "Title (A-Z)"
    
    func nextMode() -> SortingMode {
        switch self {
        case .ReleaseAscending:
            return .ReleaseDescending
        case .ReleaseDescending:
            return .TitleAscending
        default:
            return .ReleaseAscending
        }
    }
    
    var predicate: ((MovieInfo, MovieInfo) -> Bool) {
        get {
            switch self {
            case .ReleaseAscending:
                return {
                    if $0.releaseDate != nil && $1.releaseDate == nil {
                        return false
                    } else if $0.releaseDate == nil && $1.releaseDate != nil {
                        return true
                    } else if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                        return r0 < r1
                    } else {
                        return $0.title < $1.title
                    }
                }
            case .ReleaseDescending:
                return {
                    if $0.releaseDate != nil && $1.releaseDate == nil {
                        return true
                    } else if $0.releaseDate == nil && $1.releaseDate != nil {
                        return false
                    } else if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                        return r0 > r1
                    } else {
                        return $0.title < $1.title
                    }
                }
            default:
                return {
                    return $0.title < $1.title
                }
            }
        }
    }
}
