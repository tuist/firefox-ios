import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        generationOptions: .options(enableCaching: true),
        cacheOptions: .options(
            keepSourceTargets: false,
            profiles: .profiles(default: .allPossible)
        )
    )
)
