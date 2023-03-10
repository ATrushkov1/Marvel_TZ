//
//  MainViewController.swift
//  FirstTZ
//
//  Created by Алексей Трушков on 19.12.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    private let heroCollectionView: UICollectionView = {
        let layot = UICollectionViewFlowLayout()
        layot.minimumLineSpacing = 1
        layot.minimumInteritemSpacing = 1
        layot.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layot)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let searchController = UISearchController()
    private var heroesArray = [HeroMarvelModel]()
    private let idCollectionView = "idCollectionView"
    private var isFiltred = false
    private var filtredArray = [IndexPath]()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getHeroArray()
        setupViews()
        setupNavigationBar()
        setDelegate()
        setConstraints()
    }
    
    //MARK: - Methods
    private func getHeroArray() {
        NetworkDataFetch.shared.fetchHero { [weak self] heroMarvelArray, error in
            guard let self = self else {return}
            if error != nil {
                print("MainVC NetworkDataFetch error: \(String (describing: error?.localizedDescription))")
            } else {
                guard let heroMarvelArray = heroMarvelArray else {return}
                self.heroesArray = heroMarvelArray
                self.heroCollectionView.reloadData()
            }
        }
    }
    
    private func setupNavigationBar() {
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.backButtonTitle = ""
        
        navigationItem.titleView = createCustomTitleView()
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(heroCollectionView)
        heroCollectionView.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: idCollectionView)
    }
    
    private func setDelegate() {
        heroCollectionView.dataSource = self
        heroCollectionView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    private func setAlphaForCell(alpha: Double) {
        heroCollectionView.visibleCells.forEach { cell in
            cell.alpha = alpha
        }
    }
    
    private func createCustomTitleView() -> UIView {
        let view = UIView()
        let heightNavBar = navigationController?.navigationBar.frame.height ?? 0
        let widthNavBar = navigationController?.navigationBar.frame.width ?? 0
        
        view.frame = CGRect(x: 0, y: 0, width: widthNavBar, height: heightNavBar - 10)
        
        let marvelImageView = UIImageView()
        marvelImageView.image = UIImage(named: "marvelLogo")
        marvelImageView.contentMode = .left
        marvelImageView.frame = CGRect(x: 10, y: 0, width: widthNavBar, height: heightNavBar / 2)
        
        view.addSubview(marvelImageView)
        return view
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        heroesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCollectionView, for: indexPath) as? HeroCollectionViewCell else { return UICollectionViewCell() }
        let heroModel = heroesArray[indexPath.row]
        cell.cellConfigure(model: heroModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let heroModel = heroesArray[indexPath.row]
        let detailHeroViewController = DetailsHeroViewController()
        detailHeroViewController.heroModel = heroModel
        detailHeroViewController.heroesArray = heroesArray
        navigationController?.pushViewController(detailHeroViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isFiltred {
            cell.alpha = (filtredArray.contains(indexPath) ? 1 : 0.3)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 3.02,
               height: collectionView.frame.width / 3.02)
    }
}

// MARK: - UISerchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        filterContentForSearchText(text)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        for (value, hero) in heroesArray.enumerated() {
            let indexPath: IndexPath = [0, value]
            guard let cell = heroCollectionView.cellForItem(at: indexPath) else { return }
            
            if hero.name.lowercased().contains(searchText.lowercased()) {
                filtredArray.append(indexPath)
                cell.alpha = 1
            } else {
                cell.alpha = 0.3
            }
        }
    }
}

// MARK: - UISearchControllerDelegate
extension MainViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        isFiltred = true
        setAlphaForCell(alpha: 0.3)
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        isFiltred = false
        setAlphaForCell(alpha: 1)
    }
}

// MARK: - setConstraints

extension MainViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            heroCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            heroCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
