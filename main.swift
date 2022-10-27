// This code was adapted from https://github.com/Peter-Schorn/SpotifyAPIExamples
// 67-443 Team 12


import Foundation
import Combine
import SpotifyWebAPI

var cancellables: Set<AnyCancellable> = []
let dispatchGroup = DispatchGroup()

// Retrieve the client id and client secret from the environment variables.
let spotifyCredentials = getSpotifyCredentialsFromEnvironment()

let spotifyAPI = SpotifyAPI(
    authorizationManager: ClientCredentialsFlowManager(
        clientId: spotifyCredentials.clientId,
        clientSecret: spotifyCredentials.clientSecret
    )
)
// Authorize the application.
try spotifyAPI.authorizationManager.waitUntilAuthorized()

// MARK: - The Application is Now Authorized -

// MARK: Search for Tracks and Albums

dispatchGroup.enter()
spotifyAPI.search(
    query: "21 Savage",
    categories: [.track, .album],
    market: "US"
)
.sink(
    receiveCompletion: { completion in
        print("completion:", completion, terminator: "\n\n\n")
        dispatchGroup.leave()
    },
    receiveValue: { results in
        print("\nReceived results for search for '21 Savage'")
        let tracks = results.tracks?.items ?? []
        print("found \(tracks.count) tracks:")
        print("------------------------")
        for track in tracks {
            print("\(track.name) - \(track.album?.name ?? "nil")")
        }
        
        let albums = results.albums?.items ?? []
        print("\nfound \(albums.count) albums:")
        print("------------------------")
        for album in albums {
            print("\(album.name)")
        }
        
    }
)
.store(in: &cancellables)
dispatchGroup.wait()


// MARK: Retrieve a Playlist

// "21 21"
// https://open.spotify.com/playlist/676IeZjO6OH5NCfvlOWanw?si=bead7e2fcb9648a6
let playlistURI = "spotify:playlist:676IeZjO6OH5NCfvlOWanw?si=bead7e2fcb9648a6"

dispatchGroup.enter()
spotifyAPI.playlist(playlistURI, market: "US")
    .sink(
        receiveCompletion: { completion in
            print("completion:", completion, terminator: "\n\n\n")
            dispatchGroup.leave()
        },
        receiveValue: { playlist in
            
            print("\nReceived Playlist")
            print("------------------------")
            print("name:", playlist.name)
            print("link:", playlist.externalURLs?["spotify"] ?? "nil")
            print("description:", playlist.description ?? "nil")
            print("total tracks:", playlist.items.total)
            for track in playlist.items.items.compactMap(\.item) {
                print(track.name)
            }
            
        }
    )
    .store(in: &cancellables)
dispatchGroup.wait()


// MARK: Retrieve all the Episodes in a Show

// "The Psychology of your 20’s"
// https://open.spotify.com/show/2HGcJRYrjGnpce6bRp8UXm?si=e7158e8f5dcb4bf0
let showURI = "spotify:show:2HGcJRYrjGnpce6bRp8UXm?si=e7158e8f5dcb4bf0"

dispatchGroup.enter()
spotifyAPI.showEpisodes(showURI, market: "US", limit: 10)
    // Retrieve additional pages of results. In this case,
    // a total of three pages will be retrieved.
    .extendPages(spotifyAPI, maxExtraPages: 2)
    .sink(
        receiveCompletion: { completion in
            print("completion:", completion, terminator: "\n\n\n")
            dispatchGroup.leave()
        },
        receiveValue: { episodes in
            
            let currentPage = (episodes.offset / 10) + 1
            if currentPage == 1 {
                print("Received Show Episodes For The Psychology of your 20’s")
            }
            print("page \(currentPage) of results:")
            print("------------------------")
            for episode in episodes.items {
                print(episode.name)
            }
            print()

        }
    )
    .store(in: &cancellables)
dispatchGroup.wait()

// MARK: Retrieve New Album Releases

dispatchGroup.enter()
spotifyAPI.newAlbumReleases(country: "US")
    .sink(
        receiveCompletion: { completion in
            print("completion:", completion, terminator: "\n\n\n")
            dispatchGroup.leave()
        },
        receiveValue: { newAlbumReleases in
            print("\nReceive New Album Rleases")
            print("------------------------")
            //print("message:", newAlbumReleases.message ?? "nil")
            for album in newAlbumReleases.albums.items {
                print("\(album.name) - \(album.artists?.first?.name ?? "nil")")
            }
        }
    )
    .store(in: &cancellables)
dispatchGroup.wait()

// MARK: Artist Top Tracks

// "Beyonce"
// https://open.spotify.com/artist/6vWDO969PvNqNYHIOW5v0m?si=xulXJSuTQCiEOl-urv7SRw
let artistURI = "spotify:artist:6vWDO969PvNqNYHIOW5v0m?si=qMq5_V2BRzmI1d2Q587mOQ"


dispatchGroup.enter()
spotifyAPI.artistTopTracks(artistURI, country: "US")
    .sink(
        receiveCompletion: { completion in
            print("completion:", completion, terminator: "\n\n\n")
            dispatchGroup.leave()
        },
        receiveValue: { tracks in
            print("\nReceived top tracks for Beyonce:")
            print("------------------------")
            for track in tracks {
                print("\(track.name) - \(track.album?.name ?? "nil")")
            }
        }
    )
    .store(in: &cancellables)
dispatchGroup.wait()


//-----------------------------------------Zahir's Additional Calls------------------------------------------------


// MARK: Track Attributes

// "'87 Stingray'"
// https://open.spotify.com/track/17sPXQa8bT24ToCYHXuQXI?si=afa39fbdf2d249c9
let trackURI = "spotify:track:17sPXQa8bT24ToCYHXuQXI?si=afa39fbdf2d249c9"


dispatchGroup.enter()
spotifyAPI.trackAudioFeatures(trackURI)
		.sink(
				receiveCompletion: { completion in
						print("completion:", completion, terminator: "\n\n\n")
						dispatchGroup.leave()
				},
				receiveValue: { features in
						print("\nReceived audio features for '87 Stingray':")
						print("------------------------")
						print("Energy: " + String(features.energy))
						print("Danceability: " + String(features.danceability))
						print("Temp: " + String(features.tempo))
				}
		)
		.store(in: &cancellables)
dispatchGroup.wait()


// MARK: Recommendation

// Tracks
// "Love$ick - Mura Masa, A$AP Rocky"; "Fasion Killa - A$AP Rocky"; "Eastside - 99 Neighbors"
// "Redlight District - Lil Cobaine, Italian Leather"; "Churchill Downs - Jack Harlow, Drake"
// https://open.spotify.com/track/3sTN90bIP2cJ1783ctHykO?si=d6025c1d942d47cc
// https://open.spotify.com/track/0O3TAouZE4vL9dM5SyxgvH?si=46a2f81326a94d74
// https://open.spotify.com/track/6hp3OQ8ymKupyiuPVIzBMQ?si=283a675a581f4bba
// https://open.spotify.com/track/6Bv2Olo3PHPmOwzw0bz6YT?si=6b2ed1ee2584459d
// https://open.spotify.com/track/3EMp20j5E42MxfFbsEsIvD?si=81ac08cda8d4445f
let track1URI = "spotify:track:3sTN90bIP2cJ1783ctHykO?si=d6025c1d942d47cc"
let track2URI = "spotify:track:0O3TAouZE4vL9dM5SyxgvH?si=46a2f81326a94d74"
let track3URI = "spotify:track:6hp3OQ8ymKupyiuPVIzBMQ?si=283a675a581f4bba"
let track4URI = "spotify:track:6Bv2Olo3PHPmOwzw0bz6YT?si=6b2ed1ee2584459d"
let track5URI = "spotify:track:3EMp20j5E42MxfFbsEsIvD?si=81ac08cda8d4445f"

// Artists
// AJ Tracey
// https://open.spotify.com/artist/4Xi6LSfFqv26XgP9NKN26U?si=NIb4AuJbQuCEGrLytr5yWQ
let artist1URI = "spotify:artist:4Xi6LSfFqv26XgP9NKN26U?si=NIb4AuJbQuCEGrLytr5yWQ"

let attrbs: TrackAttributes
attrbs = TrackAttributes(seedArtists: [artist1URI],
												 seedTracks: [track1URI, track2URI, track3URI, track4URI, track5URI],
												 seedGenres: ["rap","summer"])

dispatchGroup.enter()
spotifyAPI.recommendations(attrbs)
		.sink(
				receiveCompletion: { completion in
						print("completion:", completion, terminator: "\n\n\n")
						dispatchGroup.leave()
				},
				receiveValue: { recs in
						print("\nReceived audio features for '87 Stingray':")
						print("------------------------")
					for rec in recs.tracks {
						print("\(rec.name)")
					}
				}
		)
		.store(in: &cancellables)
dispatchGroup.wait()
