// swift-tools-version:5.3
import PackageDescription

#if os(Linux)
let libraryType: PackageDescription.Product.Library.LibraryType = .dynamic
#else
let libraryType: PackageDescription.Product.Library.LibraryType = .static
#endif

let package = Package(
    name: "NordicDFU",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "NordicDFU",
            type: libraryType,
            targets: ["NordicDFU"]
        ),
        .executable(
            name: "dfutool",
            targets: ["dfutool"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Bluetooth.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/GATT.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothLinux.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/PureSwift/BluetoothDarwin.git",
            .branch("master")
        ),
        .package(
            name: "ZIPFoundation",
            url: "https://github.com/PureSwift/Zip.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "NordicDFU",
            dependencies: [
                "Bluetooth",
                "GATT",
                "ZIPFoundation"
            ]
        ),
        .target(
            name: "dfutool",
            dependencies: [
                "NordicDFU",
                "Bluetooth",
                .product(
                    name: "BluetoothGAP",
                    package: "Bluetooth"
                ),
                .product(
                    name: "BluetoothGATT",
                    package: "Bluetooth"
                ),
                .product(
                    name: "BluetoothHCI",
                    package: "Bluetooth"
                ),
                .product(
                    name: "BluetoothLinux",
                    package: "BluetoothLinux",
                    condition: .when(platforms: [.linux])
                ),
                .product(
                    name: "DarwinGATT",
                    package: "GATT",
                    condition: .when(platforms: [.macOS])
                ),
                .product(
                    name: "BluetoothDarwin",
                    package: "BluetoothDarwin",
                    condition: .when(platforms: [.macOS])
                )
            ]
        ),
        .testTarget(
            name: "NordicDFUTests",
            dependencies: [
                "NordicDFU"
            ]
        )
    ]
)
