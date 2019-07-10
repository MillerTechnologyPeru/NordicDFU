// swift-tools-version:5.0
import PackageDescription

_ = Package(
    name: "NordicDFU",
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
