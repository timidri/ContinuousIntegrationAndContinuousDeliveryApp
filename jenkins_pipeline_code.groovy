node {
    def mvnHome
    stage('Preparation') { // for display purposes
        git 'git@gitlab.inf.puppet.vm:puppet/ContinuousIntegrationAndContinuousDeliveryApp.git'
        gitlabCommitStatus {
          sh 'echo "Preparation"'
        }
        mvnHome = tool 'M2'
    }
    stage('Test') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
            gitlabCommitStatus {
              sh 'echo "Test"'
            }            
        } catch (e) {
            notifyStarted("Tests Failed in Jenkins!")
            throw e
        } 
    }
    stage('Build') {
        try {
            sh "'${mvnHome}/bin/mvn' clean package -DskipTests"
            gitlabCommitStatus {
              sh 'echo "Build"'
            }               
        }catch (e) {
            notifyStarted("Build Failed in Jenkins!")
            throw e
        } 
    }
    stage('Results') {
        try{
            archive 'target/*.jar'
            gitlabCommitStatus {
              sh 'echo "Results"'
            }             
        }catch (e) {
            notifyStarted("Packaging Failed in Jenkins!")
            throw e
        } 
    }
    stage('Deployment') {
        try{
            sh   '/var/lib/jenkins/workspace/Pipeline/runDeployment.sh'
            gitlabCommitStatus {
              sh 'echo "Deployment"'
            }              
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        } 
    }
    stage('Post') {
      gitlabCommitStatus {
        sh 'echo "Post"'
      }          
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}