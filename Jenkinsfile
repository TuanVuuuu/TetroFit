pipeline {
    agent any
    
    environment {
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/opt/android-sdk'
        PATH = "${env.PATH}:${env.FLUTTER_HOME}/bin:${env.ANDROID_HOME}/tools:${env.ANDROID_HOME}/platform-tools"
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
                    export PATH="${env.PATH}"
                    flutter --version
                    flutter pub get
                '''
            }
        }
        
        stage('Build Dev') {
            steps {
                sh '''
                    export PATH="${env.PATH}"
                    flutter build apk --flavor dev -t lib/main_dev.dart
                '''
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-dev.apk', fingerprint: true
            }
        }
        
        stage('Build Stag') {
            steps {
                sh '''
                    export PATH="${env.PATH}"
                    flutter build apk --flavor stag -t lib/main_stag.dart
                '''
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-stag.apk', fingerprint: true
            }
        }
        
        stage('Build Prod') {
            steps {
                sh '''
                    export PATH="${env.PATH}"
                    flutter build apk --flavor prod -t lib/main_prod.dart
                '''
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-prod.apk', fingerprint: true
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Build completed successfully!'
        }
        failure {
            echo 'Build failed!'
        }
    }
} 