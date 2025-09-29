data "aws_iam_policy_document" "bedrock-policy" {
  statement {
    sid    = "AllowModelInvocation"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ListInferenceProfiles"
    ]
    resources = [
      "arn:aws:bedrock:*:*:*",
      "arn:aws:bedrock:*:*:*/*",
      "arn:aws:bedrock:*:*:*:*",
    ]
  }
}