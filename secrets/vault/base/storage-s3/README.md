### Storage S3

If you want to use the S3 storage:
1. Put back the **iam.tf** contained in this folder
2. Replace the storage block in your config file by one following this structure:
```
storage "s3" {
  access_key = "abcd1234"
  secret_key = "defg5678"
  bucket     = "my-bucket"
}
```

Don't forget to create a bucket apart with the folder 'init'.
