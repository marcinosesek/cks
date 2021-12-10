# Open Policy Agent

1. General purpose policy engine 
1. Not K8s specific
1. Easy implementaion of policies (`Rego` language)
1. In K8s it uses Admission Controller
1. Does not know concepts like pods, deployments

# OPA GateKeeper

1. Provides K8s CRD 
    1. ConstraintTemplate
    1. Constraint: K8sRequiredLabels

1. Install OPA Gatekeeper

    ```
    kubectl create -f https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/course-content/opa/gatekeeper.yaml
    ```

1. Create Deny All Policy

    ```
    root@kubemaster:~# kubectl get crd
    NAME                                                 CREATED AT
    configs.config.gatekeeper.sh                         2021-02-09T21:30:36Z
    constraintpodstatuses.status.gatekeeper.sh           2021-02-09T21:30:36Z
    constrainttemplatepodstatuses.status.gatekeeper.sh   2021-02-09T21:30:36Z
    constrainttemplates.templates.gatekeeper.sh          2021-02-09T21:30:36Z
    root@kubemaster:~# 
    ```

    1. Create ConstraintTemplate

        ```
        kubectl apply -f alwaysdeny_template.yaml
        ```
    
    1. When we create this template OPA will create K8sAlwaysDeny crd

    1. Create constraints that will be object of K8sAlwaysDeny crd
        ```
        kubectl apply -f all_pod_always_deny.yaml
        ```
    1. OPA will apply only to new create pods. It will not apply to already running pods

1. `Rego` playground

    https://play.openpolicyagent.org/
