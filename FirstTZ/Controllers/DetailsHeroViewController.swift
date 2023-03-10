//
//  DetailHeroViewController.swift
//  FirstTZ
//
//  Created by Алексей Трушков on 22.12.2022.
//

import UIKit

class DetailsHeroViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageHeroView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let detailTextLabel: UILabel = {
        let text = UILabel()
        text.font = UIFont.systemFont(ofSize: 14)
        text.textColor = .white
        text.numberOfLines = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let exploreMoreLabel: UILabel = {
        let text = UILabel()
        text.text = "Explore More"
        text.textColor = .white
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let randomCollectionHeroCell: UICollectionView = {
        let layot = UICollectionViewFlowLayout()
        layot.minimumLineSpacing = 16
        layot.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layot)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let idRandomHeroCollectionView = "idRandomHeroCollectionView"
    
    var heroModel: HeroMarvelModel?
    var randomHeroesArray: [HeroMarvelModel] = []
    var heroesArray = [HeroMarvelModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupHeroInfo()
        getRandomHeroes()
        setDelegates()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        view.addSubview(imageHeroView)
        view.addSubview(detailTextLabel)
        view.addSubview(exploreMoreLabel)
        view.addSubview(randomCollectionHeroCell)

        navigationController?.navigationBar.tintColor = .white
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        randomCollectionHeroCell.register(RandomCollectionHeroViewCell.self, forCellWithReuseIdentifier: idRandomHeroCollectionView)
        
        let textMultiplier = 12.5
        exploreMoreLabel.font = UIFont.systemFont(ofSize: view.frame.width / textMultiplier)
    }
    
    private func setupHeroInfo() {
        guard let heroModel = heroModel else {return}
        title = heroModel.name
        detailTextLabel.text = heroModel.description
        if detailTextLabel.text == "" {
            detailTextLabel.text = "Информация об этом персонаже секретна."
        }
        
        guard let url = heroModel.thumbnail.url else {return}
        NetworkImageFetch.shared.requestImage(url: url) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                self.imageHeroView.image = image
            case.failure(let error):
                print("DetailsVC error: \(error.localizedDescription)")
            }
        }
    }
    func unique<S : Sequence, T: Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    private func getRandomHeroes() {
        while randomHeroesArray.count < 8 {
            let randomInt = Int.random(in: 0...heroesArray.count - 1)
            randomHeroesArray.append(heroesArray[randomInt])
            let sortArt = unique(source: randomHeroesArray)
            randomHeroesArray = sortArt
        }
    }
    
    private func setDelegates() {
        randomCollectionHeroCell.dataSource = self
        randomCollectionHeroCell.delegate = self
    }
    
}

// MARK: - UICollectionViewDataSource

extension DetailsHeroViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomHeroesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idRandomHeroCollectionView,
                                                            for: indexPath)
                as? RandomCollectionHeroViewCell else { return UICollectionViewCell() }
        
        let heroModel = randomHeroesArray[indexPath.row]
        cell.cellConfigure(model: heroModel)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension DetailsHeroViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let heroModel = randomHeroesArray[indexPath.row]
        
        let detailHeroViewController = DetailsHeroViewController()
        detailHeroViewController.heroModel = heroModel
        detailHeroViewController.heroesArray = heroesArray
        navigationController?.pushViewController(detailHeroViewController, animated: true)
    }
}

extension DetailsHeroViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.height,
               height: collectionView.frame.height)
    }
}

// MARK: - setConstraint

extension DetailsHeroViewController {
    
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
            imageHeroView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageHeroView.widthAnchor.constraint(equalToConstant: view.frame.width),
            imageHeroView.heightAnchor.constraint(equalToConstant: view.frame.width),
        
            detailTextLabel.topAnchor.constraint(equalTo: imageHeroView.bottomAnchor, constant: 16),
            detailTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        
            exploreMoreLabel.topAnchor.constraint(equalTo: detailTextLabel.bottomAnchor, constant: 16),
            exploreMoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exploreMoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exploreMoreLabel.bottomAnchor.constraint(equalTo: randomCollectionHeroCell.topAnchor, constant: -5),
        
            randomCollectionHeroCell.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            randomCollectionHeroCell.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            randomCollectionHeroCell.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),
            randomCollectionHeroCell.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10)])
    }
}
