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

- [ ] Verify that Step 1 deliverables remain available, including the application source, CI pipeline and downloadable application package.
- [ ] Execute the deployment script successfully against a Docker Engine and record the image reference and result.

## Supporting validation and documentation

- [ ] For the Step 5 web image, verify that the container stays running and GET `/` returns HTTP 200 with `Hello World!`.
- [ ] For the Step 5 web image, verify that GET `/health` returns HTTP 200 with `Healthy`.
- [ ] If using the alternative `hello-world` image, verify its expected output and successful exit code instead of HTTP endpoints.
- [x] Define and test what happens when the named container already exists; avoid modifying unrelated containers.
- [x] Fail clearly when pulling the image, creating the container or starting the application fails.
- [x] Document prerequisites, parameters, registry access, deployment commands, endpoint URLs and container cleanup.
- [ ] Record validation evidence, including host/engine, script command without secrets, image tag or digest and observed result.

Step 6 is optional in the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). It asks for a script that deploys the previous step's image to Docker Engine on Windows or Linux, and explicitly permits Docker's official `hello-world` image when the application image has not been published. The assignment's stated completion criterion preserves Step 1 deliverables; the deployment and supporting checks above make the script's behavior verifiable.

The alternative `hello-world` image prints a message and exits successfully. It is not the ASP.NET application and does not expose HTTP endpoints. Mark only the validation checks that apply to the selected image, documenting the alternative used.

The deployment and prerequisite sections are implemented in `scripts/deploy-docker.ps1`. Checked implementation items do not imply that an actual Docker deployment has been validated. Step 5 publication is currently unverified because GitHub Actions is blocked by an account billing issue; see the [Step 5 checklist](step5.md).

## Implementation validation

PowerShell syntax was checked locally. With Docker absent, the real script reported the expected prerequisite error. Nine tests using a simulated Docker CLI passed: web startup, official example completion, digest plus custom port, existing-name rejection, Windows-engine rejection, pull failure, run failure, engine-access failure and early container exit. Existing-name and prerequisite failures issued no container run command.

These checks validate script control flow and arguments only. No real image was pulled or executed, no endpoint was tested and no successful CI package was verified in this step. Real-engine completion criteria and runtime evidence remain unchecked.
