reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook kadmlablb.yaml
	ansible-playbook kadmlabstor.yaml
	ansible-playbook kadmlabnode.yaml

rebuild:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"

snapshot:
	virsh shutdown kadmlabnode1
	virsh shutdown kadmlabnode2
	virsh shutdown kadmlabnode3
	virsh shutdown kadmlabnode4
	virsh shutdown kadmlabnode5
	virsh shutdown kadmlabnode6
	sleep 60
	virsh snapshot-create-as kadmlabnode1 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode2 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode3 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode4 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode5 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode6 --name "make snapshot"
	virsh start kadmlabnode1
	virsh start kadmlabnode2
	virsh start kadmlabnode3
	virsh start kadmlabnode4
	virsh start kadmlabnode5
	virsh start kadmlabnode6
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"

revert:
	virsh shutdown kadmlabnode1
	virsh shutdown kadmlabnode2
	virsh shutdown kadmlabnode3
	virsh shutdown kadmlabnode4
	virsh shutdown kadmlabnode5
	virsh shutdown kadmlabnode6
	sleep 60
	virsh snapshot-revert kadmlabnode1 --snapshotname "make snapshot" --running
	virsh snapshot-revert kadmlabnode2 --snapshotname "make snapshot" --running
	virsh snapshot-revert kadmlabnode3 --snapshotname "make snapshot" --running
	virsh snapshot-revert kadmlabnode4 --snapshotname "make snapshot" --running
	virsh snapshot-revert kadmlabnode5 --snapshotname "make snapshot" --running
	virsh snapshot-revert kadmlabnode6 --snapshotname "make snapshot" --running
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"

checkpoint:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible-playbook kadmlablb.yaml
	ansible-playbook kadmlabstor.yaml
	virsh shutdown kadmlablb1
	virsh shutdown kadmlablb2
	virsh shutdown kadmlabstor1
	virsh shutdown kadmlabnode1
	virsh shutdown kadmlabnode2
	virsh shutdown kadmlabnode3
	virsh shutdown kadmlabnode4
	virsh shutdown kadmlabnode5
	virsh shutdown kadmlabnode6
	sleep 60
	virsh snapshot-create-as kadmlablb1 --name "make snapshot"
	virsh snapshot-create-as kadmlablb2 --name "make snapshot"
	virsh snapshot-create-as kadmlabstor1 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode1 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode2 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode3 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode4 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode5 --name "make snapshot"
	virsh snapshot-create-as kadmlabnode6 --name "make snapshot"
	virsh start kadmlablb1
	virsh start kadmlablb2
	virsh start kadmlabstor1
	virsh start kadmlabnode1
	virsh start kadmlabnode2
	virsh start kadmlabnode3
	virsh start kadmlabnode4
	virsh start kadmlabnode5
	virsh start kadmlabnode6
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"
