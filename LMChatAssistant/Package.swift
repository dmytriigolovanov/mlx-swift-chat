// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LMChatAssistant",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "LMChatAssistant",
            targets: ["LMChatAssistant"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm/", branch: "main"),
    ],
    targets: [
        .target(
            name: "LMChatAssistant",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMCommon", package: "mlx-swift-lm"),
            ]
        ),
        .testTarget(
            name: "LMCAIntegrationTests",
            dependencies: ["LMChatAssistant"]
        ),
    ]
)
