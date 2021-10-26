# ci-pipeline-example

See the .gitlab-ci file

# Kubernates

Dev deploy:

    export KUBECONFIG=~/Downloads/k8s-cluster_kubeconfig.yaml
    kubectl apply -f deployments/configmap.yml --namespace dev
    kubectl apply -f deployments/test1-deploymentconfig.yml --namespace dev
    kubectl apply -f deployments/test2-deploymentconfig.yml --namespace dev
    kubectl apply -f deployments/redis-deploymentconfig.yml --namespace dev
    kubectl apply -f deployments/ingress.yml --namespace dev


`kubectl get pod --namespace dev`

    NAME                                READY   STATUS    RESTARTS   AGE
    test1-deployment-5fff968b5-vcqh9    1/1     Running   0          2m26s
    test2-deployment-79fbd9d5b9-5n7bf   1/1     Running   0          2m18s

`kubectl get services  --namespace dev`

    NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
    test1   ClusterIP   10.254.200.190   <none>        5678/TCP   2m59s
    test2   ClusterIP   10.254.185.24    <none>        5678/TCP   3m3s

`kubectl get deployments  --namespace dev`

    NAME               READY   UP-TO-DATE   AVAILABLE   AGE
    test1-deployment   1/1     1            1           4m29s
    test2-deployment   1/1     1            1           4m21s