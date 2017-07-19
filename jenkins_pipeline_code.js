node {
    def mvnHome
    stage('Preparation') { // for display purposes
        git 'git@gitlab.inf.puppet.vm:puppet/ContinuousIntegrationAndContinuousDeliveryApp.git'
        mvnHome = tool 'M2'
    }
    stage('Test') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
        } catch (e) {
            notifyStarted("Tests Failed in Jenkins!")
            throw e
        } 
    }
    stage('Build') {
        try {
            sh "'${mvnHome}/bin/mvn' clean package -DskipTests"
        }catch (e) {
            notifyStarted("Build Failed in Jenkins!")
            throw e
        } 
    }
    stage('Results') {
        try{
            archive 'target/*.jar'
        }catch (e) {
            notifyStarted("Packaging Failed in Jenkins!")
            throw e
        } 
    }
    stage('Deployment') {
        try{
            sh   '/var/lib/jenkins/workspace/Pipeline/runDeployment.sh'
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        } 
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}
