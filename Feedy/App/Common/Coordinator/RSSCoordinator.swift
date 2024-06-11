//
//  RSSCoordinator.swift
//  Feedy
//
//  Created by Danijel Huis on 18.05.2024..
//

import Foundation
import SwiftUI
// Choose between PresentationMVI or PresentationMVVM.
import PresentationMVVM
import CommonUI

@MainActor struct RSSCoordinator {
    init() {}
    
    func view(_ route: RSSRoute, navigator: Navigator) -> RouteResult {
        switch route {
            
        case .list:
            let viewModel = RSSChannelListViewModel(getRSSChannelsUseCase: Container.sharedRSSManager,
                                                    removeRSSHistoryItemUseCase: Container.sharedRSSManager,
                                                    effectManager: EffectManager(),
                                                    coordinator: AppCoordinator(navigator: navigator))
            
            return .push(view: RSSChannelListView(viewModel: viewModel))
            
        case .add:
            let viewModel = AddRSSChannelViewModel(validateRSSChannelUseCase: Container.validateRSSChannelUseCase,
                                                   addRSSHistoryItemUseCase: Container.sharedRSSManager,
                                                   effectManager: EffectManager())
            viewModel.onFinished = {
                navigator.pop()
            }
            
            return .push(view: AddRSSChannelView(viewModel: viewModel))
            
        case .details(let rssHistoryItem, let channel):
            let viewModel = RSSChannelDetailsViewModel(rssHistoryItem: rssHistoryItem,
                                                       rssChannel: channel,
                                                       getRSSChannelsUseCase: Container.sharedRSSManager,
                                                       getRSSChannelUseCase: Container.rssRepository,
                                                       changeHistoryItemFavouriteStatusUseCase: Container.sharedRSSManager,
                                                       effectManager: EffectManager(),
                                                       coordinator: AppCoordinator(navigator: navigator))
            
            return .push(view: RSSChannelDetailsView(viewModel: viewModel))
        }
    }
}
