# Step 6 - Docker Deployment Checklist (Optional)

## Deployment script

- [ ] Create a script to deploy the HelloWorld Docker image from Step 5 to Docker Engine on a Windows or Linux server.
- [ ] Accept the image reference as a parameter, including a tag or digest.
- [ ] Pull the selected image and create/start its container.
- [ ] Publish the application's container port 8080 on a documented, configurable host port.

## Prerequisites and registry access

- [ ] Check that Docker is installed, its engine is running and the executing user can access it.
- [ ] Document the supported host and shell; the Step 5 Linux image requires a Linux container engine, including when hosted on Windows.
- [ ] Document authentication for private GHCR images without storing credentials in source control.
- [ ] Support the assignment's alternative `hello-world` image when the Step 5 image is unavailable.

## Completion criteria

- [ ] Verify that Step 1 deliverables remain available, including the application source, CI pipeline and downloadable application package.
- [ ] Execute the deployment script successfully against a Docker Engine and record the image reference and result.

## Supporting validation and documentation

- [ ] For the Step 5 web image, verify that the container stays running and GET `/` returns HTTP 200 with `Hello World!`.
- [ ] For the Step 5 web image, verify that GET `/health` returns HTTP 200 with `Healthy`.
- [ ] If using the alternative `hello-world` image, verify its expected output and successful exit code instead of HTTP endpoints.
- [ ] Define and test what happens when the named container already exists; avoid modifying unrelated containers.
- [ ] Fail clearly when pulling the image, creating the container or starting the application fails.
- [ ] Document prerequisites, parameters, registry access, deployment commands, endpoint URLs and container cleanup.
- [ ] Record validation evidence, including host/engine, script command without secrets, image tag or digest and observed result.

Step 6 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). It asks for a script that deploys the previous step's image to Docker Engine on Windows or Linux, and explicitly permits Docker's official `hello-world` image when the application image has not been published. The assignment's stated completion criterion preserves Step 1 deliverables; the deployment and supporting checks above make the script's behavior verifiable.

The alternative `hello-world` image prints a message and exits successfully. It is not the ASP.NET application and does not expose HTTP endpoints. Mark only the validation checks that apply to the selected image, documenting the alternative used.

All items remain pending. This document defines the checklist only; it does not implement or validate Docker deployment. Step 5 publication is currently unverified because GitHub Actions is blocked by an account billing issue; see the [Step 5 checklist](step5.md).
