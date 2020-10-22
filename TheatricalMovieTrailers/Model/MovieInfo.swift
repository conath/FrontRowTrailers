//
//  TrailerModel.swift
//  MovieTrailers
//
//  Created by Chris on 25.06.20.
//

import Foundation

struct MovieInfo: Identifiable, Hashable {
    let id: Int
    
    let title: String
    let posterURL: URL?
    let trailerURL: URL?
    let trailerLength: String
    let synopsis: String
    
    let studio: String
    let director: String
    let actors: [String]
    let genres: [String]
    let releaseDate: Date?
    let copyright: String
    
    var releaseDateString: String {
        get {
            if let releaseDate = releaseDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: releaseDate)
            } else {
                return "Unknown"
            }
        }
    }
    
    /// Use as placeholder
    static let Empty = MovieInfo(
        id: -1,
        title: "",
        posterURL: nil,
        trailerURL: nil,
        trailerLength: "",
        synopsis: "",
        studio: "",
        director: "",
        actors: [""],
        genres: [""],
        releaseDate: nil,
        copyright: ""
    )
    
    #if DEBUG
    struct Example {
        static let AQuietPlaceII = MovieInfo(
            id: 21837,
            title: "A Quiet Place Part II",
            posterURL: URL(string: "http://trailers.apple.com/trailers/paramount/a-quiet-place-part-ii/images/poster-xlarge.jpg")!,
            trailerURL: URL(string: "https://trailers.apple.com/movies/paramount/a-quiet-place-part-2/a-quiet-place-part-2-trailer-2_a720p.m4v")!,
            trailerLength: "2:37",
            synopsis:
                """
                Following the deadly events at home, the Abbott family (Emily Blunt, Millicent Simmonds, Noah Jupe) must now face the terrors of the outside world as they continue their fight for survival in silence. Forced to venture into the unknown, they quickly realize that the creatures that hunt by sound are not the only threats that lurk beyond the sand path.
                """,
            studio: "Paramount Pictures",
            director: "John Krasinski",
            actors: ["Emily Blunt", "Cillian Murphy", "Millicent Simmonds", "Noah Jupe", "Djimon Hounsou"],
            genres: ["Horror", "Thriller"],
            releaseDate: Date().addingTimeInterval(60*60*24*7), // one week in the future
            copyright: "© Copyright 2020 Paramount Pictures"
        )
    }
    #endif
}

fileprivate class MutableMovieInfo {
    enum ExpectedValue {
        case title, posterURL, trailerURL, trailerLength, synopsis, studio, director, actors, genres, releaseDate, copyright, none
    }
    var id = 0
    var title = ""
    var posterURLString = ""
    var trailerURLString = ""
    var trailerLength = ""
    var synopsis = ""
    
    var studio = ""
    var director = ""
    var actors = [String]()
    var genres = [String]()
    var releaseDate: Date? = nil
    var copyright = ""
    
    private var expectedValue: ExpectedValue = .title
    func expectValue(_ expectedValue: ExpectedValue) {
        self.expectedValue = expectedValue
    }
    
    func saveValue(_ value: String) {
        switch expectedValue {
        case .none:
            return
        case .title:
            title = value
        case .posterURL:
            posterURLString = value
        case .trailerURL:
            trailerURLString = value
        case .trailerLength:
            trailerLength = value
        case .synopsis:
            synopsis += value
            // this is sometimes split into multiple detected strings,
            //  and is followed by the "cast" element (.actors), so keep concatenating
            return
        case .studio:
            studio = value
        case .director:
            director = value
        case .actors:
            actors.append(value)
            return // this is made up of multiple detected strings, so keep appending
        case .genres:
            genres.append(value)
            return // this is made up of multiple detected strings, so keep appending
        case .releaseDate:
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: value)
            // assertions only run in debug configurations, so this will alert
            //  developers to an API change or bug but users won't notice except
            //  for missing release date
            assert(date != nil, "Failed to parse Date from releaseDate string \(value)")
            releaseDate = date
        case .copyright:
            copyright = value
        }
        expectedValue = .none
    }
    
    var movieInfo: MovieInfo {
        MovieInfo(id: id, title: title, posterURL: URL(string: posterURLString), trailerURL: URL(string: trailerURLString), trailerLength: trailerLength, synopsis: synopsis, studio: studio, director: director, actors: actors, genres: genres, releaseDate: releaseDate, copyright: copyright)
    }
}

class MovieInfoXMLParserDelegate: NSObject, XMLParserDelegate {
    var completion: (([MovieInfo]?) -> ())!
    // store parsed data
    private var mutableMI = MutableMovieInfo()
    private var resultMI = [MovieInfo]()
    
    init(completion: @escaping (([MovieInfo]?) -> ())) {
        self.completion = completion
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "movieinfo":
            // new movie entry, save previous one
            resultMI.append(mutableMI.movieInfo)
            mutableMI = MutableMovieInfo()
            if let idString = attributeDict["id"], let int = Int(idString) {
                mutableMI.id = int
            } else {
                assertionFailure("Failed to get id integer from string \(attributeDict["id"] ?? "nil")")
            }
        case "title":
            mutableMI.expectValue(.title)
        case "runtime":
            mutableMI.expectValue(.trailerLength)
        case "studio":
            mutableMI.expectValue(.studio)
        case "releasedate":
            mutableMI.expectValue(.releaseDate)
        case "copyright":
            mutableMI.expectValue(.copyright)
        case "director":
            mutableMI.expectValue(.director)
        case "description":
            mutableMI.expectValue(.synopsis)
        case "cast":
            mutableMI.expectValue(.actors)
        case "genre":
            mutableMI.expectValue(.genres)
        case "xlarge":
            mutableMI.expectValue(.posterURL)
        case "large":
            mutableMI.expectValue(.trailerURL)
        case "location": // follows the last "genre" name tag, contains the low res poster link. must skip
            mutableMI.expectValue(.none)
        default:
            // ignored
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        mutableMI.saveValue(string)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        let movies = Array(self.resultMI.dropFirst())
        let sorted = movies.sorted(by: { // release ascending
            if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                return r0 < r1
            } else {
                return $0.title < $1.title
            }
        })
        DispatchQueue.main.async {
            self.completion(sorted)
            self.completion = nil
        }
    }
}
