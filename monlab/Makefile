reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook monlablb.yaml
	ansible-playbook monlabstor.yaml
	ansible-playbook monlabnode.yaml
	ansible-playbook calico.yaml
