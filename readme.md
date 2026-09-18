Dans un terminal, exporter ses propres variables d'environnement fournie par la console aws

```sh
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

creer le bucket s3 au préalable avec la commande :

```sh
aws s3api create-bucket --bucket "5hash-bucket" --region eu-west-3 --create-bucket-configuration LocationConstraint=eu-west-3
```

generer une key ssh

```sh

mkdir -p .keys
ssh-keygen -t ed25519 -f .keys/key-5hash -N ""

```

Executer

```sh

terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply

```

En cas de terraform destroy il faut delete le secret

```sh
aws secretsmanager delete-secret --secret-id "5HASH/db-pwd" --region eu-west-3 --force-delete-without-recovery
```
