#!/bin/bash
# Create  project, update SCC to allow anyuid (root) for Invoy proxy 
PROJECT_NAME=nemo
oc new-project ${PROJECT_NAME}
oc adm policy add-scc-to-user anyuid -z default -n ${PROJECT_NAME}
oc adm policy add-scc-to-user privileged -z default -n ${PROJECT_NAME}
oc create -f init/