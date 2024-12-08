resource "aws_iam_role" "step_function_role" {
  name = "step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "step-function-policy"
  description = "Policy to allow Lambda execution"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "*" # Specify your Lambda ARN(s) here
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "step_function_policy_attachment" {
  name       = "step-function-policy-attachment"
  roles      = [aws_iam_role.step_function_role.name]
  policy_arn = aws_iam_policy.step_function_policy.arn
}

resource "aws_sfn_state_machine" "my_state_machine" {
  name     = "my-state-machine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "A simple AWS Step Function example"
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type = "Pass"
        Result = "Hello, World!"
        End = true
      }
    }
  })

  tags = {
    Environment = "Dev"
    Owner       = "YourName"
  }
}
/*
resource "aws_sfn_state_machine" "file_process_step_function" {
  name     = "FileProcessStepFunction"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Step Function triggered by S3 file upload"
    StartAt = "LogFileUpload"
    States = {
      LogFileUpload = {
        Type = "Task"
        Resource = "arn:aws:lambda:us-east-1:732583169994:function:LogFileLambda" # Example Lambda
        End = true
      }
    }
  })
}*/

