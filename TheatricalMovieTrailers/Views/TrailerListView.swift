//
//  TrailerListView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

struct TrailerListView: View {
    enum SortingMode: String {
        case TitleAscending = "Title (A-Z)"
        case ReleaseAscending = "Release date"
        case ReleaseDescending = "Release (reversed)"
        
        func nextMode() -> SortingMode {
            switch self {
            case .TitleAscending:
                return .ReleaseAscending
            case .ReleaseAscending:
                return .ReleaseDescending
            default:
                return .TitleAscending
            }
        }
        
        var predicate: ((MovieInfo, MovieInfo) -> Bool) {
            get {
                switch self {
                case .ReleaseAscending:
                    return {
                        if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
                            return r0 < r1
                        } else {
                            return $0.title < $1.title
                        }
                    }
                case .ReleaseDescending:
                    return {
                        if let r0 = $0.releaseDate, let r1 = $1.releaseDate {
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
    
    @ObservedObject private var appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    @State var model: [MovieInfo]
    @State var settingsShown = false
    @State var sortingMode = SortingMode.ReleaseAscending
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geo in
            return NavigationView() {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading) {
                        ForEach(model) { model in
                            if horizontalSizeClass == .compact {
                                MovieTrailerView(model: .constant(model))
                                    .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.8)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(geo.size.width * 0.07)
                                    .padding([.leading, .bottom], geo.size.width * 0.025)
                            } else {
                                // iPad gets a nice sidebar with posters
                                NavigationLink(destination: MovieTrailerView(model: .constant(model))
                                        .navigationBarHidden(true)
                                        .edgesIgnoringSafeArea(.top)
                                ) {
                                    HStack(alignment: .center) {
                                        if let maybe = appDelegate.idsAndImages[model.id], let image = maybe {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 100)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(model.title)
                                                .font(.title3)
                                                .foregroundColor(.primary)
                                                .padding(.top)
                                            Text(model.releaseDateString)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(model.studio)
                                                .font(.callout)
                                                .foregroundColor(.primary)
                                                .padding(.bottom)
                                            
                                            Divider()
                                        }
                                        .padding(.top)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Theatrical Trailers")
                .navigationBarItems(leading:
                    Button(action: {
                        let nextMode = sortingMode.nextMode()
                        DispatchQueue.global(qos: .userInteractive).async {
                            let sortedModel = model.sorted(by: nextMode.predicate)
                            DispatchQueue.main.async {
                                sortingMode = nextMode
                                model = sortedModel
                            }
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(sortingMode.rawValue)
                        }
                    }), trailing:
                    Button(action: {
                        settingsShown = true
                    }, label: {
                        Image(systemName: "gearshape")
                            .clipShape(Rectangle())
                            .accessibility(label: Text("Settings"))
                    })
                )
            }
            .sheet(isPresented: $settingsShown, onDismiss: nil) {
                SettingsView()
            }
        }
    }
}

#if DEBUG
struct TrailerListView_Previews: PreviewProvider {
    static var previews: some View {
        TrailerListView(model: [MovieInfo.Example.AQuietPlaceII, MovieInfo.Example.AQuietPlaceII])
            .colorScheme(.dark)
            .background(Color.black)
    }
}
#endif
