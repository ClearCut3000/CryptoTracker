//
//  Models.swift
//  CryptoTracker
//
//  Created by Николай Никитин on 02.11.2021.
//

import Foundation

struct Crypto: Codable{
  let asset_id: String
  let name: String?
  let price_usd: Float?
  let id_icon: String?
}

struct Icon: Codable{
  let asset_id: String
  let url: String
}
