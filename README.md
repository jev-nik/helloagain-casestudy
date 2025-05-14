# helloagain-casestudy
A case study for the copany Hello Again GmbH

aws dynamodb create-table \
  --table-name helloagain-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region eu-central-1

