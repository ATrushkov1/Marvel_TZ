//
//  RandomCollectionHeroViewCell.swift
//  FirstTZ
//
//  Created by Алексей Трушков on 22.12.2022.
//

import UIKit

class RandomCollectionHeroViewCell: UICollectionViewCell {
    
    let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setConstraints()
    }
    
    //MARK: - Methods
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .none
        addSubview(heroImageView)
    }
    
    func cellConfigure(model: HeroMarvelModel) {
        guard let url = model.thumbnail.url else {return}
        
        NetworkImageFetch.shared.requestImage(url: url) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                self.heroImageView.image = image
            case .failure(_):
                print("AlertHere")
            }
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
