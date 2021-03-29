pipeline {
  
  environment {
    // shouldn't need the registry variable unless you're not using dockerhub
    // registry = 'registry.hub.docker.com'
    //
    // change this HUB_CREDENTIAL to the ID of whatever jenkins credential has your registry user/pass
    // first let's set the docker hub credential and extract user/pass
    // we'll use the USR part for figuring out where are repository is
    HUB_CREDENTIAL = "docker-hub"
    // use credentials to set DOCKER_HUB_USR and DOCKER_HUB_PSW
    DOCKER_HUB = credentials("${HUB_CREDENTIAL}")
    // change repository to your DockerID
    REPOSITORY = "${DOCKER_HUB_USR}/jenkins-syft-demo"
  } // end environment
  
  agent any
  stages {
    
    stage('Checkout SCM') {
      steps {
        checkout scm
      } // end steps
    } // end stage "checkout scm"
    
    stage('Build image and tag with build number') {
      steps {
        script {
          dockerImage = docker.build REPOSITORY + ":${BUILD_NUMBER}"
        } // end script
      } // end steps
    } // end stage "build image and tag w build number"
    
    stage('Analyze with syft') {
      steps {
        script {
          try {
            // run syft, use jq to get the list of artifact names, concatenate 
            // output to a single line and test that curl isn't in that line
            // the grep will fail if curl exists, causing the pipeline to fail
            sh '/var/jenkins_home/syft -o json ${REPOSITORY}:${BUILD_NUMBER} | jq .artifacts[].name | tr "\n" " " | grep -qv curl'
          } catch (err) {
            // if scan fails, clean up (delete the image) and fail the build
            sh """
              docker rmi ${REPOSITORY}:${BUILD_NUMBER}
              exit 1
            """
          } // end try/catch
        } // end script
      } // end steps
    } // end stage "analyze with syft"
    
    stage('Re-tag as prod and push stable image to registry') {
      steps {
        sh """
          docker tag ${REPOSITORY}:${BUILD_NUMBER} ${REPOSITORY}:prod
          docker push ${REPOSITORY}:prod
        """
        //script {
        //  docker.withRegistry('', HUB_CREDENTIAL) {
        //    dockerImage.push('prod') 
        //    // dockerImage.push takes the argument as a new tag for the image before pushing
        //  }
        //} // end script
      } // end steps
    } // end stage "retag as prod"

    stage('Clean up') {
      // delete the images locally
      steps {
        sh 'docker rmi ${REPOSITORY}:${BUILD_NUMBER} ${REPOSITORY}:prod'
      } // end steps
    } // end stage "clean up"

    
  } // end stages
} //end pipeline
