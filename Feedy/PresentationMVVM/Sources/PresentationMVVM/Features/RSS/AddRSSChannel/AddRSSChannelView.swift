//
//  AddRSSChannelView.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import SwiftUI
import CommonUI

@MainActor public struct AddRSSChannelView: View {
    @Bindable private var viewModel: AddRSSChannelViewModel // Using new @Bindable for iOS 17 @Observable
    @FocusState private var isURLTextFieldFocused: Bool
    
    public init(viewModel: AddRSSChannelViewModel) {
        self.viewModel = viewModel
        self.isURLTextFieldFocused = true
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.background2.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: .spacing.stackView) {
                // Top padding
                EmptyView()
                    .frame(height: .spacing.stackView)
                
                // Text field
                // MVVM allows us to directly mutate channelURL from here (two way binding).
                TextField(viewModel.placeholder, text: $viewModel.channelURL)
                .focused($isURLTextFieldFocused)
                .keyboardType(.URL)
                .textFieldStyle(Style.TextField.standard)
                .onSubmit {
                    viewModel.didTapAddButton()
                }
                .accessibilityIdentifier("url_textfield")
                
                // Status (idle, validating, error)
                switch viewModel.status {
                case .idle: EmptyView()
                case .validating:
                    ProgressView()
                        .progressViewStyle(Style.ProgressView.standard)
                case .error(let message):
                    Text(message)
                        .textStyle(Style.Text.error1)
                        .accessibilityIdentifier("error_text")
                }
                
                // Add button
                Button(viewModel.buttonTitle) {
                    viewModel.didTapAddButton()
                }
                .buttonStyle(Style.Button.action)
                .accessibilityIdentifier("add_button")
                
                // @TODO just for testing
                /*VStack {
                    Button("Sky news") {
                        // In MVVM it is "acceptable" to mutate property directly from view, same as two-way binding.
                        viewModel.channelURL = "https://feeds.skynews.com/feeds/rss/world.xml"
                    }
                    Button("BBC") {
                        viewModel.channelURL = "https://feeds.bbci.co.uk/news/world/rss.xml"
                    }
                    Button("Bug.hr") {
                        viewModel.channelURL = "https://bug.hr/rss"
                    }
                    Button("Index.hr") {
                        viewModel.channelURL = "https://index.hr/rss"
                    }
                }*/
            }
            .padding(.spacing.quad)
            .disabled(viewModel.status == .validating)
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .onFirstAppear {
            isURLTextFieldFocused = true
        }
    }
}
