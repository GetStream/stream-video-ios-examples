//
//  ParticipantsView.swift
//  AudioRooms-UIKit
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import Foundation
import UIKit
import StreamVideo
import Combine

final class ParticipantsView: UIView {

    private enum ParticipantsListSection: Int {
        case speakers
        case listeners
    }

    var content: [CallParticipant] = [] {
        didSet { updateContent() }
    }

    private lazy var collectionViewDatasource: UICollectionViewDiffableDataSource<ParticipantsListSection, CallParticipant.ID> = makeDataSource()

    private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: makeCompositionalLayout())
        .withoutTranslatesAutoresizingMaskIntoConstraints()

    private let call: Call
    private var cancellables: Set<AnyCancellable> = []

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    init(call: Call) {
        self.call = call

        super.init(frame: .zero)

        addSubview(collectionView)
        collectionView.pin(to: self)

        collectionView.dataSource = collectionViewDatasource
        collectionView.register(
            ParticipantCollectionViewCell.self,
            forCellWithReuseIdentifier: "ParticipantCollectionViewCell"
        )

        collectionView.register(
            ParticipantsListHeader.self,
            forSupplementaryViewOfKind: "ParticipantsListHeader",
            withReuseIdentifier: "ParticipantsListHeader"
        )

        subscribeToParticipantsUpdates()

        updateContent()
    }

    func updateContent() {
        guard !content.isEmpty else {
            loadSnapshot(speakers: [], listeners: [])
            return
        }

        var speakers: [CallParticipant] = []
        var listeners: [CallParticipant] = []

        content.forEach {
            if $0.hasAudio { speakers.append($0) }
            else { listeners.append($0) }
        }

        loadSnapshot(speakers: speakers, listeners: listeners)
    }

    private func loadSnapshot(
        speakers: [CallParticipant],
        listeners: [CallParticipant]
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<ParticipantsListSection, CallParticipant.ID>()
        var sections = [ParticipantsListSection]()
        if !speakers.isEmpty { sections.append(.speakers) }
        if !listeners.isEmpty { sections.append(.listeners) }
        snapshot.appendSections(sections)

        if !speakers.isEmpty {
            snapshot.appendItems(speakers.map(\.id), toSection: .speakers)
        }

        if !listeners.isEmpty {
            snapshot.appendItems(listeners.map(\.id), toSection: .listeners)
        }
        collectionViewDatasource.applySnapshotUsingReloadData(snapshot)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<ParticipantsListSection, CallParticipant.ID> {
        // Create a cell registration that the diffable data source will use.
        let cellRegistration = UICollectionView.CellRegistration<ParticipantCollectionViewCell, CallParticipant> {
            cell, indexPath, item in
            cell.content = item
        }

        // Create the diffable data source and its cell provider.
        let datasource: UICollectionViewDiffableDataSource<ParticipantsListSection, CallParticipant.ID> = UICollectionViewDiffableDataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, identifier -> UICollectionViewCell in
            let participant = self.content.first { $0.id == identifier }!
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: participant
            )
        }

        datasource.supplementaryViewProvider = { [weak self] collectionView, identifier, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "ParticipantsListHeader",
                withReuseIdentifier: "ParticipantsListHeader",
                for: indexPath
            ) as? ParticipantsListHeader
            else {
                return UICollectionReusableView()
            }

            let hasSpeakers = self?.content.first { $0.hasAudio } != nil
            headerView.content = indexPath.section == 0 && hasSpeakers ? "Speakers" : "Listeners"
            return headerView
        }

        return datasource
    }

    private func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize =
        NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.15)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )

        section.boundarySupplementaryItems = [
            .init(layoutSize: headerSize, elementKind: "ParticipantsListHeader", alignment: .top)
        ]

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func subscribeToParticipantsUpdates() {
        call.state
            .$participants
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.content = $0 }
            .store(in: &cancellables)
    }
}

extension CallParticipant: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
