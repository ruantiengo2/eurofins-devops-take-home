# Step 5 - Docker Image Checklist (Optional)

## Application image

- [ ] Add a Dockerfile for the HelloWorld web application from Step 1.
- [ ] Build a Docker image containing the published application and its runtime dependencies.
- [ ] Configure the image to start the HelloWorld application and listen on a documented container port.

## CI pipeline

- [ ] Extend the Step 1 pipeline to build the Docker image automatically when repository changes trigger CI.
- [ ] Keep the existing application build, automated tests and downloadable application package.
- [ ] Ensure the pipeline fails if the Docker image build or publication fails.

## Image registry

- [ ] Select Docker Hub or an alternative container registry.
- [ ] Configure the repository/image name and tags used by the pipeline.
- [ ] Configure registry authentication without storing credentials in source control.
- [ ] Publish the built image to the selected registry from CI.

## Completion criteria

- [ ] Verify that all Step 1 deliverables remain available, including the application package.
- [ ] Verify that CI creates the HelloWorld Docker image successfully.
- [ ] Verify that the image is uploaded to Docker Hub or the chosen alternative registry.

## Supporting validation and documentation

- [ ] Pull the published image and verify that a container starts successfully.
- [ ] Verify that the containerized application returns Hello World and a healthy response on its documented endpoints.
- [ ] Document the image location, tags, required registry access, container port and local build/run commands.
- [ ] Record a successful CI run and the published image tag or digest used for validation.

Step 5 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Its required outcome is a Docker image built by the existing pipeline and uploaded to a registry, while preserving Step 1 deliverables. The supporting checks above help verify that the published image is usable.

All items remain pending. This checklist does not implement Docker packaging or registry publication. A scripted Docker deployment belongs to Step 6 and is outside this step.
