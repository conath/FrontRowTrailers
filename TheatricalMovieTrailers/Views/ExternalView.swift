//
//  ExternalView.swift
//  TheatricalMovieTrailers
//
//  Created by Chris on 26.06.20.
//

import SwiftUI

private extension CGPoint {
    mutating func add(_ point: CGPoint) {
        x += point.x
        y += point.y
    }
}

private class FPS: ObservableObject {
    private var timer: Timer? = nil
    @Published var time: Int = 0
    
    init(framerate: Int = 24) {
        let aTimer = Timer.scheduledTimer(withTimeInterval: 1/24, repeats: true, block: { timer in
            guard self.timer != nil else {
                timer.invalidate()
                return
            }
            self.time += 1
        })
        self.timer = aTimer
    }
}

private enum Direction {
    case downRight, downLeft, upRight, upLeft
    
    /// Returns the delta in terms of (x, y) with a top left (0, 0) coordinate system
    func getVector() -> CGPoint {
        switch self {
        case .downRight:
            return CGPoint(x: 1, y: 1)
        case .downLeft:
            return CGPoint(x: -1, y: 1)
        case .upLeft:
            return CGPoint(x: -1, y: -1)
        case .upRight:
            return CGPoint(x: 1, y: -1)
        }
    }
    
    func flipVertically() -> Direction {
        switch self {
        case .downRight:
            return .upRight
        case .downLeft:
            return .upLeft
        case .upLeft:
            return .downLeft
        case .upRight:
            return .downRight
        }
    }
    
    func flipHorizontally() -> Direction {
        switch self {
        case .downRight:
            return .downLeft
        case .downLeft:
            return .downRight
        case .upLeft:
            return .upRight
        case .upRight:
            return .upLeft
        }
    }
}

/// Shows the selected trailer from the `MovieInfoDataStore` in a layout suitable for a large, non-interactive screen.
/// Playback is controlled by `MovieInfoDataStore.isPlaying`.
/// If there is no selected trailer, or the selected trailer doesn't change for five minutes,
///  the trailer is deselected and a screensaver is shown.
struct ExternalView: View {
    @ObservedObject private var dataStore = MovieInfoDataStore.shared
    /// Screensaver logistics
    @StateObject private var fps = FPS()
    private let screensaverTimeout: TimeInterval = 5 * 60
    @State private var timeout: Timer?
    /// Screensaver state; Logo starts off at (0, 0)
    @State private var offset = CGPoint.zero
    @State private var direction = Direction.downRight
    
    var body: some View {
        GeometryReader { geo in
            if let selected = dataStore.selectedTrailerModel {
                ExternalTrailerView(model: selected, posterImage: $dataStore.posterImage)
                    .onAppear {
                        let nowSelected = selected
                        /// Recreate the screensaver timeout timer
                        timeout?.invalidate()
                        timeout = Timer.scheduledTimer(withTimeInterval: screensaverTimeout, repeats: false, block: { timer in
                            /// Important: don't capture `self` as we're a struct
                            let dataStore = MovieInfoDataStore.shared
                            /// Some time later, is the same trailer still on screen?
                            /// The value of `nowSelected` is captured in this closure
                            /// If it's not playing, remove it to show screensaver
                            if nowSelected == dataStore.selectedTrailerModel && !dataStore.isPlaying {
                                dataStore.selectedTrailerModel = nil
                            }
                        })
                        /// It doesn't matter if the screensaver starts after exactly five minutes
                        timeout!.tolerance = 10
                    }
                    .transition(.opacity)
            } else {
                /// Logo moves around the screen
                Image("RatingLogo")
                    .resizable()
                    .frame(width: geo.size.height / 3, height: geo.size.height / 3)
                    .cornerRadius(geo.size.height / 20, antialiased: true)
                    .shadow(color: Color("TMTGreen"), radius: 20, x: 0, y: 0)
                    .onChange(of: fps.time) { _ in
                        withAnimation {
                            updateOffset(geo)
                        }
                    }
                    .offset(x: offset.x, y: offset.y)
                    .transition(.opacity)
            }
        }
        .background(Color.black)
        .colorScheme(.dark)
    }
    
    private func updateOffset(_ geo: GeometryProxy) {
        offset.add(direction.getVector())
        
        let minX: CGFloat = 0
        let maxX: CGFloat = geo.size.width - geo.size.height / 3
        let minY: CGFloat = 0
        let maxY: CGFloat = geo.size.height * 2 / 3
        let hitLeft = offset.x < minX
        let hitRight = offset.x > maxX
        let hitTop = offset.y < minY
        let hitBottom = offset.y > maxY
        
        let toggleUpDown = hitTop || hitBottom
        let toggleLeftRight = hitLeft || hitRight
        
        if toggleUpDown {
            direction = direction.flipVertically()
        }
        if toggleLeftRight {
            direction = direction.flipHorizontally()
        }
        
        /// update offset again to make sure we don't get stuck in an edge
        offset.add(direction.getVector())
    }
}
