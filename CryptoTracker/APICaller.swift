//
//  APICaller.swift
//  CryptoTracker
//
//  Created by Николай Никитин on 02.11.2021.
//

import Foundation
final class APICaller {

  //MARK: - Properties
  static let shared = APICaller()
  private struct Constants {
    static let apiKey = "?apikey=5466BCC8-853D-4128-A459-83CAAD871FEA"
    static let assetsEndPoint = "https://rest.coinapi.io/v1/assets"
    static let iconsEndPoint = "https://rest.coinapi.io/v1/assets/icons/55/"
  }
  public var icons: [Icon] = []
  private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
  private init () {}

  // MARK: - Public Methods

  /// Returns all data about coin from rest.coinapi.io
  /// - Parameter completion: Chech if icons array is empty then start to loads icons. It it's not empty, then make task to get data and returns array of cryptos with price more than 0.01
  public func getAllCryptoData(
    completion: @escaping (Result<[Crypto], Error>) -> Void
  ) {
    guard !icons.isEmpty else {
      whenReadyBlock = completion
      return
    }
    guard let url = URL(string: Constants.assetsEndPoint + Constants.apiKey) else { return }
    let task = URLSession.shared.dataTask(with: url) {data, _, error in
      guard let data = data, error == nil else { return }
      do {
        //Decode response
        let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
        completion(.success(
          cryptos
            .filter({ crypto -> Bool in
            guard let price = crypto.price_usd else { return false }
            return price >= 0.01
          })
            .sorted { first, second -> Bool in
            return first.price_usd ?? 0 > second.price_usd ?? 0
          }
        ))
      }
      catch {
        completion(.failure(error))
      }
    }
    task.resume()
  }


  /// Makes tast to get all icos url from api
  public func getAllIcons(){
    guard let url = URL(string: Constants.iconsEndPoint + Constants.apiKey) else {
      print ("No valid icon url")
      return }
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
      guard let data = data, error == nil else { return }
      do {
        self?.icons = try JSONDecoder().decode([Icon].self, from: data)
        if let completion = self?.whenReadyBlock {
          self?.getAllCryptoData(completion: completion)
        }
      }
      catch {
        print(error)
      }
    }
    task.resume()
  }
}

