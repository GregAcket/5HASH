Prérequis :

Docker
un compte aws
Avoir aws CLI installé
utiliser la region eu-west-3

Préparation :

Dans un terminal, exporter ses propres variables d'environnement fournie par la console aws

```sh
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

construire l'image docker depuis la racine:

```sh
docker build -t 5hash-tools .
```

Si cette commande renvoie "Permission denied", executer la commande

```sh
chmod +x run.sh
```

puis relancer

```sh
docker build -t 5hash-tools .
```

creer le bucket s3 au préalable avec la commande :
/!\ Important :

Les noms de bucket sont unique, il vous faudra remplacer "5hash-bucket" par votre nom de bucket dans la commande ci-dessous ainsi que dans le fichier **/terraform/backend.tf**

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

./run.sh terraform -chdir=terraform init
./run.sh terraform -chdir=terraform fmt -recursive
./run.sh terraform -chdir=terraform validate
./run.sh terraform -chdir=terraform plan
./run.sh terraform -chdir=terraform apply

```

En cas de terraform destroy il faut delete le secret

```sh
aws secretsmanager delete-secret --secret-id "5HASH/db-pwd" --region eu-west-3 --force-delete-without-recovery
```

test WAF :

```sh
curl -i "http://<dns-de-ton-alb>/?q=<script>alert(1)</script>"
curl -i "http://load-balancer-2122675166.eu-west-3.elb.amazonaws.com/?q=<script>alert(1)</script>"
```

multi az :

```sh
aws rds describe-db-instances --db-instance-identifier terraform-bdc3b32b5ca88f0b0bcde1005f --region eu-west-3 --query 'DBInstances[0].[MultiAZ,AvailabilityZone,SecondaryAvailabilityZone]'
```

pour tester la connexion en ssh sur le bastion:

```sh
ssh -i .keys/key-5hash admin@<IP-DU-BASTION>
```

/!\ Important :

Le contournement de ce bug ne faisant pas l'objet de ce projet, nous avons fait génerer les fichiers .dockerignore, dockerfile et run.sh.

L'idée du contournement est de fixer les versions de Ansible et de Terraform à des versions avant que le bug n'apparraisse. Ce contournement permet ainsi d'avoir un environnement identique et fonctionnel, quel que soit l'OS de votre machine en utilisant terraform_provider.

Pour executer les commandes de test, il faudra prefixer par ./run.sh les commandes terraform et ansible (elles doivent tourner dans le conteneur, avec les versions d'outils fixées). Les autres commandes (docker, aws, ssh-keygen, curl) s'executent directement sur la machine, sans prefixe.

```sh
docker build -t 5hash-tools .
./run.sh terraform -chdir=terraform init
./run.sh terraform -chdir=terraform apply
./run.sh ansible-galaxy install -r ansible/requirements.yml
./run.sh ansible-inventory -i ansible/inventory.yml --graph
./run.sh ansible-playbook -i ansible/inventory.yml ansible/site.yml --ask-vault-pass
./run.sh ansible-playbook -i ansible/inventory.yml ansible/site.yml --ask-vault-pass
```

creation du vault dans docker :

```sh
./run.sh ansible-vault create ansible/group_vars/all/vault.yml
```

generer le mot de passe
