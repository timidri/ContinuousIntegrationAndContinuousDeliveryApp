node {
    puppet.credentials 'puppet-access-token'
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
            sh "/usr/local/bin/fpm -s dir -t rpm -n helloworldjavaapp -v 0.0.7 /var/lib/jenkins/workspace/Pipeline/target/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar=/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar /var/lib/jenkins/workspace/Pipeline/target/helloworldjavaapp.service=/usr/lib/systemd/system/helloworldjavaapp.service"
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
      puppet.job 'production', query: 'nodes { certname = "centos-7-2.pdx.puppet.vm" }'        
      gitlabCommitStatus {
        sh 'echo "Post"'
      }          
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}
