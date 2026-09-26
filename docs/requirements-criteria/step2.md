# Step 2 - IIS Deployment Checklist

## Deployment script

- [ ] Create a PowerShell script to deploy the application from Step 1.
- [ ] Accept parameters for the package path, site, application, application pool, user, group, log directory, and certificate.
- [ ] Check that IIS and the ASP.NET Core Hosting Bundle are installed.
- [ ] Extract the application package to the deployment directory.

## User and permissions

- [ ] Create a local group.
- [ ] Add the specified user to the local group.
- [ ] Grant the permissions needed to access the application files.
- [ ] Handle the user's password without storing it in source control.

## IIS configuration

- [ ] Create an IIS website.
- [ ] Add an HTTPS binding with a certificate.
- [ ] Create an application pool and configure it to run as the specified user.
- [ ] Set a custom directory for the website logs.
- [ ] Create an application under the website.
- [ ] Assign the application to the created application pool.

## Quality and validation

- [ ] Ensure the script can be run again without duplicating existing resources.
- [ ] Verify that Hello World is reachable through a localhost HTTP URL.
- [ ] Verify that the HTTPS binding works.
- [ ] Verify that the application's health endpoint returns 200 OK.
- [ ] Verify that website logs are written to the configured directory.
- [ ] Document the prerequisites, script parameters, and deployment command.
