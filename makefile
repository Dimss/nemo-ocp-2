
init:
	oc new-project nemo
	oc adm policy add-scc-to-user anyuid -z default -n nemo
	oc adm policy add-scc-to-user privileged -z default -n nemo
	oc create -f 0-init/
	oc delete -f 0-init/12-tel.yaml

istio-routes:
	oc create -f 0-init/routes-gw/0-routes.yaml -n istio-system

build:
	oc start-build comments
	oc start-build feed
	oc start-build identity
	oc start-build identity-new-version
	oc start-build likes
	oc start-build links
	oc start-build receiver
	oc start-build ui
	oc start-build ui-new-version

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
	echo "Create Istio GW"
	cd 0-init && oc create -f routes-gw/1-gw.yaml

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
	echo "Delete Istio GW"
	cd 0-init && oc delete -f routes-gw/1-gw.yaml


demo0-traffic-weight-identity-step1:
	oc delete -f 1-identity/2-drule.yaml
	oc delete -f 1-identity/3-vs.yaml
	oc create -f 0-init/12-tel.yaml
	oc create -f demos/0-traffic-shifting/0-weight-idenity.yaml

demo0-traffic-weight-identity-step1-clean:
	oc delete -f demos/0-traffic-shifting/0-weight-idenity.yaml
	oc delete -f 0-init/12-tel.yaml
	oc create -f 1-identity/2-drule.yaml
	oc create -f 1-identity/3-vs.yaml

demo0-traffic-weight-identity-step2:
	oc delete -f 1-identity/2-drule.yaml
	oc delete -f 1-identity/3-vs.yaml
	oc create -f demos/0-traffic-shifting/1-weight-idenity.yaml

demo0-traffic-weight-identity-step2-clean:
	oc delete -f demos/0-traffic-shifting/1-weight-idenity.yaml
	oc create -f 1-identity/2-drule.yaml
	oc create -f 1-identity/3-vs.yaml

demo0-traffic-header-identity-step3:
	oc delete -f 1-identity/2-drule.yaml
	oc delete -f 1-identity/3-vs.yaml
	oc create -f demos/0-traffic-shifting/2-header-idenity.yaml

demo0-traffic-header-identity-step3-clean:
	oc delete -f demos/0-traffic-shifting/2-header-idenity.yaml
	oc create -f 1-identity/2-drule.yaml
	oc create -f 1-identity/3-vs.yaml


demo0-delay:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/0-demo-delay.yaml
demo0-delay-clean:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 5-likes/2-drule.yaml
	oc create -f 5-likes/3-vs.yaml
demo0-abort:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/0-demo-abort.yaml
demo0-abort-clean:
	@echo $(shell oc get virtualservices | grep "^likes" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^likes" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 5-likes/2-drule.yaml
	oc create -f 5-likes/3-vs.yaml

demo1-circuit-braker:
	oc scale deployment feed --replicas=2
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f demos/1-demo-cb.yaml

demo1-circuit-braker-clean:
	oc scale deployment feed --replicas=1
	@echo $(shell oc get virtualservices | grep "^feed" | cut -f1 -d ' ' | xargs oc delete virtualservices)
	@echo $(shell oc get destinationrules | grep "^feed" | cut -f1 -d ' ' | xargs oc delete destinationrules)
	oc create -f 6-feed/1-drule.yaml
	oc create -f 6-feed/2-vs.yaml

demo2-mirror:
	oc create -f demos/2-demo-debug.yaml
	oc delete -f 6-feed/1-drule.yaml
	oc delete -f 6-feed/2-vs.yaml
	oc create -f demos/2-demo-mirror-rule.yaml
	oc create -f 0-init/12-tel.yaml

demo2-mirror-clean:
	oc delete -f demos/2-demo-debug.yaml
	oc delete -f demos/2-demo-mirror-rule.yaml
	oc delete -f 0-init/12-tel.yaml
	oc create -f 6-feed/1-drule.yaml
	oc create -f 6-feed/2-vs.yaml
	

