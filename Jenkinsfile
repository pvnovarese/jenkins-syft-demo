pipeline {
  environment {
    registry = 'registry.hub.docker.com'
    registryCredential = 'docker-hub'
    repository = 'pvnovarese/jenkins-syft-demo'
  }
  agent any
  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }
    stage('Build image and push to registry') {
      steps {
        sh 'docker --version'
        def image = docker.build(repository)
        //script {
          //docker.withRegistry('https://' + registry, registryCredential) {
            //def image = docker.build(repository)
            //image.push()
          //}
        //}
      }
    }
    stage('Analyze with syft') {
      steps {
        // run syft, concatenate output to a single line and test that curl isn't in that line
        // the grep will fail if curl exists, causing the pipeline to fail
        sh '/var/jenkins_home/syft ${repository}:latest | tr "\n" " " | grep -v curl'
      }
    }
    stage('Build and push prod image to registry') {
      steps {
        script {
          docker.withRegistry('https://' + registry, registryCredential) {
            def image = docker.build(repository + ':prod')
            image.push()  
          }
        }
      }
    }
  }
}
