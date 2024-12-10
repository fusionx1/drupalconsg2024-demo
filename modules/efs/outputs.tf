output "fs_id" {
  value = aws_efs_file_system.files.id
}

output "files_access_point" {
  value = aws_efs_access_point.files.id
}