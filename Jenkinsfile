node {
    puppet.credentials 'puppet-access-token'
    def mvnHome
    stage('Preparation') { // for display purposes
        sh   '${WORKSPACE}/cleanup-docker.sh'
        git 'https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp.git'
        sh 'cd deployment/ && rm -rf control-repo && git clone  -b development git@gitlab.inf.puppet.vm:puppet/control-repo.git && sed -ie \'$d\' control-repo/environment.conf && cd ..'
        gitlabCommitStatus {
          sh 'echo "Preparation"'
        }
        mvnHome = tool 'M2'
    }
    stage('Unit Tests') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
            gitlabCommitStatus {
              sh 'echo "Unit Test"'
            }
        } catch (e) {
            notifyStarted("Unit Tests Failed in Jenkins!")
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
    stage('Package') {
        try{
            // Create jar
            archive 'target/*.jar'
            // Create RPM
            sh   '${WORKSPACE}/deployRPM.sh'
            gitlabCommitStatus {
              sh 'echo "Results"'
            }
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
            gitlabCommitStatus {
              sh 'echo "Test"'
            }
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
            gitlabCommitStatus {
              sh 'echo "Deployment"'
            }
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        }
    }
    stage('Post') {
      sleep 2
//      sh '${WORKSPACE}/isserverup.sh centos-7-3.pdx.puppet.vm 8090'
      sh 'echo "The build is done!"'
      gitlabCommitStatus {
        sh 'echo "Post"'
      }
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}
