# Step 6 - Docker Deployment Checklist (Optional)

## Deployment script

- [x] Create a script to deploy the HelloWorld Docker image from Step 5 to Docker Engine on a Windows or Linux server.
- [x] Accept the image reference as a parameter, including a tag or digest.
- [x] Pull the selected image and create/start its container.
- [x] Publish the application's container port 8080 on a documented, configurable host port.

## Prerequisites and registry access

- [x] Check that Docker is installed, its engine is running and the executing user can access it.
- [x] Document the supported host and shell; the Step 5 Linux image requires a Linux container engine, including when hosted on Windows.
- [x] Document authentication for private GHCR images without storing credentials in source control.
- [x] Support the assignment's alternative `hello-world` image when the Step 5 image is unavailable.

## Completion criteria

- [x] Verify that Step 1 deliverables remain available, including the application source, CI pipeline and downloadable application package.
- [x] Execute the deployment script successfully against a Docker Engine and record the image reference and result.

## Supporting validation and documentation

- [x] For the Step 5 web image, verify that the container stays running and GET `/` returns HTTP 200 with `Hello World!`.
- [x] For the Step 5 web image, verify that GET `/health` returns HTTP 200 with `Healthy`.
- [x] If using the alternative `hello-world` image, verify its expected output and successful exit code instead of HTTP endpoints.
- [x] Define and test what happens when the named container already exists; avoid modifying unrelated containers.
- [x] Fail clearly when pulling the image, creating the container or starting the application fails.
- [x] Document prerequisites, parameters, registry access, deployment commands, endpoint URLs and container cleanup.
- [x] Record validation evidence, including host/engine, script command without secrets, image tag or digest and observed result.

Step 6 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). It asks for a script that deploys the previous step's image to Docker Engine on Windows or Linux, and explicitly permits Docker's official `hello-world` image when the application image has not been published. The assignment's stated completion criterion preserves Step 1 deliverables; the deployment and supporting checks above make the script's behavior verifiable.

The alternative `hello-world` image prints a message and exits successfully. It is not the ASP.NET application and does not expose HTTP endpoints. Mark only the validation checks that apply to the selected image, documenting the alternative used.



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

Reproduce the runtime checks with `./scripts/test-docker-deployment.ps1 -Image IMAGE_REFERENCE` on a Linux Docker host with PowerShell 7. See the README for registry authentication.
