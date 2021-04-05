# Static Analysis

1. Looks at source code and text files
1. Check against rules
1. Enforce rules
1. Used in CI/CD

# Kubesec

1. kubesec.io
1. docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < pod.yaml

# OPA Conftest

1. Unit Test framework for Kubernetes configurationd
1. Uses Rego language
1. https://github.com/open-policy-agent/conftest