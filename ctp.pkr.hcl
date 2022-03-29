build {
  name = "ctp"
  sources = [
    "source.docker.debian"
  ]
  provisioner "file" {
    sources = [
      "CTP-installer.jar", 
      "config-serveronly.xml",
      "Launcher.properties",
      "entrypoint.sh"
    ]
    destination = "/tmp/"
  }
  provisioner "shell" {
    inline = [
      "apt update",
      "mkdir -p /JavaPrograms/ && cd /JavaPrograms",
      "jar xf /tmp/CTP-installer.jar CTP",
      "mv /tmp/config-serveronly.xml /JavaPrograms/CTP/config.xml",
      "mv /tmp/Launcher.properties /JavaPrograms/CTP/",
      "rm -f /tmp/CTP-installer.jar"
    ]    
  }
  post-processor "docker-tag" {
    repository = var.repo
  }
}
variable "repo" {
  type = string
  default = "archetype/mirc-ctp"
}
source "docker" "debian" {
  image = "openjdk:18-jdk-slim-bullseye"
  commit  = true
  changes = [
    "LABEL org.opencontainers.image.source https://github.com/exxa-tech/ctp-build",
    "USER root",
    "EXPOSE 1080 1443 25055",
    "WORKDIR /JavaPrograms/CTP",
    "ENTRYPOINT [\"/bin/sh\", \"/tmp/entrypoint.sh\"]"
  ]
}
