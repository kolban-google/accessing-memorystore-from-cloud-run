PROJECT_ID=$(shell gcloud config get-value core/project)
APP=cloud-run-app
all:
	@echo "do-all             - Build all the test components"
	@echo "build              - Build the docker image"
	@echo "deploy             - Deploy the image to Cloud Run"
	@echo "create-memorystore - Create the Memorystore instance"
	@echo "create-connection  - Create the VPC Access Connector"
	@echo "clean              - Delete all resources in GCP created by these tests"

create-connection:
	gcloud compute networks vpc-access connectors create my-vpc-connector \
		--network default \
		--region us-central1 \
		--range 10.8.0.0/28

create-memorystore:
	gcloud redis instances create redis1 --region us-central1

deploy:
	REDIS_IP=$(shell gcloud redis instances describe redis1 --region us-central1 --format='value(host)'); \
	gcloud run deploy $(APP) \
		--image gcr.io/$(PROJECT_ID)/$(APP) \
		--max-instances 1 \
		--platform managed \
		--region us-central1 \
		--vpc-connector my-vpc-connector \
		--allow-unauthenticated \
		--set-env-vars "REDIS_IP=$$REDIS_IP"
	@url=$(shell gcloud run services describe cloud-run-app --format='value(status.url)' --region us-central1 --platform managed); \
	echo "Target URL = $$url"

build:
	gcloud builds submit --tag gcr.io/$(PROJECT_ID)/$(APP)

do-all: create-memorystore create-connection build deploy
	@echo "All done!"

clean:
	-gcloud run services delete $(APP) --platform managed --region us-central1 --quiet
	-gcloud container images delete gcr.io/$(PROJECT_ID)/$(APP):latest --quiet
	-gcloud compute networks vpc-access connectors delete my-vpc-connector --region us-central1 --quiet
	-gcloud redis instances delete redis1 --region us-central1 --quiet
