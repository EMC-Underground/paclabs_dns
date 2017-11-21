all: build
	echo "Use make gen_zones if you want to generate a zone file from host_list.csv"

gen_zones:
	./gen_zones.sh
	terraform init
	terraform validate -var-file=terraform.tfvars
	terraform apply -var-file=terraform.tfvars

init:
	terraform init

validate: init
	terraform validate -var-file=terraform.tfvars

build: validate
	terraform apply -var-file=terraform.tfvars

debug: validate
ifeq ($(OS),Windows_NT)
	$(set TF_LOG=trace)
else
	$(TF_LOG=trace)
endif
	terraform apply -var-file=terraform.tfvars

destroy:
	echo "yes" | terraform destroy
