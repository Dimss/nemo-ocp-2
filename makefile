
init:
	oc new-project nemo
	oc adm policy add-scc-to-user anyuid -z default -n nemo
	oc adm policy add-scc-to-user privileged -z default -n nemo
	oc create -f 0-init/
	oc delete -f 0-init/12-tel.yaml
	oc create -f 0-init/routes-gw/0-routes.yaml -n istio-system
	oc create -f 0-init/routes-gw/1-gw.yaml

build:
	oc start-build comments
	oc start-build feed
	oc start-build identity
	oc start-build likes
	oc start-build links
	oc start-build receiver
	oc start-build ui

create:
	echo "0-ui"
	cd 0-ui && oc create -f ./
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
	echo "Create Tel"
	cd 0-init && oc create -f 12-tel.yaml

delete:
	echo "0-ui"
	cd 0-ui && oc delete -f ./
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
	echo "Tel delete"
	cd 0-init && oc delete -f 12-tel.yaml

demo1-delay:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/0-demo-delay.yaml
demo1-delay-clean:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 5-likes/2-drule.yaml
	oc create -f 5-likes/3-vs.yaml
demo1-abort:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/0-demo-abort.yaml
demo1-abort-clean:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 5-likes/2-drule.yaml
	oc create -f 5-likes/3-vs.yaml

demo2-circuit-braker:
	oc scale deployment feed --replicas=2
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/1-demo-cb.yaml

demo2-circuit-braker-clean:
	oc scale deployment feed --replicas=1
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 6-feed/1-drule.yaml
	oc create -f 6-feed/2-vs.yaml

demo3-debug:
	oc create -f demos/2-demo-debug.yaml
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/2-demo-mirror-rule.yaml
demo3-debug-clean:
	oc delete -f demos/2-demo-debug.yaml
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 6-feed/1-drule.yaml
	oc create -f 6-feed/2-vs.yaml

