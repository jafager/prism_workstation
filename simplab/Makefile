rebuild:
	terraform destroy -auto-approve
	terraform apply -auto-approve

reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook host_file.yaml
	ansible-playbook simplablb.yaml
	ansible-playbook simplabstor.yaml
	ansible-playbook simplabnode.yaml
	ansible-playbook calico.yaml
	ansible-playbook metallb.yaml
	ansible-playbook nfs_provisioner.yaml
	ansible-playbook mimir.yaml

nodes:
	ansible simplabcp,simplabwk -m shell -a "kubeadm reset -f"
	ansible-playbook simplabnode.yaml
	ansible-playbook calico.yaml
	ansible-playbook metallb.yaml
	ansible-playbook nfs_provisioner.yaml
