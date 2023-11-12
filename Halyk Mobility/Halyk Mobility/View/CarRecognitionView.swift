//
//  CarRecognitionView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI
import PhotosUI
import UIKit

enum CarRecognitionError: Error {
    case notVerified
    case noPickedImage
    case nonBinaryResponse
}

struct CarRecognitionResponse {
    let image: Image
    let title: String
    let description: String
}

private enum Mocks {
    static let enterImage: Image = .init(systemName: "car")
    static let enterTitle: String = "Пройдите верификацию авто"
    static let enterDescription: String = "Нам нужно это для обеспечения безопасности \nи точности распознавания вашего автомобиля."
    static let loadingImage: Image = .init(systemName: "car.front.waves.up")
    static let loadingTitle: String = "Подождите"
    static let loadingDescription: String = "Идет проверка вашего авто. \nЭто может занять несколько минут."
    static let successImage: Image = .init(systemName: "car.side.lock.open")
    static let errorImage: Image = .init(systemName: "car.side.lock")
    static let successResponse: CarRecognitionResponse = .init(
        image: successImage,
        title: "Успешное распознование",
        description: "Автомобиль успешно определен. Результаты распознавания доступны для просмотра."
    )
    static let errorResponse: CarRecognitionResponse = .init(
        image: errorImage,
        title: "Машина не распознана",
        description: "Попробуйте еще раз или убедитесь, что изображение содержит автомобиль."
    )
}

struct CarRecognitionViewModel {
    func getStatus(with pickedImage: UIImage?, label: String) async -> CarRecognitionResponse {
        do {
            try await ingetStatus(with: pickedImage, label: label)

            return Mocks.successResponse
        } catch {
            guard let error = error as? CarRecognitionError else {
                return Mocks.errorResponse
            }

            return Mocks.errorResponse
        }
    }

    private func ingetStatus(with image: UIImage?, label: String) async throws -> Void {
        guard let image else {
            throw CarRecognitionError.noPickedImage
        }
        print("start get text")

        do {
            let response = try await carRecognitionProvider.getImageLabeling(image: image, label: label)

            if response == "verified" {
                return
            } else if response == "not verified" {
                throw CarRecognitionError.notVerified
            } else {
                throw CarRecognitionError.nonBinaryResponse
            }
        }
        catch {
            throw error
        }
    }

    private let networkClient = NetworkClient()
    private var carRecognitionProvider: CarRecognitionProvider {
        AppManager(networkClient: networkClient)
    }
}

struct CarRecognitionView: View {
    @State private var viewModel = CarRecognitionViewModel()

    @State private var isPresentedImagePicker = false

    @State private var pickedPickerItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?
    @State private var imageLabel: String = ""

    @State private var isLoading = false
    @State private var response: CarRecognitionResponse?

    var body: some View {
        VStack {
            if isLoading {
                CarRecognitionLoadingView(didTap: reset)
            } else if let response {
                CarRecognitionResponseView(didTap: reset, response: response)
            } else if let pickedImage {
                CarRecognitionPickedImageView(
                    imageLabel: $imageLabel,
                    didTap: { get() },
                    image: pickedImage
                )
            } else {
                CarRecognitionEnterView(
                    pickedItem: $pickedPickerItem
                )
                .onChange(of: pickedPickerItem) {
                    Task {
                        guard
                            let data = try? await pickedPickerItem?.loadTransferable(type: Data.self),
                            let uiImage = UIImage(data: data)
                        else {
                            print("Failed")
                            return
                        }

                        pickedImage = uiImage
                    }
                }
            }
        }
        .animation(.easeInOut)
    }

    private func reset() {
        isLoading = false
        response = nil
        pickedImage = nil
        pickedPickerItem = nil
    }

    private func get() {
        isLoading = true
        Task {
            response = await viewModel.getStatus(with: pickedImage, label: imageLabel)
            isLoading = false
        }
    }
}

struct CarRecognitionEnterView: View {
    @Binding var pickedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            CarRecognitionInfoView(image: Mocks.enterImage, title: Mocks.enterTitle, description: Mocks.enterDescription)

            Spacer()

            PhotosPicker(selection: $pickedItem) {
                Text("Загрузить")
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.accentColor)
            .cornerRadius(32)
            .padding()
        }
    }
}

struct CarRecognitionBottomView: View {
    let didTap: () -> Void

    let title: String
    var isEnabledButton: Bool = true

    var body: some View {
        Button(action: didTap) {
            Text(title)
                .foregroundColor(.white)
                .padding()
        }
        .disabled(!isEnabledButton)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.accentColor)
        .cornerRadius(32)
    }
}

struct CarRecognitionInfoView: View {
    let image: Image
    let title: String
    let description: String

    var animatingAppearance: Bool = false
    var animatingVariableColor: Bool = false

    @State private var appeared = false

    private var imageView: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .foregroundColor(Color.accentColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            if animatingAppearance {
                imageView
                    .symbolEffect(.bounce, value: appeared)
            } else if animatingVariableColor {
                imageView
                    .symbolEffect(.variableColor.iterative, options: .repeating, isActive: animatingVariableColor)
            } else {
                imageView
            }

            Spacer().frame(height: 32)
            Text(title)
                .font(.title)
                .foregroundColor(.primary)

            Spacer().frame(height: 8)
            Text(description)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .onAppear {
            appeared = true
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CarRecognitionResponseView: View {
    let didTap: () -> Void

    let response: CarRecognitionResponse

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                CarRecognitionInfoView(
                    image: response.image,
                    title: response.title,
                    description: response.description,
                    animatingAppearance: true
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
            CarRecognitionBottomView(didTap: didTap, title: "Попробовать еще раз")
        }
        .padding()
    }
}

struct CarRecognitionPickedImageView: View {
    @Binding var imageLabel: String

    let didTap: () -> Void
    let image: UIImage

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(16)

                Spacer().frame(height: 24)
                ZStack {
                    Color.gray.opacity(0.1)
                        .cornerRadius(12)

                    TextField("Введите название авто", text: $imageLabel)
                        .padding()
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
            CarRecognitionBottomView(didTap: didTap, title: "Проверить")
                .disabled(imageLabel.isEmpty)
        }
        .padding()
    }
}

struct CarRecognitionLoadingView: View {
    let didTap: () -> Void

    var body: some View {
        VStack {
            VStack(alignment: .center) {
                CarRecognitionInfoView(
                    image: Mocks.loadingImage,
                    title: Mocks.loadingTitle,
                    description: Mocks.loadingDescription,
                    animatingVariableColor: true
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
            CarRecognitionBottomView(didTap: didTap, title: "Отменить")
        }
        .padding()
    }
}

#Preview {
    CarRecognitionView()
}
