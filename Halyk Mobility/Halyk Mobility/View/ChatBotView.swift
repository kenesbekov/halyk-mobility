//
//  ChatBotView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI

enum ChatBotError: Error {
    case noChatID
}

struct ChatBotViewModel {
    mutating func create() async throws -> Void {
        guard chatID == nil else {
            return
        }

        let chatID = try await provider.create()
        self.chatID = chatID
    }

    func sendMessage(with message: ChatMessage) async throws -> SendMessageResponse {
        guard let chatID else {
            throw ChatBotError.noChatID
        }

        print("CHAT ID:", chatID)

        let request: SendMessageRequest = .init(chatId: chatID, message: message)
        return try await provider.sendMessage(with: request)
    }

    private var chatID: ChatID?

    private let networkClient = NetworkClient()
    private var provider: ChatBotProvider {
        AppManager(networkClient: networkClient)
    }
}

struct ChatBotView: View {
    @State private var viewModel: ChatBotViewModel = .init()

    @State private var inputText: String = ""
    @State private var items: [ChatBotHistory.Item] = []

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    ForEach(items, id: \.id) { item in
                        ChatBubble(item: item)
                    }
                }
                .padding(.top, 16)
            }
            .onAppear {
                Task {
                    do {
                        try await viewModel.create()
                    } catch {
                        addBotMessage("Error")
                        print(error.localizedDescription)
                    }
                }
            }

            HStack {
                ZStack {
                    Color.gray.opacity(0.1)
                        .cornerRadius(12)

                    TextField("Введите запрос", text: $inputText)
                        .padding()
                }
                .fixedSize(horizontal: false, vertical: true)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane")
                        .foregroundColor(.white)
                }
                .frame(width: 50, height: 50)
                .background(
                    Color.accentColor
                        .cornerRadius(12)
                )
            }
            .cornerRadius(12)
            .padding(.top, 4)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }

        addItem(.init(roleKind: .user, message: inputText))
        addUserMessage(inputText)
        inputText = ""
    }

    private func addUserMessage(_ message: ChatMessage) {
        Task {
            do {
                let response = try await viewModel.sendMessage(with: message)
                addBotMessage(response.message)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }

    private func addBotMessage(_ message: ChatMessage) {
        addItem(.init(roleKind: .chatBot, message: message))
    }

    private func addItem(_ item: ChatBotHistory.Item) {
        items.append(item)
    }
}

struct ChatBubble: View {
    let item: ChatBotHistory.Item
    let isError: Bool = false

    private var text: some View {
        Text(item.message)
            .padding(12)
    }

    private var spacer: some View {
        Spacer().frame(width: 40)
    }

    private var isChatBot: Bool {
        item.roleKind == .chatBot
    }

    var body: some View {
        HStack {
            if !isChatBot {
                spacer
            }

            ZStack(alignment: isChatBot ? .leading : .trailing) {
                Color.clear

                text
                    .background(
                        Color.gray.opacity(0.2)
                            .cornerRadius(12)
                    )
            }

            if isChatBot {
                spacer
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

#Preview {
    NavigationView {
        ChatBotView()
    }
}
