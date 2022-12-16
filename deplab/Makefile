reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook deplab.yaml
	virsh reset deplabclient1
	virsh reset deplabclient2
	virsh reset deplabclient3
	virsh reset deplabclient4

rebuild:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible deplabserver -m wait_for_connection -a "timeout=180 sleep=10"
