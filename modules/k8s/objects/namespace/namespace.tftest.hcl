variables {
  name     = "test"
  expected = <<-EOF
    apiVersion: v1
    kind: Namespace
    metadata:
        name: ${var.name}
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