#! /usr/bin/env bash

oc new-project desenv
oc new-project teste
oc new-project prod

oc new-app --template=jenkins-ephemeral --name=jenkins -n desenv

oc adm policy add-role-to-user edit system:serviceaccount:desenv:jenkins -n teste
oc adm policy add-role-to-user edit system:serviceaccount:desenv:jenkins -n prod

oc create secret generic repository-credentials --from-file=ssh-privatekey=$HOME/.ssh/id_rsa --type=kubernetes.io/ssh-auth -n desenv
oc label secret repository-credentials credential.sync.jenkins.openshift.io=true -n desenv
oc annotate secret repository-credentials 'build.openshift.io/source-secret-match-uri-1=ssh://github.com/*' -n desenv
oc new-build ssh://git@github.com/leandroberetta/openshift-cicd-demo.git --name=hello-service-pipeline --strategy=pipeline -e APP_NAME=hello-service -n desenv
