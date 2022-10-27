//
//  TrackStruct.swift
//  SpotifyAPIExamples
//
//  Created on 10/27/22.
//

import SpotifyWebAPI

struct TrackStruct {
	let name: String
	let album: String
	let artist: [Artist]
	let duration: Int
}
