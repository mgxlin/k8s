# 1. 指定一个包含 Java 环境的基础镜像
FROM openjdk:17-slim

# 2. 设置容器内的工作目录
WORKDIR /app

# 3. 将编译好的 JAR 包从 target 目录复制到容器的 /app 目录下
#    请确保 JAR 文件名和你的项目匹配
COPY target/k8s-0.0.1-SNAPSHOT.jar app.jar

# 4. 声明应用运行的端口
EXPOSE 8080

# 5. 设置容器启动时要执行的命令
ENTRYPOINT ["java", "-jar", "app.jar"]