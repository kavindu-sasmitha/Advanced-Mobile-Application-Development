allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ මේ ක්‍රමයෙන් :app එක මඟඇරලා, Agora වගේ ප්ලගින්ස් වල compileSdk එක විතරක් 36 ට ලොක් කරනවා
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            if (project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")) {
                val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
                // ✅ compileSdk එක 36 කරන එක විතරක් තියන්න, අනිත් කුණු කෑලි අයින් කරන්න
                android?.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}