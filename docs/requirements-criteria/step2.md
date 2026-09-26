# Step 2 - IIS Deployment Checklist

## Deployment script

- [x] Create a PowerShell script to deploy the application from Step 1.
- [x] Check that IIS and the ASP.NET Core Hosting Bundle are installed.
- [x] Extract the application package to the deployment directory.

## User and permissions

- [x] Create a local group.
- [x] Add the specified user to the local group.
- [x] Grant the permissions needed to access the application files.
- [x] Handle the user's password without storing it in source control.

## IIS configuration

- [x] Create an IIS website.
- [x] Add an HTTPS binding with a certificate.
- [x] Create an application pool and configure it to run as the specified user.
- [x] Set a custom directory for the website logs.
- [x] Create an application under the website.
- [x] Assign the application to the created application pool.

## Quality and validation

- [ ] Ensure the script can be run again without duplicating existing resources.
- [ ] Verify that Hello World is reachable through a localhost HTTP URL.
- [ ] Verify that the HTTPS binding works.
- [ ] Verify that the application's health endpoint returns 200 OK.
- [ ] Verify that website logs are written to the configured directory.
- [ ] Document the prerequisites, script parameters, and deployment command.
