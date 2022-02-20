//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Николай Никитин on 02.11.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

  //MARK: - Properties
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.identifier)
    return tableView
  }()

  private var viewModels = [CryptoTableViewCellViewModel]()

  private var filteredViewModels = [CryptoTableViewCellViewModel]()

  static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.allowsFloats = true
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.currencySymbol = "$"
    formatter.formatterBehavior = .default
    return formatter
  }()

  private let searchController = UISearchController()

  //MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Crypto Tracker"
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    APICaller.shared.getAllCryptoData{ [weak self] result in
      switch result {
      case .success(let models):
        self?.viewModels = models.compactMap({ model in
          //NumberFormatter
          let price = model.price_usd ?? 0
          let formatter = ViewController.numberFormatter
          let priceString = formatter.string(from: NSNumber(value: price))
          let iconUrl = URL(
            string:
              APICaller.shared.icons.filter({ icon in
                icon.asset_id == model.asset_id
              }).first?.url ?? ""
          )
          return CryptoTableViewCellViewModel(name: model.name ?? "N/A",
                                              symbol: model.asset_id,
                                              price: priceString ?? "N/A",
                                              iconUrl: iconUrl
          )
        })
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      case .failure(let error):
        print ("Error: \(error)")
      }
    }
    searchController.loadViewIfNeeded()
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.enablesReturnKeyAutomatically = false
    searchController.searchBar.returnKeyType = UIReturnKeyType.done
    definesPresentationContext = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.searchBar.delegate = self
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }

  //MARK: - Search methods
  func updateSearchResults(for searchController: UISearchController) {
    let searchText = searchController.searchBar.text!.replacingOccurrences(of: " ", with: "")
    filteredViewModels = viewModels.filter { model in
      if (searchText != "") {
        return model.symbol.lowercased().contains(searchText.lowercased())
      } else {
        return true
      }
    }
    tableView.reloadData()
  }


  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive {
      return filteredViewModels.count
    }
    return viewModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.identifier, for: indexPath) as? CryptoTableViewCell else { fatalError() }
    if (searchController.isActive) {
      cell.configure(with: filteredViewModels[indexPath.row])
    } else {
      cell.configure(with: viewModels[indexPath.row])
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

}

