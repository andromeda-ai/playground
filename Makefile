# Define the base image names
CPU_IMAGE_BASE := ghcr.io/andromeda-ai/playground:cpu
GPU_IMAGE_BASE := ghcr.io/andromeda-ai/playground:gpu

# Define the base images for CPU and GPU
CPU_BASE_IMAGE := ubuntu:22.04
GPU_BASE_IMAGE := nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Function to generate a new version number
VERSION := $(shell date +%Y%m%d%H%M)

# Target to build CPU image
build-cpu:
	@echo "Building CPU Docker image with version $(VERSION)..."
	docker build -t $(CPU_IMAGE_BASE)-$(VERSION) -t $(CPU_IMAGE_BASE)-latest -f Dockerfile . --build-arg BASE_IMAGE=$(CPU_BASE_IMAGE) --platform=linux/amd64

# Target to build GPU image
build-gpu:
	@echo "Building GPU Docker image with version $(VERSION)..."
	docker build -t $(GPU_IMAGE_BASE)-$(VERSION) -t $(GPU_IMAGE_BASE)-latest -f Dockerfile . --build-arg BASE_IMAGE=$(GPU_BASE_IMAGE) --platform=linux/amd64

# Target to deploy both images
deploy: build-cpu build-gpu
	@echo "Deploying Docker images with version $(VERSION)..."
	docker push $(CPU_IMAGE_BASE)-$(VERSION)
	docker push $(CPU_IMAGE_BASE)-latest
	docker push $(GPU_IMAGE_BASE)-$(VERSION)
	docker push $(GPU_IMAGE_BASE)-latest

# Phony targets
.PHONY: build-cpu build-gpu deploy
