# Theatrical Trailers
iOS 14 app written in SwiftUI that provides a nice movie trailer watching experience on iPhone and iPad, plus via AirPlay to Apple TV and AirPlay 2-compatible TVs. This app is available on [TestFlight](https://testflight.apple.com/join/Wnlesgzr).  

## Screenshots

On device:  
<img src="https://github.com/conath/TheatricalMovieTrailers/blob/main/Theatricals-CoverFlow.jpg?raw=true" alt="Screenshot of iOS interface showing a movie details screen, with (from top to bottom) title and poster image, as well as metadata visible." width="300"/>
<img src="https://github.com/conath/TheatricalMovieTrailers/blob/main/Theatricals-Search.jpg?raw=true" alt="Screenshot of iOS interface showing a movie details screen, with (from top to bottom) title and poster image, as well as metadata visible." width="300"/>

On TV (via AirPlay or adapter):  
![Screenshot of TV interface showing a movie poster on the left, the words "An Apple original" on the right in a video player, and metadata about a movie below.](Theatricals-AirPlay.jpg)

## Installation

This app is available on [TestFlight](https://testflight.apple.com/join/Wnlesgzr). It appears on your homescreen as "Theatricals".   


<img src="https://github.com/conath/TheatricalMovieTrailers/blob/main/TheatricalTrailersIcon.png?raw=true" alt="App Icon. It is a green color with small white text on it that is inspired by the MPAA trailer age rating panel that appears before American movie trailers." width="500"/>

To build from source, you need Xcode 12 and an Apple Developer account. Clone or download the repository, open the Xcode project and change the bunde identifier and development team. Then build and run.

## Use

The app presents a list of the latest movie trailers available from the iTunes Movie Trailers XML API.  
Tap on the Play button to start the trailer.

When an external screen is connected, the device displays only the poster artwork and play/pause button. The trailer video and related information for the now playing movie trailer is shown on the connected (AirPlay) screen.

## How to connect to a TV or external screen

On a real iOS device: use AirPlay Mirroring from Control Center or connect directly via a compatible adapter.

In the iOS Simulator: Click "I/O" in the menu bar, then choose any resolution under "External Displays".

## Contributing

Please feel free to submit a pull request if you would like to contribute to this project.   
The author does not actively monitor issues.  

## Copyright

See [License](LICENSE) for details about the source code license.

Two XML files from iTunes Movie Trailers are included with the project for reference and educational purposes. The [License](LICENSE) does not cover these XML files.

The Apple Logo, AirPlay, iOS, and iTunes are trademarks of Apple Inc., registered in the U.S. and other countries.  
Greyhound is © Copyright 1969-2020 Apple.
