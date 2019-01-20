init:
	oc new-project nemo
	oc adm policy add-scc-to-user anyuid -z default -n nemo
	oc adm policy add-scc-to-user privileged -z default -n nemo
	oc create -f 0-init/

build:
	oc start-build comments
	oc start-build feed
	oc start-build identity
	oc start-build likes
	oc start-build links
	oc start-build receiver

create:
	echo "1-identity"
	cd 1-identity && oc create -f ./
	echo "2-receiver"
	cd 2-receiver && oc create -f ./
	echo "3-links"
	cd 3-links && oc create -f ./
	echo "4-comments"
	cd 4-comments && oc create -f ./
	echo "5-likes"
	cd 5-likes && oc create -f ./
	echo "5-feed"
	cd 6-feed && oc create -f ./

delete:
	echo "1-identity"
	cd 1-identity && oc delete -f ./
	echo "2-receiver"
	cd 2-receiver && oc delete -f ./
	echo "3-links"
	cd 3-links && oc delete -f ./
	echo "4-comments"
	cd 4-comments && oc delete -f ./
	echo "5-likes"
	cd 5-likes && oc delete -f ./
	echo "5-feed"
	cd 6-feed && oc delete -f ./

demo1-delay:
	oc delete virtualservices likes
	oc delete DestinationRule likes
	oc create -f demos/0-demo-delay.yaml

demo1-abort:
	oc delete virtualservices likes
	oc delete DestinationRule likes
	oc create -f demos/0-demo-abort.yaml

demo2-circuit-braker:
	oc scale deployment feed --replicas=2
	oc delete virtualservices feed
	oc delete DestinationRule feed
	oc create -f demos/1-demo-cm.yaml
