#! /bin/bash

chmod +x ./scripts/*

cd scripts/ &&  ./preready.sh && ./createCA.sh && ./deployKubectl.sh && ./deployEtcd.sh && \
   ./deployFlannel.sh && ./deployHaproxy.sh && ./deployKube-apiserver.sh && \
   ./deployKube-controller-manager.sh && ./deployKube-scheduler.sh && \
   ./deployDocker.sh && ./deployKubelet.sh && ./deployKube-proxy.sh
   
