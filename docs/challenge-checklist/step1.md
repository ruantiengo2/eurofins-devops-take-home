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
- [ ] Verify that the pipeline runs successfully from start to finish.

## Quality and validation

- [x] Run automated tests in the CI pipeline before publishing.
- [x] Ensure the pipeline fails when any test fails.
- [ ] Document how to run, test, and build the application locally.
- [ ] Document the API endpoints and how to download the generated package.
- [ ] Verify that the generated ZIP contains the files required for deployment.
