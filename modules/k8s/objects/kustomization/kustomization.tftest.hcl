variables {
  name                 = "test"
  namespace            = []
  patches              = []
  resources            = []
  helm_charts          = []
  config_map_generator = []
  secret_generator     = []
  expected             = <<-EOF
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    namespace: test
    helmCharts:
      - name: test
        releaseName: test
        version: 2.23.0
        repo: https://helm.test.com/v2
        namespace: test
        valuesFile: ./values.yaml
        valuesInline:
            test: test
        
    secretGenerator:
      - name: gcloud-auth
        namespace: litellm
        behavior: create
        options:
            disableNameSuffixHash: true
        files:
        - secrets/service_account.json

    configMapGenerator:
      - name: test
        namespace: test
        behavior: create
        envs: []
        files: []
        options:
            disableNameSuffiHash: true

    resources: []
    patches: []
    EOF
}

run "build" {}

run "verify" {
  command = plan

  assert {
    condition     = yamldecode(run.build.manifest) == yamldecode(var.expected)
    error_message = "Namespace manifest produced unequal output."
  }
}