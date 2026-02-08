.PHONY: init plan apply destroy configure pki-init server-cert client-cert client-config deploy status

TF_DIR := terraform
ANSIBLE_DIR := ansible

# --- Terraform ---
init:
	cd $(TF_DIR) && terraform init

plan:
	cd $(TF_DIR) && terraform plan

apply:
	cd $(TF_DIR) && terraform apply

destroy:
	cd $(TF_DIR) && terraform destroy

# --- PKI ---
pki-init:
	./scripts/init-pki.sh

server-cert:
	./scripts/generate-server-cert.sh

client-cert:
	@test -n "$(CLIENT)" || (echo "Usage: make client-cert CLIENT=<name>" && exit 1)
	./scripts/generate-client-cert.sh $(CLIENT)

client-config:
	@test -n "$(CLIENT)" || (echo "Usage: make client-config CLIENT=<name>" && exit 1)
	./scripts/generate-client-config.sh $(CLIENT)

# --- Ansible ---
configure:
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

status:
	cd $(ANSIBLE_DIR) && ansible all -m ping

# --- Full deployment ---
deploy: apply configure
	@echo "Deployment complete."
