import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.retrotrix.tetrofit.dev"
            resValue(type = "string", name = "app_name", value = "RetroTrixDev")
        }
        create("stag") {
            dimension = "flavor-type"
            applicationId = "com.retrotrix.tetrofit.stag"
            resValue(type = "string", name = "app_name", value = "RetroTrixStag")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.retrotrix.tetrofit"
            resValue(type = "string", name = "app_name", value = "RetroTrix")
        }
    }
}