#!/bin/bash
cd comments && oc delete -f ./ && oc create -f ./
cd ../feed && oc delete -f ./ && oc create -f ./
cd ../identity && oc delete -f ./ && oc create -f ./
cd ../likes && oc delete -f ./ && oc create -f ./
cd ../links && oc delete -f ./ && oc create -f ./
cd ../receiver && oc delete -f ./ && oc create -f ./
