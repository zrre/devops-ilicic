devops-ilicic

feature/* -> develop: branch policy + Terragrunt plan test
develop -> main: branch policy + Terragrunt plan prod
main/develop direct push: blocked by branch protection
self-hosted runner: required
Azure auth: temporary SP secret; planned OIDC when Entra permissions are available