provider "aws" {
  region = "us-east-1" # Set your region
}

module "eventbridge" {
  source = "./modules/eventbridge"

  create_bus = false

  rules = {
    s3_folder_trigger = {
      description   = "Trigger Step Function when files are uploaded to the test folder in S3"
      event_pattern = jsonencode({
        source = ["aws.s3"]
        detail = {
          eventSource = ["s3.amazonaws.com"]
          eventName   = ["PutObject"]
          requestParameters = {
            bucketName = ["my162homebucket112211"]
          }
          object = {
            key = [{ prefix = "test/" }] 
          }
        }
      })
    }
  }

  targets = {
    s3_folder_trigger = [
      {
        name            = "TriggerStepFunction"
        arn             = "arn:aws:states:us-east-1:732583169994:stateMachine:my_state_machine"
        attach_role_arn = true
      }
    ]
  }

  sfn_target_arns   = ["arn:aws:states:us-east-1:732583169994:stateMachine:my_state_machine"]
  attach_sfn_policy = true
}

resource "aws_s3_bucket_notification" "test_folder_eventbridge" {
  bucket      = "my162homebucket112211"  
  eventbridge = true                    
}

resource "aws_iam_role_policy" "s3_eventbridge_put_events" {
  name = "S3EventBridgePutEventsPolicy"
  role = aws_iam_role.step_function_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "events:PutEvents",
        Resource = "arn:aws:events:us-east-1:732583169994:event-bus/default"
      }
    ]
  })
}

