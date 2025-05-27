pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stag', 'prod'],
            description: 'Select build environment'
        )
        choice(
            name: 'BUILD_TYPE',
            choices: ['debug', 'release'],
            description: 'Select build type'
        )
        booleanParam(
            name: 'CLEAN_BUILD',
            defaultValue: true,
            description: 'Clean project before building'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run tests before building'
        )
    }
    
    environment {
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/opt/android-sdk'
        PATH = "${env.FLUTTER_HOME}/bin:${env.ANDROID_HOME}/tools:${env.ANDROID_HOME}/platform-tools:${env.PATH}"
        GRADLE_OPTS = "-Dorg.gradle.daemon=false -Dorg.gradle.parallel=true -Dorg.gradle.configureondemand=true"
        JAVA_OPTS = "-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup Environment') {
            steps {
                sh '''
                    flutter --version
                    flutter pub get
                '''
            }
        }
        
        stage('Setup Gradle') {
            steps {
                sh '''
                    # Check if Gradle is installed
                    if ! command -v gradle &> /dev/null; then
                        echo "Gradle is not installed. Installing Gradle..."
                        sudo apt-get update
                        sudo apt-get install -y gradle
                    fi
                    
                    # Check if gradlew exists, if not generate it
                    cd android
                    if [ ! -f gradlew ]; then
                        echo "Gradle wrapper not found. Generating..."
                        gradle wrapper
                    fi
                    
                    # Set execute permissions
                    chmod +x gradlew
                    
                    # Verify Gradle wrapper
                    ./gradlew --version
                    cd ..
                '''
            }
        }
        
        stage('Get Version') {
            steps {
                script {
                    def pubspec = readFile('pubspec.yaml')
                    def versionMatch = pubspec =~ /version:\s*([\d.]+)\+(\d+)/
                    if (versionMatch.find()) {
                        env.VERSION_NAME = versionMatch.group(1)
                        env.VERSION_CODE = versionMatch.group(2)
                        echo "Found version: ${env.VERSION_NAME}+${env.VERSION_CODE}"
                    } else {
                        error "Could not find version in pubspec.yaml"
                    }
                }
            }
        }
        
        stage('Run Tests') {
            when {
                expression { return params.RUN_TESTS }
            }
            steps {
                sh '''
                    flutter test
                '''
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def buildCommand = "flutter build apk"
                    
                    // Add build type
                    if (params.BUILD_TYPE == 'release') {
                        buildCommand += " --release"
                    }
                    
                    // Add flavor
                    buildCommand += " --flavor ${params.ENVIRONMENT} -t lib/main_${params.ENVIRONMENT}.dart"
                    
                    // Add version info
                    buildCommand += " --build-name=${env.VERSION_NAME} --build-number=${env.VERSION_CODE}"
                    
                    // Clean if requested
                    if (params.CLEAN_BUILD) {
                        sh "flutter clean"
                    }
                    
                    // Execute build with timeout
                    timeout(time: 30, unit: 'MINUTES') {
                        sh """
                            cd android
                            ./gradlew clean
                            cd ..
                            ${buildCommand} --verbose
                        """
                    }
                }
                archiveArtifacts artifacts: "build/app/outputs/flutter-apk/app-${params.ENVIRONMENT}-${params.BUILD_TYPE}.apk", fingerprint: true
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo """
                Build completed successfully!
                Environment: ${params.ENVIRONMENT.toUpperCase()}
                Build Type: ${params.BUILD_TYPE.toUpperCase()}
                Version: ${env.VERSION_NAME}+${env.VERSION_CODE}
            """
        }
        failure {
            echo """
                Build failed!
                Environment: ${params.ENVIRONMENT.toUpperCase()}
                Build Type: ${params.BUILD_TYPE.toUpperCase()}
                Version: ${env.VERSION_NAME}+${env.VERSION_CODE}
            """
        }
    }
} 