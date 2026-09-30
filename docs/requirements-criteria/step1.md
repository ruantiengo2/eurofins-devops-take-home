# Step 1 - Build Checklist

## Application

- [x] Create a simple .NET Core web application.
- [x] Ensure the application builds successfully.
- [x] Ensure the application runs successfully.
- [x] Store the application source code in Git.
- [x] Create health and hello world routes.
- [x] Create integration tests for the routes.
- [x] Push the repository to a remote version control platform.

## CI/CD

- [x] Create a CI pipeline using GitHub Actions.
- [x] Configure the pipeline to trigger automatically on repository changes.
- [x] Configure the pipeline to run on every push to the target branch.
- [x] Restore application dependencies.
- [x] Build the application.
- [x] Generate the application package.
- [x] Store the generated package as a pipeline artifact.
- [x] Ensure the package is rebuilt on every committed change.
- [x] Ensure the pipeline fails when the build fails.
- [x] Verify that the pipeline runs successfully from start to finish.

## Quality and validation

- [x] Run automated tests in the CI pipeline before publishing.
- [x] Ensure the pipeline fails when any test fails.
- [x] Document how to run, test, and build the application locally.
- [x] Document the API endpoints and how to download the generated package.
- [x] Verify that the generated ZIP contains the files required for deployment.


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
