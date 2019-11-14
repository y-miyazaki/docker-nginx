#--------------------------------------------------------------
# arguments
#--------------------------------------------------------------
# Image Name
APP_IMAGE?=proxy
# Container Name
APP_CONT?=proxy
# TAG
TAG?=latest
# container from port
FROM_PORT?=8080
# container to port
TO_PORT?=80
# environment file
ENV_FILE?=config/.local.env

#--------------------------------------------------------------
# make commands
#--------------------------------------------------------------
build:
	docker build --rm -f docker/build/Dockerfile -t $(APP_IMAGE) .

run:
	@docker stop $(APP_CONT)
	@docker rm $(APP_CONT)
	docker run -d -p 80:80 --name $(APP_CONT) $(APP_IMAGE):$(TAG)

run-local:
	-docker stop $(APP_CONT)-local
	docker run --rm -d --env-file=$(ENV_FILE) -p $(FROM_PORT):$(TO_PORT) --name $(APP_CONT)-local $(APP_IMAGE)-local:$(TAG)

check-aws:
	PROFILE=--profile $(PROFILE)
	AWS_ID=$$( \
			aws sts get-caller-identity \
			--query 'Account' \
			--output text \
			$(PROFILE))
	REGION=$$(aws configure get region $(PROFILE))

upload-aws: check-aws
	@$$(aws ecr get-login --no-include-email --region $(REGION) $(PROFILE))
	@docker tag $(APP_IMAGE):$(TAG) $(AWS_ID).dkr.ecr.$(REGION).amazonaws.com/$(APP_IMAGE):$(TAG)
	@docker push $(AWS_ID).dkr.ecr.$(REGION).amazonaws.com/$(APP_IMAGE):$(TAG)

upload-gcp:
# see https://cloud.google.com/container-registry/docs/pushing-and-pulling
	@gcloud auth configure-docker --quiet
	@docker tag $(APP_IMAGE) gcr.io/$(PROJECT_ID)/$(APP_IMAGE)
	@docker push gcr.io/$(PROJECT_ID)/$(APP_IMAGE):$(TAG)

upload-azure:
# see https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-get-started-docker-cli
	@az acr login --name $(REGISTORY)
	@docker tag $(APP_IMAGE) $(REGISTORY).azurecr.io/$(APP_IMAGE)
	@docker push $(REGISTORY).azurecr.io/$(APP_IMAGE):$(TAG)
