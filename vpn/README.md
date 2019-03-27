### OpenVPN
- Removes private keys from the instance
- Push them to S3, restrict access to the bucket
- Pull certificates from S3 if exists
- Lambda to sign and revoke CSRs