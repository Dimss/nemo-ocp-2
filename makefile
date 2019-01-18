init:
	PROJECT_NAME=nemo
	oc new-project ${PROJECT_NAME}
	oc adm policy add-scc-to-user anyuid -z default -n ${PROJECT_NAME}
	oc adm policy add-scc-to-user privileged -z default -n ${PROJECT_NAME}
	oc create -f init/
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
