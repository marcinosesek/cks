kubectl create ns blacklist-ns

echo '
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blacklistimages
spec:
  crd:
    spec:
      names:
        kind: BlacklistImages
  targets:
  - rego: |
      package k8strustedimages
      images {
        image := input.review.object.spec.containers[_].image
        not startswith(image, "docker-fake.io/")
        not startswith(image, "google-gcr-fake.com/")
      }
      violation[{"msg": msg}] {
        not images
        msg := "not trusted image!"
      }
    target: admission.k8s.gatekeeper.sh
' > blacklistimages.yaml

kubectl apply -f blacklistimages.yaml

echo '
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: BlacklistImages
metadata:
  name: pod-trusted-images
spec:
  match:
    kinds:
    - apiGroups:
      - ""
      kinds:
      - Pod
' > pod-trusted-images.yaml

kubectl apply -f pod-trusted-images.yaml