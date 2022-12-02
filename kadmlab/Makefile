reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook -f 6 kadmlab.yaml

rebuild:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"
