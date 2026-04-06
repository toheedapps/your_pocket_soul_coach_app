// -----------------------------------------------------------
// 1. BUILDSCRIPT BLOCK (MUST COME FIRST AND INCLUDE REPOSITORIES)
// -----------------------------------------------------------
buildscript {
    repositories {
        google() // Google's repository is needed for 'google-services'
        mavenCentral()
    }
    dependencies {
        // You fixed this line to use Kotlin syntax
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// -----------------------------------------------------------
// 2. ALLPROJECTS BLOCK (FOR MODULE-LEVEL REPOSITORIES)
// -----------------------------------------------------------
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// -----------------------------------------------------------
// 3. OTHER CONFIGURATION
// -----------------------------------------------------------
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}