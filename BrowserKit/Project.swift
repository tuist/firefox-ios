import ProjectDescription

let deploymentTargetsIOS = DeploymentTargets.iOS("15.0")
let deploymentTargetsMac = DeploymentTargets.macOS("12.0")
let deploymentTargetsIOSAndMac = DeploymentTargets.multiplatform(iOS: "15.0", macOS: "12.0")

let configurations: [Configuration] = [
    .debug(name: "Fennec", xcconfig: "../firefox-ios/Client/Configuration/Fennec.xcconfig"),
    .debug(name: "Fennec_Testing", xcconfig: "../firefox-ios/Client/Configuration/Fennec.xcconfig"),
    .debug(name: "Fennec_Enterprise", xcconfig: "../firefox-ios/Client/Configuration/Fennec.enterprise.xcconfig"),
    .release(name: "Firefox", xcconfig: "../firefox-ios/Client/Configuration/Firefox.xcconfig"),
    .release(name: "FirefoxBeta", xcconfig: "../firefox-ios/Client/Configuration/FirefoxBeta.xcconfig"),
    .release(name: "FirefoxStaging", xcconfig: "../firefox-ios/Client/Configuration/FirefoxStaging.xcconfig")
]

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0"
]

let projectSettings = Settings.settings(
    base: baseSettings,
    configurations: configurations,
    defaultSettings: .recommended
)

func targetSettings(additional: SettingsDictionary = [:]) -> Settings {
    var settings = baseSettings
    for (key, value) in additional {
        settings[key] = value
    }
    return .settings(
        base: settings,
        configurations: configurations,
        defaultSettings: .recommended
    )
}

func sourceFiles(_ path: String) -> SourceFilesList {
    .sourceFilesList(globs: [.glob(.relativeToManifest("\(path)/**/*.swift"))])
}

func frameworkTarget(
    name: String,
    destinations: Destinations = .iOS,
    deploymentTargets: DeploymentTargets = deploymentTargetsIOS,
    dependencies: [TargetDependency] = [],
    resources: ResourceFileElements? = nil
) -> Target {
    Target.target(
        name: name,
        destinations: destinations,
        product: .framework,
        bundleId: "org.mozilla.browserkit.\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        sources: sourceFiles("Sources/\(name)"),
        resources: resources,
        dependencies: dependencies,
        settings: targetSettings()
    )
}

func testTarget(
    name: String,
    dependencies: [TargetDependency],
    resources: ResourceFileElements? = nil,
    deploymentTargets: DeploymentTargets = deploymentTargetsIOS
) -> Target {
    Target.target(
        name: name,
        destinations: .iOS,
        product: .unitTests,
        bundleId: "org.mozilla.browserkit.\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        sources: sourceFiles("Tests/\(name)"),
        resources: resources,
        dependencies: dependencies,
        settings: targetSettings()
    )
}

let project = Project(
    name: "BrowserKit",
    settings: projectSettings,
    targets: [
        frameworkTarget(
            name: "Shared",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        frameworkTarget(
            name: "ComponentLibrary",
            dependencies: [
                .target(name: "Common"),
                .target(name: "SiteImageView")
            ]
        ),
        testTarget(
            name: "ComponentLibraryTests",
            dependencies: [
                .target(name: "ComponentLibrary")
            ]
        ),
        frameworkTarget(
            name: "SiteImageView",
            dependencies: [
                .external(name: "Fuzi"),
                .external(name: "Kingfisher"),
                .target(name: "Common"),
                .external(name: "SwiftDraw")
            ],
            resources: .resources([
                .glob(pattern: .relativeToManifest("Sources/SiteImageView/BundledTopSitesFavicons.xcassets"))
            ])
        ),
        testTarget(
            name: "SiteImageViewTests",
            dependencies: [
                .target(name: "SiteImageView"),
                .target(name: "TestKit"),
                .external(name: "GCDWebServers")
            ],
            resources: .resources([
                .glob(pattern: .relativeToManifest("Tests/SiteImageViewTests/Resources/*"))
            ])
        ),
        frameworkTarget(
            name: "Common",
            dependencies: [
                .external(name: "Dip"),
                .external(name: "SwiftyBeaver"),
                .external(name: "Sentry-Dynamic")
            ]
        ),
        testTarget(
            name: "CommonTests",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        frameworkTarget(
            name: "TabDataStore",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        testTarget(
            name: "TabDataStoreTests",
            dependencies: [
                .target(name: "TabDataStore"),
                .target(name: "TestKit")
            ]
        ),
        frameworkTarget(
            name: "Redux",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        testTarget(
            name: "ReduxTests",
            dependencies: [
                .target(name: "Redux")
            ]
        ),
        frameworkTarget(
            name: "WebEngine",
            dependencies: [
                .target(name: "Common"),
                .external(name: "GCDWebServers")
            ]
        ),
        testTarget(
            name: "WebEngineTests",
            dependencies: [
                .target(name: "WebEngine"),
                .target(name: "TestKit")
            ]
        ),
        frameworkTarget(name: "TestKit"),
        frameworkTarget(
            name: "ToolbarKit",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        testTarget(
            name: "ToolbarKitTests",
            dependencies: [
                .target(name: "ToolbarKit"),
                .target(name: "TestKit")
            ]
        ),
        frameworkTarget(
            name: "MenuKit",
            dependencies: [
                .target(name: "Common"),
                .target(name: "ComponentLibrary"),
                .target(name: "SiteImageView")
            ]
        ),
        testTarget(
            name: "MenuKitTests",
            dependencies: [
                .target(name: "MenuKit")
            ]
        ),
        frameworkTarget(
            name: "SummarizeKit",
            dependencies: [
                .target(name: "Common"),
                .target(name: "ComponentLibrary"),
                .external(name: "Down")
            ]
        ),
        testTarget(
            name: "SummarizeKitTests",
            dependencies: [
                .target(name: "SummarizeKit"),
                .target(name: "TestKit")
            ]
        ),
        frameworkTarget(
            name: "JWTKit",
            dependencies: [
                .target(name: "Common"),
                .target(name: "Shared")
            ]
        ),
        testTarget(
            name: "JWTKitTests",
            dependencies: [
                .target(name: "JWTKit")
            ]
        ),
        frameworkTarget(
            name: "UnifiedSearchKit",
            dependencies: [
                .target(name: "Common"),
                .target(name: "ComponentLibrary")
            ]
        ),
        frameworkTarget(
            name: "VoiceSearchKit",
            dependencies: [
                .target(name: "Common")
            ]
        ),
        testTarget(
            name: "VoiceSearchKitTests",
            dependencies: [
                .target(name: "VoiceSearchKit")
            ]
        ),
        frameworkTarget(
            name: "ContentBlockingGenerator",
            destinations: [.iPhone, .iPad, .mac],
            deploymentTargets: deploymentTargetsIOSAndMac
        ),
        testTarget(
            name: "ContentBlockingGeneratorTests",
            dependencies: [
                .target(name: "ContentBlockingGenerator")
            ]
        ),
        frameworkTarget(
            name: "OnboardingKit",
            dependencies: [
                .target(name: "Common"),
                .target(name: "ComponentLibrary"),
                .sdk(name: "Metal", type: .framework),
                .sdk(name: "MetalKit", type: .framework)
            ],
            resources: .resources([
                .glob(pattern: .relativeToManifest("Sources/OnboardingKit/Shaders/**")),
                .glob(pattern: .relativeToManifest("Sources/OnboardingKit/Media.xcassets"))
            ])
        ),
        testTarget(
            name: "OnboardingKitTests",
            dependencies: [
                .target(name: "OnboardingKit")
            ]
        ),
        frameworkTarget(name: "ActionExtensionKit"),
        testTarget(
            name: "ActionExtensionKitTests",
            dependencies: [
                .target(name: "ActionExtensionKit")
            ]
        ),
        Target.target(
            name: "ExecutableContentBlockingGenerator",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "org.mozilla.browserkit.ExecutableContentBlockingGenerator",
            deploymentTargets: deploymentTargetsMac,
            infoPlist: .default,
            sources: sourceFiles("Sources/ExecutableContentBlockingGenerator"),
            dependencies: [
                .target(name: "ContentBlockingGenerator")
            ],
            settings: targetSettings()
        )
    ],
    resourceSynthesizers: []
)
