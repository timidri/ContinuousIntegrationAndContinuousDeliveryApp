node {
    puppet.credentials 'puppet-access-token'
    def mvnHome
    stage('Preparation') { // for display purposes
        git 'https://github.com/maju6406/ContinuousIntegrationAndContinuousDeliveryApp.git'
        sh 'cd deployment/ && rm -rf tse-control-repo-jenkinswork && git clone -b production https://github.com/maju6406/tse-control-repo-jenkinswork.git && sed -ie \'$d\' tse-control-repo-jenkinswork/environment.conf && cd ..'
        sh   '${WORKSPACE}/cleanup-docker.sh'
step([$class: 'GitHubCommitStatusSetter', statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: 'Pending', state: 'PENDING']]]])

        mvnHome = tool 'M2'
    }
    stage('Unit Tests') {
        try {
            sh "'${mvnHome}/bin/mvn' test"
        } catch (e) {
            notifyStarted("Unit Tests Failed in Jenkins!")
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
    stage('Package') {
        try{
            // Create jar
            archive 'target/*.jar'
            // Create RPM
            sh   '${WORKSPACE}/deployRPM.sh'
        }catch (e) {
            notifyStarted("Packaging Failed in Jenkins!")
            throw e
        }
    }
    stage('Docker Acceptance Tests') {
        try {
            sh '${WORKSPACE}/dockerDeployment.sh'
            sleep 2
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
        }catch (e) {
            notifyStarted("Deployment Failed in Jenkins!")
            throw e
        }
    }
    stage('Post') {
      sleep 2
      sh 'echo "The build is done!"'
step([$class: 'GitHubCommitStatusSetter', statusResultSource: [$class: 'ConditionalStatusResultSource', results: [[$class: 'AnyBuildResult', message: 'Success', state: 'SUCCESS']]]])
        
    }
    notifyStarted("All is well! Your code is tested,built,and deployed.")
}
def notifyStarted(String message) {
}
