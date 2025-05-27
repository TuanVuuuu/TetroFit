pipeline {
    agent any
    
    environment {
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/opt/android-sdk'
        PATH = "${env.PATH}:${env.FLUTTER_HOME}/bin:${env.ANDROID_HOME}/tools:${env.ANDROID_HOME}/platform-tools"
        PATH+EXTRA = "${env.FLUTTER_HOME}/bin:${env.ANDROID_HOME}/tools:${env.ANDROID_HOME}/platform-tools"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh 'flutter pub get'
            }
        }
        
        stage('Build Dev') {
            steps {
                sh 'flutter build apk --flavor dev -t lib/main_dev.dart'
            }
        }
        
        stage('Build Stag') {
            steps {
                sh 'flutter build apk --flavor stag -t lib/main_stag.dart'
            }
        }
        
        stage('Build Prod') {
            steps {
                sh 'flutter build apk --flavor prod -t lib/main_prod.dart'
            }
        }
        
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', fingerprint: true
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