# Step 5 - Docker Image Checklist (Optional)

Status: **17 of 17 items complete**, validated by the successful run recorded below.

## Application image

- [x] Add a Dockerfile for the HelloWorld web application from Step 1.
- [x] Build a Docker image containing the published application and its runtime dependencies.
- [x] Configure the image to start the HelloWorld application and listen on a documented container port.

## CI pipeline

- [x] Extend the Step 1 pipeline to build the Docker image automatically when repository changes trigger CI.
- [x] Keep the existing application build, automated tests and downloadable application package.
- [x] Ensure the pipeline fails if the Docker image build or publication fails.

## Image registry

- [x] Select Docker Hub or an alternative container registry.
- [x] Configure the repository/image name and tags used by the pipeline.
- [x] Configure registry authentication without storing credentials in source control.
- [x] Publish the built image to the selected registry from CI.

## Completion criteria

- [x] Verify that all Step 1 deliverables remain available, including the application package.
- [x] Verify that CI creates the HelloWorld Docker image successfully.
- [x] Verify that the image is uploaded to Docker Hub or the chosen alternative registry.

## Supporting validation and documentation

- [x] Pull the published image and verify that a container starts successfully.
- [x] Verify that the containerized application returns Hello World and a healthy response on its documented endpoints.
- [x] Document the image location, tags, required registry access, container port and local build/run commands.
- [x] Record a successful CI run and the published image tag or digest used for validation.

Step 5 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Its required outcome is a Docker image built by the existing pipeline and uploaded to a registry, while preserving Step 1 deliverables. The supporting checks above help verify that the published image is usable.



## Successful CI validation

[Successful run](https://github.com/ruantiengo2/eurofins-devops-take-home/actions/runs/36648785834), source commit `6ea9a19aedef0290e9e941189f12071f700f58f4`, executed on Ubuntu 24.04 with Docker Engine and PowerShell 7 on 2026-09-29 (Brasilia; 2026-09-30 UTC). Both build and image jobs passed.

- Solution restore/build and API integration tests succeeded.
- The `HelloWorldApi` artifact (ID `11069272250`, 355754 bytes) was uploaded, downloaded by the image job and extracted. Required nonempty files were verified: `HelloWorldApi.dll`, `.deps.json`, `.runtimeconfig.json`, `web.config` and `appsettings.json`.
- Image: `ghcr.io/ruantiengo2/eurofins-devops-take-home:sha-6ea9a19aedef0290e9e941189f12071f700f58f4`.
- Published and pulled digest: `ghcr.io/ruantiengo2/eurofins-devops-take-home@sha256:b9738b3505ee459455e62d0fad5cf598be3b9c27b79d4e0177107c3df558ff8d`.
- Both the built image and the pulled digest returned HTTP 200 with `Hello World!` on `/` and `Healthy` on `/health`.
- The actual PowerShell deployment script pulled and started that image with host port 18080 mapped to container port 8080; both endpoints passed again.
- Repeating deployment with the same name failed as expected and preserved the original container ID.
- `-UseHelloWorld` pulled the official example, printed `Hello from Docker!` and exited with code 0. Its digest was `sha256:5e23090353324d887c48ad5e5c56d294eab81588df9605b07d1afe895f9cc8f8`.
- Test containers were removed in cleanup. This validates deployment on the Linux CI host; local Windows Docker execution was not performed.
