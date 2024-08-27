pipeline {
  agent any
  tools {
  
  maven 'Maven' // Ensure this matches the Maven tool name configured in Jenkins
   
  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/workspacebychristian/devops-project.git']]])
        }
      }
	  
	  stage ('Build')  {
	      steps {
            dir('webapp'){
            sh "pwd"
            sh "ls -lah"
            sh "mvn package"
       // Integrate the specified web.xml path here
          sh "mvn clean package -DwebXml=/home/ubuntu/devops/devops-project/webapp/src/main/webapp/WEB-INF\web.xml"
          }
        }
         
      }
   
     stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {
                
				dir('webapp'){
                 sh 'mvn -U clean install sonar:sonar'
                }
				
              }
            }
      }

    stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "jfrog",
                    url: "http://54.166.108.10:8082/artifactory",
                    credentialsId: "jfrog"
                )

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "jfrog",
                    releaseRepo: "devops-project-libs-release-local",
                    snapshotRepo: "devops-project-libs-release-local"
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "jfrog",
                    releaseRepo: "devops-project-libs-release",
                    snapshotRepo: "devops-project-libs-snapshot"
                )
            }
    }

    stage ('Deploy Artifacts') {
            steps {
                rtMavenRun (
                    tool: "Maven", // Tool name from Jenkins configuration
                    pom: 'webapp/pom.xml',
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
         }
    }

    stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "jfrog"
             )
        }
    }

    stage('Copy Dockerfile & Playbook to Ansible Server') {
            
            steps {
                  sshagent(['ssh_agent']) {
                       sh "chmod 400  nv-kp.pem"
                       sh "ls -lah"
                        sh "scp -i nv-kp.pem -o StrictHostKeyChecking=no dockerfile ec2-user@34.233.34.128:/home/ec2-user"
                        sh "scp -i nv-kp.pem -o StrictHostKeyChecking=no dockerfile ec2-user@34.233.34.128:/home/ec2-user"
                        sh "scp -i nv-kp.pem -o StrictHostKeyChecking=no dockerhub.yaml ec2-user@34.233.34.128:/home/ec2-user"
                    }
                }
        } 

    stage('Build Container Image') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "ssh -i nv-kp.pem -o StrictHostKeyChecking=no ec2-user@34.233.34.128 -C \"ansible-playbook  -vvv -e build_number=${BUILD_NUMBER} dockerhub.yaml\""       
                    }
                }
        } 

    stage('Copy Deployment & Service Defination to K8s Master') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "scp -i nv-kp.pem -o StrictHostKeyChecking=no deployment.yaml ubuntu@107.23.253.7:/home/ubuntu"
                        sh "scp -i nv-kp.pem -o StrictHostKeyChecking=no service.yaml ubuntu@107.23.253.7:/home/ubuntu"
                    }
                }
        } 

    stage('Waiting for Approvals') {
            
        steps{

				input('Test Completed ? Please provide  Approvals for Prod Release ?')
			 }
    }     
    stage('Deploy Artifacts to Production') {
            
            steps {
                  sshagent(['ssh_key']) {
                        sh "ssh -i nv-kp.pem -o StrictHostKeyChecking=no ubuntu@107.23.253.7 -C \"kubectl set image deployment/chuka customcontainer=workspacebychuka/devops:${BUILD_NUMBER}\""
                        //sh "ssh -i nv-kp.pem -o StrictHostKeyChecking=no ubuntu@107.23.253.7 -C \"kubectl delete pod class-deploy2\""
                        sh "ssh -i nv-kp.pem -o StrictHostKeyChecking=no ubuntu@107.23.253.7 -C \"kubectl apply -f deployment.yaml\""
                        sh "ssh -i nv-kp.pem -o StrictHostKeyChecking=no ubuntu@107.23.253.7 -C \"kubectl apply -f service.yaml\""
		    }
                }  
        } 
   } 
}

