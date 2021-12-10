# Authentication, Autorization, Addmission

1. Authentication
    1. K8s API server ask: "Who are you?"
1. Authorization
    1. K8s API server ask: "What checks what can you do"
1. Admission
    1. K8s API server checks if the limits of pods already reached 

1. All API requests are always tied to:
    1. user
    1. serviceaccount
    1. anonymous requests
1. Every request must be authenticated
1. Don't allow anonymous access
1. Close insecure port
1. Don't expose API server to the outside
1. Restrict access from nodes to API (NodeRestriction)

# Anonymous access
1. It's configured in K8s API server: `--anonymous-auth=true/false` - It's by default enabled - K8s Aapi server needs it for it's own liveness probe
    ```
    # curl -k https://localhost:6443
    {
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {
        
    },
    "status": "Failure",
    "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
    "reason": "Forbidden",
    "details": {
        
    },
    "code": 403
    }
    ```
1. Disable anonymous access
    ```
    apiVersion: v1
    kind: Pod
    metadata:
    annotations:
        kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 192.168.56.2:6443
    creationTimestamp: null
    labels:
        component: kube-apiserver
        tier: control-plane
    name: kube-apiserver
    namespace: kube-system
    spec:
    containers:
    - command:
        - kube-apiserver
        - --advertise-address=192.168.56.2
        - --anonymous-auth=false
        ...
    ```

    ```
    curl -k https://localhost:6443
    {
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {
        
    },
    "status": "Failure",
    "message": "Unauthorized",
    "reason": "Unauthorized",
    "code": 401
    ```
1. Since K8s 1.20 the insecure access is not longer possible:
    ```
    kube-apiserver --insecure-port=8080
    ```

# HTTP/HTTPS access

1. Insecure access:
    1. Request bypasses authentication and authorization modules
    1. Admission controller still enforces
    1. To enable it

        ```
        kube-apiserver --insecure-port=8080
        ```
    
    1. To access K8s api server in insecure way:
    
        ```
        curl http://localhost:8080
        ```

# Send manual API requests
1. Check kube config details:
    
    ```
    kubectl config view --raw
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1ERXpNREl4TXpFd04xb1hEVE14TURFeU9ESXhNekV3TjFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTHBBCjY5U0U5Y0Y2ZXRNQ0JucXZpS1lnMGJhdUNmYlhnVG9iejNIcS9icDNJSTlCd2RmMHh6UGt5QXBKZVhvZ3dndkwKRjZ2TE4yVkkyMGoxc2FxM0ZRWFlYR0d3b09kM3NlUzhSeTl5SncrSUhaaFV4NDJuS3J1NjBnV21HTjR4ZFVjMgpyOVNFN1kzb2FxeTlnYU1zTGpUQkRyc2kxdGJGZ0VCRFVuTEhtYktLUW5wVkhIUHZqWmYvK2V4bUdZR25GSDZ4CkxJRTkrTmpra3gwNmtLbHZ2bmZra2xBeWIyWTZ5ckpoTC9HSE9ucG5ENUl5T0xIRmRCOXJmMjhHUWZ2Y1RnNkIKcjJwNjNaVW13d1VqTjkrTG5hRmF2NDdWeDhYMGVDS3A0TlpZTVZyZU1jSExtREFrN0lBeWgvSGFEbTM5MUpTSgpGc2Q4YWQ2anovalY5L29scHdrQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZPY1RjSkpDMHo0RVpTMVJtS05ZZjRUczZZcmNNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBUFgvSUMyelM1UGkzcmUwVGVpc1g0WW1wc0k5TzR4TXJLaTVrUWdYR3FhSmtMRHExdQpVb04xb1lSeEVLa1UwdXcyYjhLWkpVWkFCeE9lUnFwOUdsdUd3NmhJSGlkTmJpeEh1SkxlNEhHVjFFNnE3elhmCnhMVXNMdlB6T04yNnJaTFczUzNBZGlmSElQdGE5R1hTek5MNmtUOTNvb2JXYVpjQkNjSC9BRDZZYkJ6NmI0SEMKV09jb0FrQmw1MUFQd2lObEM3SjdUZ1Z1U2NkTkFuMFdNVDZUUE15QnMwcFlqaDU2YVEwU2ZVbXZvTWhVa3ByMgpGbmh1QnRYOGlMQmpnbUE3cDlDb1I4V0dIejE5V3M5ak5UNU9Md2p2WG92djVNb2p5Qkp1ZFlnclBoVkVnemQ3CmxPMnB3cERjRzdDYzVaZ28vaUEyWCt0NUhFV0QvVVVTa0NZSAotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
        server: https://192.168.56.2:6443
    name: kubernetes
    contexts:
    - context:
        cluster: kubernetes
        user: jane
    name: jane
    - context:
        cluster: kubernetes
        user: kubernetes-admin
    name: kubernetes-admin@kubernetes
    current-context: kubernetes-admin@kubernetes
    kind: Config
    preferences: {}
    users:
    - name: jane
    user:
        client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURPVENDQWlHZ0F3SUJBZ0lRSjdmS281VHNobDl4UGVqczlzblRoVEFOQmdrcWhraUc5dzBCQVFzRkFEQVYKTVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1CNFhEVEl4TURJd05ESXlNRFl4TlZvWERUSXlNREl3TkRJeQpNRFl4TlZvd1ZERUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdUQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WCkJBb1RHRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERU5NQXNHQTFVRUF4TUVhbUZ1WlRDQ0FTSXcKRFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQUpjNDJ6N2ZmNnZ1RitlaVhBMXFWdkVHemhjLwpnNTRMbWxoTkZvM29Iek9FSlJLbHFPM0c5WVpraWE1b3FNMldsWkp6aHRzOGFUczVWbTlTMFN6UXRucVFlb0xCCnpvNkkrRkJiS3BrY0k5REhWWW55ZTZVWjVOZmlQRERlNTFMN00zRGVFT1BuWGZVc3JsNk03ODdOMVZZSFJHbmMKU1pIaHBtZHhJRTRvdTVMcG5QcTZjS2tCUXEvS2RtTGthbCtLM21xS2c2cnJ2b050Vm5HMGcwUTQwYkw2Zmc5SAphSkZNZTBFSGFrU1BCUTFkclRxQW1yZE1YaUd6dkRDMmsrL2JyZGJIMW83RFVndzQ3OGhTY1ZLRnU2YUozOFZXCkRlZ25URTk3NlYyT1FBY3BzUmVYVWo0MTZuNUZNVjIrVFRia2h0R0NyRlBUSmxENE9mOUd5ekpudUNzQ0F3RUEKQWFOR01FUXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd0l3REFZRFZSMFRBUUgvQkFJd0FEQWZCZ05WSFNNRQpHREFXZ0JUbkUzQ1NRdE0rQkdVdFVaaWpXSCtFN09tSzNEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFSU3g4CkdwOVM5UHZyOXhSbjRNMzRqNHYrUlY3Ykpjam9ybUJIazNKY0ovV0E2bFAzTE82bDRIOE9iQXNyZEJVd1llYm0KNnk1OWRLNlNjS2RDeEM4aUlIRDNqL1hGUk9LL2lQam15Z0NJODJDRkZlWTVqem1zanlhcUdBS2FZSDF3NmRaSwpKSjdXdTE0SEdWZTdHeENpeEZxTUxOSmFWRGVIVUd3SXZVY2YwZVZSU05FMmprZHYwMWsrbmhoZmsxQWlWTmJRCm8xcFgwcm9yZjVCeWhMaFVSUlZiaTJLTjdUUFkwb1EzQk1uYXJpMGo5WnFuRFZUUjdoZ2hXTmRYUC9WZjY4MkgKYWk2eXF5c3Zlc3hCWVhHMEcvb2p5cXlTMWgxMTBodUJ0a0c0Tm1hWDN3bFFLaDJpdlBqV3FTcGJwN3pHM3hHNQpocGZyMFNyMmVKbWcwSG01dXc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
        client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBbHpqYlB0OS9xKzRYNTZKY0RXcFc4UWJPRnorRG5ndWFXRTBXamVnZk00UWxFcVdvCjdjYjFobVNKcm1pb3paYVZrbk9HMnp4cE96bFdiMUxSTE5DMmVwQjZnc0hPam9qNFVGc3FtUndqME1kVmlmSjcKcFJuazErSThNTjduVXZzemNONFE0K2RkOVN5dVhvenZ6czNWVmdkRWFkeEprZUdtWjNFZ1RpaTdrdW1jK3JwdwpxUUZDcjhwMll1UnFYNHJlYW9xRHF1dStnMjFXY2JTRFJEalJzdnArRDBkb2tVeDdRUWRxUkk4RkRWMnRPb0NhCnQweGVJYk84TUxhVDc5dXQxc2ZXanNOU0REanZ5Rkp4VW9XN3BvbmZ4VllONkNkTVQzdnBYWTVBQnlteEY1ZFMKUGpYcWZrVXhYYjVOTnVTRzBZS3NVOU1tVVBnNS8wYkxNbWU0S3dJREFRQUJBb0lCQUNZWDUzcmVHQzQ2U3dGSgpzQUNkSWd1VFdFVVk5ZEhSUUc4djlCZUpPcHJpbGVndG5QRlE1amFWaXUxSlpnUnNBMytoNUgzRHFRcUhOaFBTCisraGJKeXlXeXBXM3RvM0hTUzRNMlIwNnJuY0FUN2J4UTE1aXVIZjlnSVliRUpDaHdPS1V2aEo3RFBzZTUwbmcKSE9TdWl5Z2hxb1UwUGNBbTVLRTRLUmduUUtFUUh4cVJ6RVorRkNleERGeWpJT1AyMDBOYVQ5alY1aEtaTHNnWAplR3pNWHNjV1BNcS9aNHA5R1dFd0NnV1AvR0VXY1YwL0NkTUwwMHQ2WTNiYWVyYzFpN2hoNmN4UGV5M0lkY01hCnJNaHkydzU0cS9heTBGQmpyRUE0dU90cXVzRkdlRnZkODFtaDAxY1NuUFE3YWFCL2FLR3FKV3BabCtvY3VIbHMKRGxDWGJHRUNnWUVBeUptWC9ROGU2a3hpWWd4cjREekl3UjFlcEJQclRtYTYzSlBTRWkrSWJIZFJIUExwTXo5cwpSNFA5SmxMNGNsQ1diUGZrZ01xbHMzT0dyZ1pRRE1PT1RKSVlIdFJuVjVJbUkzQloyQWRsdWJSNi9hVnY2a0ZICktnY0lva29OREJmQnc1eklndDRDcnhjejU2dVBoVmY5dXZkQU4xcnRPakY1RC9YamtWUkk5cHNDZ1lFQXdQdy8KNHJ1cThnQk0xVmJGL01LRE96WUt2MzBjQnBqTEZFc3IrMkYvTXdQcU12NS93cUpNa0o1OFJISXpXTVd5aXVZVApPUHVteFIxVk4vUFJYRDFtNzZMcEp0UjMzZ3lLTFFEczNLc0tIcXlqamdLMERXMTRUb0orQlliNUZSdVl0NmFZCkRYU2VwYmZUdmN3S3pySHVmRkZPMUh4ZEhrSy94WUVyS0cyWGxiRUNnWUVBcjlwVjd6WU9OLzkyVDlYcnk4djkKZ2EycGhkVWdkcjZBR1ZaTTFqeHRNQWo1UnBONzg3MHB3eGZtR0c2cjlpckhkQWRzZmFzb3o4UDYwUndmbU5EbQpNaUh3bXpaQTBmZ0JEeGd5NnJxeFpyYmRDdmE0d1hjd1Y1dUs2aHBZamIxVjA1SGlCVGR5eXVOZ1VUdUl1YkNGCmNoM0dZY0NJTG5lb1ZXR05lWjJWeVBrQ2dZRUF2NkY3K3JRcHdsYWo5UEJPZDNmYkFnL2V5bGo4WEZ5YXc1TUYKb0lBbTQ4eU9ZWWF2N09CbXNQQi9LeVJQY21ZVnJiRmJBeWw0WjZHQi9xYUFqVngzZTV2RWN3ZGw0N3VGOWJ4RwpkN1RydnB2bGFOMnNWdTBPR3IrZlRmUENJTUNmZkRYVUpRQlpqT3NtT2dDRDlzMWVxRm5Bc21TdnZwMi9lZXFTCnBYbDFuWEVDZ1lFQWxYcEFlYXdhM1ltL0VkMHhIRGpmWGtabWFHVUQvOFg0dkNWUlc2akdMMk95NlkrWmVwNCsKK015S1BaRVVWSWdHS1lmcWhNTzBQUUhKU2ZRYnBvV3dWRXlWaDBEKzFQL1pPckpseGhjbFptcTlieWI5L0JJSgpBQStqeDRYbXhOMVJsWG02cjlCUXhVbnBEQVo0MG5VSDFod0hvdnNMQzd0aUlXcjdYMmw1Tjl3PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
    - name: kubernetes-admin
    user:
        client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURFekNDQWZ1Z0F3SUJBZ0lJUENFTmhYcElsMHN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TVRBeE16QXlNVE14TURkYUZ3MHlNakF4TXpBeU1UTXhNRGxhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXhGaldZYTZhaDhuTWhKMHcKSG5VVVNycklyeXdxM0dNZVhQRjJ3Y01Hd1Z5cllkQTVoR0UxVUc4RWRlbDVhakQwQk12TzdnQUM0V0VxdDNpNwpyQmpKU0hDM0JaZXNrSTZ0MGtmQjZ5M1grRW94TXd3Zk9Ra3BRZzhQekN2Snd5cThKRjVPVWJpSGQ4SjQ3QTBjCjdvd291cXFJbGJRUStKMkJlSVVvLzIrZG1JT3NWRXp1THVzL0dVMTZkbyswMHlJWGxncHVQWVN3QzBoMTFoaXoKNjhGODNndGZSVGJoTi8yeU5heTlSWFhZSElWdWlYeDhtMm9HSFpEL091bkxyMEFWMDFERGhaR1lTMWt5eVhGVwpoVEJZeDBHR0ZTcDZsQWZLUnBkNEJtdmx6QWhsL3MzMWZjUlJ0VFRsN2I2Z1p0K2toOGVFK2dWYXlNTitIRkFuClVtdWh5d0lEQVFBQm8wZ3dSakFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0h3WURWUjBqQkJnd0ZvQVU1eE53a2tMVFBnUmxMVkdZbzFoL2hPenBpdHd3RFFZSktvWklodmNOQVFFTApCUUFEZ2dFQkFKdGNsWnBXU0huWkE5LzcxM00yVE1DZkl1aTV2RFUzZjVnam9MaEZnMllINEhuQmRsMGpGenkzCnJJdzMwckxwbzBJSk1lUFNKNGlHZ0oxQUVyRUY5TzdmYkMvRWdEVk9FSVlyQXJaTGRCQ3lyYjlRUDgwQm5qbDMKeHpSS1RtTGFxL1VkK2hCQnc3SG4vaUxSZGNKUS80L2ZtTDZSbk9KM09xT0FCT21RNEIzeHNNRW5uZm43dS92VwpaWGpzVHJiZzRvckF1RlVTTlFIK0taaFFteTVhSnJBdEZranZpZ2RFeGdQYWZpL0xRTlBZUG1HVWJyU0FoRHNLCjg3VFpSYUFwRXFOWkdFZUVWYlExOW1BdzVOYTF0NCtJUUtBYUFHeTlFVmd3bTNHTVg5S3dCY1NDQmprWmRVcW4Kc0svRjg4ZlZ4VEpoQXBNZ0JoVm9OaC93YSsyVjY1Zz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
        client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBeEZqV1lhNmFoOG5NaEowd0huVVVTcnJJcnl3cTNHTWVYUEYyd2NNR3dWeXJZZEE1CmhHRTFVRzhFZGVsNWFqRDBCTXZPN2dBQzRXRXF0M2k3ckJqSlNIQzNCWmVza0k2dDBrZkI2eTNYK0VveE13d2YKT1FrcFFnOFB6Q3ZKd3lxOEpGNU9VYmlIZDhKNDdBMGM3b3dvdXFxSWxiUVErSjJCZUlVby8yK2RtSU9zVkV6dQpMdXMvR1UxNmRvKzAweUlYbGdwdVBZU3dDMGgxMWhpejY4RjgzZ3RmUlRiaE4vMnlOYXk5UlhYWUhJVnVpWHg4Cm0yb0dIWkQvT3VuTHIwQVYwMUREaFpHWVMxa3l5WEZXaFRCWXgwR0dGU3A2bEFmS1JwZDRCbXZsekFobC9zMzEKZmNSUnRUVGw3YjZnWnQra2g4ZUUrZ1ZheU1OK0hGQW5VbXVoeXdJREFRQUJBb0lCQUczT0xONW1Fais4U0djbApyU0pyWVpURlRyUkFaQnZxUnJHOXpDZGlWU1hRR0h4VVFjWlp3c0lmeEFQWk5UQ0EvZ2Fzb0NZVDFZaUxtYU1QCm53MElzNUNTa0poTkVaR3FhV1UvQWlEdSsyZjh2ZlVKWTNDM1FkNlNvOGdQK1A3dnFGWkNjMVJhZVZBdGJ3aTcKOEtFcnV4OWhmWThUSzZhT0Z6ajZaMG9xOXB5eWtoUGVjdXhobUJRU2FTbVhST2hzTENNWWxLSGp0RkF3aUNsdApDaEtLZEUwS0hEQTN1Z0Yzc3NGY29aUXpwL1NhNk8vMG9hZFNuSGdISHRtakR5OTVOV1lmYjBXQk1HSk1hV3hpCkdPdDNPNFdLS2Z4QktHck5OZUFva3diNVZ5ZUEzTURxKzI1amZFWFpTT0tNVzRkbUdkVHZUd0RUSTJMRkU1bHMKcmc2ZzV1a0NnWUVBeHFVNkpnVEoxNFhGdk9aSWxNRHA1L1ZOVWJ0VGIvYU5SYjZmMi9WcUkwTHdycEVXNnlrTQpmR0lsRzFzZ3laOGpNK2YrSjFmd2NPM2h0RHI2eG12d0h6enRqb2kvMW44cVFrZy9ncy9XQXN6RU12RXN2djFMCnFiRERldE0xcEMzR3dzNlN6OVo1cGFack5OR2RZTTl5WnRsUG0vemR2RzFpUUQ5eDZWZmV2ODhDZ1lFQS9RbTUKdHBCbCttbkR3bDUrZjAra3JWVGRZZzlZaldrVXJMakkzenE1eWJjcWxEN0gzODkzWnBZMjZxRFp1WTlMTHJBUgpHYmZzZUdJcXNiOTFKTnZFVXU1ajVVNHMxU2Z6ZkowL3Uwcm5SbmxMT2VGd1hxRGJ3NEtjR0dwK2ZEcVA2OXdkCmF0WGFXOXpuemlBOE9TSGNjY0tNZVV0Q0FYVTl5TUpSSTRTajRVVUNnWUF4WlpyOUkwbXgvNEQ1aFdaZEgwL0wKTDdQSGRFYStXOWdybE1pWjRRQkF2bit0V1VVU3UwVndsTk5YWnlUVEhuQ1prc0lmdEgyRkI1S054L0RlY0s3bwpoYlVwTVpaSzE1cUJtd2U0RnNqSUwzVkdtYlNmMWNyLzZvWGh3QzNob3NSL1l2RWRIOTltTXVrTDNHZy9UN2JLCkhwWHVXMFlrZWlycGdSMXBna0ZRL3dLQmdGTFRlQ0syS1d0S2EzV1lFTGdEamRmZXk0aHBsWWJVT3B3KzhDR0IKeTRhbm1oeGtZSEIyTEpNNzRFWDAyTS9RZzcrSWlsQnN6ODZuODJtelRkait4c2lPbDh4YlJubVBWamdZRU9CeApxRHA5UVk1MHFKK1E3OTZUUmgwSDN0Y3pKQ0VFTCt6a2kxRStnZklLd3l2QVZiUTNCbHc5c2lGZ0N4Vkg1ZDlHCmI0NHhBb0dCQUxEWnd0RC8wbUlYT3ltS1lid1lyT0dTY1RrWUczdklpbW5jWGs3RGM1OHlrZmpGZmhNZmZSZkYKU3VPNUgxd3FPN280MTJVRkZrYzhqQ2JTNlJuWEtuaDZPUnROcFpZQ2NOdkNNOEp2ZlU5c3ZXcFc0dHBiWGJZRgpBL3N1UVR5dVB3ZC9EOGRFS2hFVXc1Ty8wRUw5bTlsT2prb28xb083bUdXTGpIZHBORzZUCi0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
    ```
1. Save to files ca, client cert and client key
1. Access K8s API server

    ```
    curl https://192.168.56.2:6443 --cacert ca
    ```

    ```
    curl https://192.168.56.2:6443 --cacert ca --cert crt --key key
    {  "paths": [    
        "/.well-known/openid-configuration",
        "/api",
        "/api/v1",
        "/apis",
        "/apis/",
        "/apis/admissionregistration.k8s.io",
        ...
    ```

1. Make K8s API server reachable from the outside
    1. Edit K8s svc and change it to `NodePort`
    1. Access K8s API server from outside

        ```
        curl https://192.168.56.2:31168 -k
        {
        "kind": "Status",
        "apiVersion": "v1",
        "metadata": {
            
        },
        "status": "Failure",vi /etc/kube
        "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
        "reason": "Forbidden",
        "details": {
            
        },
        "code": 403
        }
        ```

1. NodeRestriction
    1. It's Addmission Controller and can be enabled in K8s API server: `enable-admission-plugins=NodeRestriction`
    1. It limits the node labels a kubelet can modify
    1. It ensure secure workload isolation via labels
    1. Log in to worker node
    1. Check if we can access K8s api server
        
        ```
        root@kubenode01:~# export KUBECONFIG=/etc/kubernetes/kubelet.conf 
        root@kubenode01:~# 
        root@kubenode01:~# 
        root@kubenode01:~# kubectl get ns
        Error from server (Forbidden): namespaces is forbidden: User "system:node:kubenode01" cannot list resource "namespaces" in API group "" at the cluster scope
        kubectl  get nodes
        NAME         STATUS   ROLES                  AGE     VERSION
        kubemaster   Ready    control-plane,master   6d23h   v1.20.2
        kubenode01   Ready    <none>                 6d23h   v1.20.2
        ```

    1. From worker node we can't change labels of other nodes. We can only changed labels of it's own node except labels that starts with: `node-restriction.kubernetes.io`
        ```    
        # kubectl  label node kubemaster  cks/test=yes
        Error from server (Forbidden): nodes "kubemaster" is forbidden: node "kubenode01" is not allowed to modify node "kubemaster"

        # kubectl  label node kubenode01  cks/test=yes
        node/kubenode01 labeled
        # kubectl  label node kubenode01  node-restriction.kubernetes.io/cks/test=yes
        Error from server (Forbidden): nodes "kubenode01" is forbidden: is not allowed to modify labels: node-restriction.kubernetes.io/cks/test
        ```

1. Resources
    
    https://kubernetes.io/docs/concepts/security/controlling-access