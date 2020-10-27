// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "NordicDFU",
    platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "NordicDFU",
            targets: ["NordicDFU"]
        ),
        .executable(
            name: "dfutool",
            targets: ["dfutool"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothLinux.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/Zip.git",
            .branch("master")
        ),
    ],
    targets: [
        .target(
            name: "NordicDFU",
            dependencies: [
                "GATT",
                "ZIPFoundation"
            ]
        ),
        .target(
            name: "dfutool",
            dependencies: [
                "NordicDFU",
                "DarwinGATT",
                "BluetoothLinux"
            ]
        ),
        .testTarget(
            name: "NordicDFUTests",
            dependencies: [
                "NordicDFU"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
