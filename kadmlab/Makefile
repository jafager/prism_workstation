reset:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	# virsh snapshot-create-as --domain kadmlabnode1 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlabnode2 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlabnode3 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlabnode4 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlabnode5 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlabnode6 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlablb1 --name "make snapshot"
	# virsh snapshot-create-as --domain kadmlablb2 --name "make snapshot"
	ansible-playbook kadmlablb.yaml
	ansible-playbook kadmlabnode.yaml

rebuild:
	terraform destroy -auto-approve
	terraform apply -auto-approve
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"

snapshot:
	virsh snapshot-create-as --domain kadmlabnode1 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlabnode2 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlabnode3 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlabnode4 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlabnode5 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlabnode6 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlablb1 --name "make snapshot"
	virsh snapshot-create-as --domain kadmlablb2 --name "make snapshot"

revert:
	virsh snapshot-revert --domain kadmlabnode1 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode2 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode3 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode4 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode5 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode6 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlablb1 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlablb2 --snapshotname "make snapshot" --running
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"

revertnode:
	virsh snapshot-revert --domain kadmlabnode1 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode2 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode3 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode4 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode5 --snapshotname "make snapshot" --running
	virsh snapshot-revert --domain kadmlabnode6 --snapshotname "make snapshot" --running
	ansible kadmlab -m wait_for_connection -a "timeout=180 sleep=10"
