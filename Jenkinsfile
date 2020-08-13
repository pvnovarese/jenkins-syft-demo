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
    stage('Build image and tag as latest') {
      steps {
        sh 'docker --version'
        script {
          docker.withRegistry('https://' + registry, registryCredential) {
            def image = docker.build(repository)
          }
        }
      }
    }
    stage('Analyze with syft') {
      steps {
        // run syft, use jq to get the list of artifact names, concatenate 
        // output to a single line and test that curl isn't in that line
        // the grep will fail if curl exists, causing the pipeline to fail
        sh '/var/jenkins_home/syft -o json ${repository}:latest | jq .artifacts[].name | tr "\n" " " | grep -qv curl'
      }
    }
    stage('Build image with prod tag and push to registry') {
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
