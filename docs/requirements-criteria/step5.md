# Step 5 - Docker Image Checklist (Optional)

## Application image

- [x] Add a Dockerfile for the HelloWorld web application from Step 1.
- [ ] Build a Docker image containing the published application and its runtime dependencies.
- [x] Configure the image to start the HelloWorld application and listen on a documented container port.

## CI pipeline

- [x] Extend the Step 1 pipeline to build the Docker image automatically when repository changes trigger CI.
- [x] Keep the existing application build, automated tests and downloadable application package.
- [x] Ensure the pipeline fails if the Docker image build or publication fails.

## Image registry

- [x] Select Docker Hub or an alternative container registry.
- [x] Configure the repository/image name and tags used by the pipeline.
- [x] Configure registry authentication without storing credentials in source control.
- [ ] Publish the built image to the selected registry from CI.

## Completion criteria

- [ ] Verify that all Step 1 deliverables remain available, including the application package.
- [ ] Verify that CI creates the HelloWorld Docker image successfully.
- [ ] Verify that the image is uploaded to Docker Hub or the chosen alternative registry.

## Supporting validation and documentation

- [ ] Pull the published image and verify that a container starts successfully.
- [ ] Verify that the containerized application returns Hello World and a healthy response on its documented endpoints.
- [x] Document the image location, tags, required registry access, container port and local build/run commands.
- [ ] Record a successful CI run and the published image tag or digest used for validation.

Step 5 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Its required outcome is a Docker image built by the existing pipeline and uploaded to a registry, while preserving Step 1 deliverables. The supporting checks above help verify that the published image is usable.

Docker packaging, registry publication steps and automated container checks are implemented. Runtime validation and actual publication remain pending because GitHub Actions could not allocate a runner. A scripted Docker deployment belongs to Step 6 and is outside this step.

## Validation evidence

Attempted CI run: [CI #14](https://github.com/ruantiengo/eurofins-devops-takehome/actions/runs/36646225065), commit `15d0bd0902404174d207f54533167b94e42e85b2`.

GitHub reported: "The job was not started because your account is locked due to a billing issue." The build job executed no steps and the image job was skipped. This is not a successful build or publication; no validated image tag or digest is available from this run. Docker is also unavailable on the local Windows validation machine.

After the account owner resolves the GitHub billing lock, rerun CI and verify both jobs succeed, the `HelloWorldApi` artifact is downloadable, and the image job summary records the published digest and successful endpoint checks. The intended tag for the run above is `ghcr.io/ruantiengo/eurofins-devops-takehome:sha-15d0bd0902404174d207f54533167b94e42e85b2`; its existence has not been verified.

See the [README](../../README.md#docker-image-step-5) for registry access, tags, container port and local build/run commands.
