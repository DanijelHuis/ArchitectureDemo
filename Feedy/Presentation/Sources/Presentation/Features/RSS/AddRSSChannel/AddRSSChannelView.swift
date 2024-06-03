//
//  AddRSSChannelView.swift
//  Feedy
//
//  Created by Danijel Huis on 17.05.2024..
//

import SwiftUI

@MainActor public struct AddRSSChannelView: View {
    @ObservedObject private var viewModel: ObservableSwiftUIViewModelOf<AddRSSChannelViewModel>
    @FocusState private var isURLTextFieldFocused: Bool
    
    public init(viewModel: ObservableSwiftUIViewModelOf<AddRSSChannelViewModel>) {
        self.viewModel = viewModel
        self.isURLTextFieldFocused = isURLTextFieldFocused
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.background2).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: .spacing.stackView) {
                // Top padding
                EmptyView()
                    .frame(height: .spacing.stackView)

                // Text field
                TextField(viewModel.state.placeholder,
                          text: viewModel.binding(\.channelURL, send: { .didChangeChannelURLText($0) }))
                .focused($isURLTextFieldFocused)
                .keyboardType(.URL)
                .textFieldStyle(Style.TextField.standard)
                .onSubmit {
                    viewModel.send(.didTapAddButton)
                }
                .accessibilityIdentifier("url_textfield")

                // Status (idle, validating, error)
                switch viewModel.state.status {
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
                Button(viewModel.state.buttonTitle) {
                    viewModel.send(.didTapAddButton)
                }
                .buttonStyle(Style.Button.action)
                .accessibilityIdentifier("add_button")
            }
            .padding(.spacing.quad)
            .disabled(viewModel.state.status == .validating)
        }
        .navigationTitle(viewModel.state.title)
        .navigationBarTitleDisplayMode(.inline)
        .onFirstAppear {
            isURLTextFieldFocused = true
        }
    }
}
