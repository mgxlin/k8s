pipeline {
    agent any

    tools {
            // 确保 'MAVEN_3.8.1' 与你在 Jenkins 全局工具配置中设置的名称一致
            maven 'mvn'
        }

    // 定义环境变量
    environment {
        REPO_URL = 'https://github.com/mgxlin/k8s.git'
        DOCKERHUB_USER = 'mgxlin' // <--- 这里请替换成你的 Docker Hub 用户名
        IMAGE_NAME = "${DOCKERHUB_USER}/k8s-springboot"
        TAG = "latest"
        K8S_KUBECONFIG_ID = 'k8s-kubeconfig'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== 1. Checkout Code ==='
                git url: "${REPO_URL}", branch: 'main'
            }
        }

        stage('Maven Build') {
            steps {
                echo '=== 2. Maven Build ==='
                // -DskipTests 跳过单元测试，可根据需要移除
                sh "mvn clean package -DskipTests"
            }
        }

        stage('Docker Build') {
            steps {
                echo '=== 3. Build Docker Image ==='
                script {
                    // 使用当前 Jenkins 构建号作为镜像标签
                    def tag = "${env.BUILD_NUMBER}"
                    sh "docker build -t ${IMAGE_NAME}:${tag} ."
                    // 也给镜像打上 latest 标签
                    sh "docker tag ${IMAGE_NAME}:${tag} ${IMAGE_NAME}:${TAG}"
                }
            }
        }

        stage('Docker Push') {
            steps {
                echo '=== 4. Push Docker Image ==='
                script {
                    // 使用 Jenkins 凭据安全登录 Docker Hub
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                        // 推送带构建号和latest的镜像
                        sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                        sh "docker push ${IMAGE_NAME}:${TAG}"
                    }
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                echo '=== 5. Deploy to Kubernetes ==='
                // 使用 Jenkins 凭据文件配置 kubectl
                withCredentials([file(credentialsId: "${K8S_KUBECONFIG_ID}", variable: 'KUBECONFIG_PATH')]) {
                    script {
                        // 替换 YAML 文件中的镜像标签，以实现滚动更新
                        sh "sed -i 's|${IMAGE_NAME}:latest|${IMAGE_NAME}:${env.BUILD_NUMBER}|g' k8s/deployment.yaml"

                        // 应用 Deployment 和 Service 文件
                        sh "kubectl --kubeconfig=$KUBECONFIG_PATH apply -f k8s/deployment.yaml"
                        sh "kubectl --kubeconfig=$KUBECONFIG_PATH apply -f k8s/service.yaml"

                        // 可选：等待 Deployment 滚动更新完成
                        sh "kubectl --kubeconfig=$KUBECONFIG_PATH rollout status deployment/k8s-springboot-deployment"
                    }
                }
            }
        }
    }
}