export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64

fmt:
	- go fmt ./...

build-importer:
	- cd cmd/aws_lambda/importer && go build -a -installsuffix cgo -ldflags '-s -w -extldflags "-static"' -o ../../../bin/bootstrap *.go
	- chmod +x bin/bootstrap
	- cd bin/ && zip -j importer_lambda.zip bootstrap

build-generator:
	- cd cmd/aws_lambda/generator && go build -a -installsuffix cgo -ldflags '-s -w -extldflags "-static"' -o ../../../bin/bootstrap *.go
	- chmod +x bin/bootstrap
	- cd bin/ && zip -j generator_lambda.zip bootstrap

build-indexer:
	- cd cmd/aws_lambda/indexer && go build -a -installsuffix cgo -ldflags '-s -w -extldflags "-static"' -o ../../../bin/bootstrap *.go
	- chmod +x bin/bootstrap
	- cd bin/ && zip -j indexer_lambda.zip bootstrap

build-api-get-certificates:
	- cd cmd/aws_lambda/apigateway/get_certificates && go build -tags lambda.norpc -o ../../../../bin/bootstrap *.go
	- chmod +x bin/bootstrap
	- cd bin/ && zip -j api_get_certificates_lambda.zip bootstrap

build-api-get-certificate-file:
	- cd cmd/aws_lambda/apigateway/get_certificate_file && go build -tags lambda.norpc -o ../../../../bin/bootstrap *.go
	- chmod +x bin/bootstrap
	- cd bin/ && zip -j api_get_certificate_file_lambda.zip bootstrap

deploy:
	- make build-generator
	- make build-importer
	- make build-indexer
	- make build-api-get-certificates
	- make build-api-get-certificat-file
	- cd terraform && terraform apply -var-file='dev.tfvars' -auto-approve

deploy-fast:
	- cd terraform && terraform apply -var-file='dev.tfvars' -auto-approve
