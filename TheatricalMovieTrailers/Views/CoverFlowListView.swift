//
//  CoverFlowListView.swift
//  TheatricalMovieTrailers
//
//  Created by Christoph Parstorfer on 14.10.20.
//

import SwiftUI

struct CoverFlowListView: View {
    enum CoverFlowItem: Identifiable {
        case blank
        case settings
        case list
        case moviePlaceholder
        case movie(info: MovieInfo)
        
        var id: Int {
            switch self {
            case .blank:
                return -4
            case .settings:
                return -3
            case .list:
                return -2
            case .moviePlaceholder:
                return -1
            case .movie(info: let info):
                return info.id
            }
        }
        
        var text: String {
            switch self {
            case .blank:
                return ""
            case .settings:
                return "Settings"
            case .list:
                return "List view"
            case .moviePlaceholder:
                return "Loading …"
            case .movie(info: let info):
                return info.title
            }
        }
        
        var image: UIImage? {
            switch self {
            case .blank:
                return nil
            case .settings:
                return UIImage(named: "settingsPoster")
            case .list:
                return UIImage(named: "listViewPoster")
            case .moviePlaceholder:
                return nil
            case .movie(_):
                return nil
            }
        }
    }
    
    @Binding var model: [MovieInfo]
    @State private var showingSheet = false
    @State private var selectedItem: CoverFlowItem? = nil
    @State private var hasSelectedMovieBefore = false
    
    var body: some View {
        var displayedModel: [CoverFlowItem] = [.settings, .list]
        if model.count > 0 {
            displayedModel.append(contentsOf: model.map { CoverFlowItem.movie(info: $0) })
        } else {
            displayedModel.append(contentsOf: repeatElement(.moviePlaceholder, count: 10))
        }
        
        return GeometryReader { frame in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { reader in
                    VStack {
                        Spacer().frame(height: frame.size.height * 0.1)
                        HStack(alignment: .center, spacing: itemWidth(frame) * -0.5) {
                            ForEach(displayedModel) { model in
                                GeometryReader { movGeo in
                                    ZStack {
                                        switch model {
                                        case .blank:
                                            Color.clear
                                        default:
                                            CoverFlowRotatingView(envGeo: frame, content:
                                                                    MoviePosterView(id: model.id, image: model.image) {
                                                    if isCenteredX(container: frame, movGeo) {
                                                        switch model {
                                                        case .settings, .movie(_):
                                                            selectedItem = model
                                                        case .list:
                                                            Settings.instance().isCoverFlow = false
                                                        default:
                                                            break
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            reader.scrollTo(model.id, anchor: .center)
                                                            hasSelectedMovieBefore = true
                                                        }
                                                    }
                                                }
                                            )
                                            VStack {
                                                Spacer()
                                                    .frame(height: movGeo.size.height / 2)
                                            
                                                Spacer()
                                                
                                                Group {
                                                    Text(model.text)
                                                        .font(.headline)
                                                        .lineLimit(4)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.init(top: 0, leading: 16, bottom: 32, trailing: 16))
                                                    
                                                    if case let .movie(info) = model {
                                                        CoverFlowMovieMetaView(model: info/*, movGeo: movGeo*/, onTap: { selected in
                                                            selectedItem = model
                                                            (UIApplication.shared.delegate as! AppDelegate).isPlaying = true
                                                        })
                                                    }
                                                }
                                                .opacity(isCenteredX(container: frame, movGeo) ? 1 : 0)
                                                .animation(Animation.easeIn)
                                            }
                                        }
                                    }
                                }
                                .frame(width: itemWidth(frame) * 1.5)
                                .id(model.id)
                            }
                        }
                    }
                    .padding(.horizontal, itemWidth(frame) * 0.25)
                    .onAppear {
                        // scroll to first placeholder while loading
                        if !hasSelectedMovieBefore {
                            if model.count > 0 {
                                reader.scrollTo(model[0].id)
                            } else {
                                reader.scrollTo(CoverFlowItem.moviePlaceholder.id)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedItem, content: { item in
            if case let .movie(model) = item {
                NavigationView {
                    VStack {
                        MovieTrailerView(model: .constant(model))
                        Spacer()
                    }
                    .navigationBarHidden(true)
                }
                .modifier(CustomDarkAppearance())
            } else {
                SettingsView(isPresented: $showingSheet)
            }
        })
    }
    
    private func itemWidth(_ geo: GeometryProxy) -> CGFloat {
        return min(geo.size.width * 0.5, 200)
    }
    
    private func isCenteredX(container frame: GeometryProxy, _ geo: GeometryProxy, allowance: CGFloat = 0.1) -> Bool {
        let outerCenter = frame.frame(in: .local).midX
        let center = geo.frame(in: .global).midX
        return abs(outerCenter - center) < frame.size.width * allowance
    }
}

#if DEBUG
struct CoverFlowListView_Previews: PreviewProvider {
    static var previews: some View {
        CoverFlowListView(model: .constant([MovieInfo.Example.AQuietPlaceII]))
    }
}
#endif
