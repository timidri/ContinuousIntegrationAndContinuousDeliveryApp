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
            // Create jar
            archive 'target/*.jar'
            // Create RPM
            sh   '/var/lib/jenkins/workspace/Pipeline/runDeployment.sh'            
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
            // Run Puppet on test machine to get latest code
            sh 'source /var/lib/jenkins/.openstack_snapshotrc;nova rebuild --poll "895e732e-3f32-4d6c-8cc2-481f6bf03f78" "d9553b4f-b4f8-483e-9e4f-a91c3b8e3208"'
            sleep 10            
            puppet.job 'development', query: 'nodes { certname = "centos-7-3.pdx.puppet.vm" }'        
            puppet.codeDeploy 'development'
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
