IMAGE_NAME = pgmoneta-rocky8
TAG = latest
KIND_CLUSTER = pgopr-new

.PHONY: build load clean rebuild

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Load into kind cluster
load:
	kind load docker-image $(IMAGE_NAME):$(TAG) --name $(KIND_CLUSTER)

# Build + Load in one step
rebuild: build load

# Remove the image
clean:
	docker rmi $(IMAGE_NAME):$(TAG)

# Full clean + rebuild
reset: clean rebuild