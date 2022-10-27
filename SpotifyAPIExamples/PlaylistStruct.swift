//
//  PlaylistStruct.swift
//  SpotifyAPIExamples
//
//  Created on 10/27/22.
//

import SpotifyWebAPI
import Foundation

struct PlaylistStruct {
	let name: String
	let description: String
	let totalTracks: Int
	let items: [PlaylistItem]
}

