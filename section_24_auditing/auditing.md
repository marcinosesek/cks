# Audit logs

1. K8s API server generetes audit logs where we can find history of API requests
1. Audit Policy Stages
    * RequestReceived - Stage for events generates as soon as the audit handler received the request, and before it's delegated down the hancler chain
    * ResponseStarted - Once the response headers are seen, but before the respons body is send. This stage is only genereted for long-running requests (eg. watch)
    * ResponseComplete - The response body has been completed and no more bytes will be send
    * Panic - Events genereted when a panic occurred
1. Many API Requests and much data will be genereted
1. There are 4 levels of audit policy rules:
    * None - don't log events that match this rule
    * Metadata - log request metadata (requesting user, timestamt, resource, verb...), but not request or response body
    * Request - log event metadata and request body but not response body
    * RequestResponse - log event metadata, request and response bodies

1. Audit Policy defines what events should be recorded and what data should these contain
    * Rules are processed in order
1. Audit logs can be stored 
    * in jsopn format
    * webhook (external API)
    * Dynamic backend (AuditSink API)

1. Event content:
    * for example: Pods, Secrets, get, delete etc

1. Configure api server to store Audit Logs in json format
    1. Create audit folder:
        ```
        mkdir /etc/kubernetes/audit
        ```
    1. Create audit policy 
        ```
        https://github.com/killer-sh/cks-course-environment/tree/master/course-content/runtime-security/auditing
        ```
    1. Enable audit logs in K8s api server
        ```
        vi /etc/kubernetes/manifests/kube-apiserver.yaml
        ```