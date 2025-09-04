data "aws_caller_identity" "current" {}
data "archive_file" "llm_prompt_upload_function_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/llm_prompt_upload.py"
  output_path = "${path.module}/../llm_prompt_upload.zip"

}