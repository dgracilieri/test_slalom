resource "aws_lambda_function" "llm_prompt_upload_function" {
  function_name = "${var.name_prefix}-LLMPromptUploadFunction-${var.name_postfix}"
  description   = "LLMPromptUploadFunction"
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  memory_size   = 128
  timeout       = 60
  filename      = data.archive_file.llm_prompt_upload_function_zip.output_path
  role          = aws_iam_role.llm_prompt_upload_role.arn

  depends_on = [
    data.archive_file.llm_prompt_upload_function_zip
  ]
}