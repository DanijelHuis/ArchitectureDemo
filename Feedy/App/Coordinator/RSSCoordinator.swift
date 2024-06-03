//
//  RSSCoordinator.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI
import Presentation

@MainActor struct RSSCoordinator {
    init() {}
    
    func view(_ route: RSSRoute, navigator: Navigator) -> RouteResult {
        switch route {
            
        case .list:
            let viewModel = RSSChannelListViewModel(getRSSHistoryItemsUseCase: Container.sharedRSSHistoryManager,
                                                    removeRSSHistoryItemUseCase: Container.sharedRSSHistoryManager,
                                                    getRSSChannelsUseCase: Container.getRSSChannelsUseCase,
                                                    effectManager: SideEffectManager(),
                                                    coordinator: AppCoordinator(navigator: navigator))
            
            return .push(view: RSSChannelListView(viewModel: .init(viewModel: viewModel)))
            
        case .add:
            let viewModel = AddRSSChannelViewModel(validateRSSChannelUseCase: Container.validateRSSChannelUseCase,
                                                   addRSSHistoryItemUseCase: Container.sharedRSSHistoryManager,
                                                   effectManager: SideEffectManager())
            viewModel.onFinished = {
                navigator.pop()
            }
            
            return .push(view: AddRSSChannelView(viewModel: .init(viewModel: viewModel)))
            
        case .details(let rssHistoryItem, let channel):
            let viewModel = RSSChannelDetailsViewModel(rssHistoryItem: rssHistoryItem,
                                                       rssChannel: channel,
                                                       getRSSHistoryItemsUseCase: Container.sharedRSSHistoryManager,
                                                       getRSSChannelUseCase: Container.rssRepository,
                                                       changeHistoryItemFavouriteStatusUseCase: Container.sharedRSSHistoryManager,
                                                       updateLastReadItemIDUseCase: Container.sharedRSSHistoryManager,
                                                       effectManager: SideEffectManager(),
                                                       coordinator: AppCoordinator(navigator: navigator))
            
            return .push(view: RSSChannelDetailsView(viewModel: .init(viewModel: viewModel)))
        }
    }
}
