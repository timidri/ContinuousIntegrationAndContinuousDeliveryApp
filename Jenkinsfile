node {
    puppet.credentials 'puppet-access-token'
    def mvnHome
    stage('Preparation') { // for display purposes
        sh   '${WORKSPACE}/cleanup-docker.sh'
        git 'https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp.git'
        sh 'cd deployment/ && rm -rf control-repo && git clone  -b development git@gitlab.inf.puppet.vm:puppet/control-repo.git && sed -ie \'$d\' control-repo/environment.conf && cd ..'
        githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Preparing',  status: 'PENDING'        
        mvnHome = tool 'M2'
    }
    stage('Unit Tests') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
            githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Unit Tests',  status: 'PENDING'        
        } catch (e) {
            notifyStarted("Unit Tests Failed in Jenkins!")
            throw e
        }
    }
    stage('Build') {
        try {
            sh "'${mvnHome}/bin/mvn' clean package -DskipTests"
            githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Build',  status: 'PENDING'        
        }catch (e) {
            notifyStarted("Build Failed in Jenkins!")
            throw e
        }
    }
    stage('Package') {
        try{
            // Create jar
            archive 'target/*.jar'
            // Create RPM
            sh   '${WORKSPACE}/deployRPM.sh'
            githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Package',  status: 'PENDING'        
        }catch (e) {
            notifyStarted("Packaging Failed in Jenkins!")
            throw e
        }
    }
    stage('Docker Acceptance Tests') {
        try {
            sh '${WORKSPACE}/dockerDeployment.sh'
//            sleep 2
//            sh '${WORKSPACE}/isserverup.sh localhost 8090'
            githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Docker Acceptance Tests',  status: 'PENDING'        
        } catch (e) {
            notifyStarted("Tests Failed in Jenkins!")
            throw e
        }
    }
    stage('Prod Deployment') {
        try{
            // Puppet Pipeline Plugin magic
            puppet.codeDeploy 'development'
            puppet.job 'development', query: 'nodes { certname = "centos-7-3.pdx.puppet.vm" }'
            githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp",  description: 'Prod Deployment',  status: 'PENDING'        
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        }
    }
    stage('Post') {
      sleep 2
//      sh '${WORKSPACE}/isserverup.sh centos-7-3.pdx.puppet.vm 8090'
      sh 'echo "The build is done!"'
      githubNotify credentialsId: 'puppet-github-maju6406', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Build Finished',  status: 'SUCCESS'        
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}
