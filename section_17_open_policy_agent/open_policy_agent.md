# Open Policy Agent

1. General purpose policy engine 
1. Not K8s specific
1. Easy implementaion of policies (Rego language)
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