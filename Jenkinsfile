node {
    puppet.credentials 'puppet-access-token'
    def mvnHome
    stage('Preparation') { // for display purposes
        git 'https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp.git'
        sh 'cd deployment/ && rm -rf tse-control-repo-jenkinswork && git clone -b production https://github.com/maju6406/tse-control-repo-jenkinswork.git && sed -ie \'$d\' tse-control-repo-jenkinswork/environment.conf && cd ..'
        sh   '${WORKSPACE}/cleanup-docker.sh'
//        githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Preparing',  status: 'PENDING'        
//        githubNotify account: 'maju6406', context: 'TSE Jenkins', credentialsId: '70878517-f286-4149-9f6f-ffb4e8648d29', description: 'Preparing', repo: 'ContinuousIntegrationAndContinuousDeliveryApp', status: 'PENDING'
//  step([
//      $class: "GitHubCommitStatusSetter",
//      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp"],
//      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
//      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
//      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: "Preparing Message", state: "PENDING"]] ]
//  ]);
//step([$class: 'GitHubSetCommitStatusBuilder', contextSource: [$class: 'ManuallyEnteredCommitContextSource', context: 'TSE-Jenkins']])
step([$class: 'GitHubCommitStatusSetter', statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: 'Pending', state: 'PENDING']]]])

        mvnHome = tool 'M2'
    }
    stage('Unit Tests') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
//            githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Unit Tests',  status: 'PENDING'        
        } catch (e) {
            notifyStarted("Unit Tests Failed in Jenkins!")
            throw e
        }
    }
    stage('Build') {
        try {
            sh "'${mvnHome}/bin/mvn' clean package -DskipTests"
//            githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Build',  status: 'PENDING'        
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
//            githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Package',  status: 'PENDING'        
        }catch (e) {
            notifyStarted("Packaging Failed in Jenkins!")
            throw e
        }
    }
    stage('Docker Acceptance Tests') {
        try {
            sh '${WORKSPACE}/dockerDeployment.sh'
            sleep 2
//            sh '${WORKSPACE}/isserverup.sh localhost 8090'
//            githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Docker Acceptance Tests',  status: 'PENDING'        
        } catch (e) {
            notifyStarted("Tests Failed in Jenkins!")
            throw e
        }
    }
    stage('Prod Deployment') {
        try{
            // Puppet Pipeline Plugin magic
            puppet.codeDeploy 'production'
            puppet.job 'production', query: 'nodes { certname ~ "javaappserver" }'
//            githubNotif credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp",  description: 'Prod Deployment',  status: 'PENDING'        
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        }
    }
    stage('Post') {
      sleep 2
//      sh '${WORKSPACE}/isserverup.sh centos-7-3.pdx.puppet.vm 8090'
      sh 'echo "The build is done!"'
//      githubNotify credentialsId: 'puppet-github-up', account: "maju6406", repo: "ContinuousIntegrationAndContinuousDeliveryApp", description: 'Build Finished',  status: 'SUCCESS'        
//      githubNotify account: 'maju6406', context: 'TSE Jenkins', credentialsId: '70878517-f286-4149-9f6f-ffb4e8648d29', description: 'Build Finished', repo: 'ContinuousIntegrationAndContinuousDeliveryApp', status: 'SUCCESS'        
//   step([
//      $class: "GitHubCommitStatusSetter",
//      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp"],
//      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
//      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
//      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: "Done", state: "SUCCESS"]] ]
//  ]);
step([$class: 'GitHubCommitStatusSetter', statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: 'Success', state: 'SUCCESS']]]])
        
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
//  slackSend (color: '#FFFF00', message: "${message}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
}
