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

- [x] Ensure the script can be run again without duplicating existing resources.
- [x] Verify that Hello World is reachable through a localhost HTTP URL.
- [x] Verify that the HTTPS binding works.
- [x] Verify that the application's health endpoint returns 200 OK.
- [x] Verify that website logs are written to the configured directory.
- [x] Document the prerequisites, script parameters, and deployment command.

## Windows validation

Rechecked the installed IIS application on 2026-09-29. HTTPS `/api/` returned HTTP 200 with `Hello World!`, and `/api/health` returned HTTP 200 with `Healthy`, using the specific localhost certificate as the client's trust anchor. HTTP returns 307 to HTTPS; following that redirect reaches the same HTTP 200 responses. Six fresh request entries with a unique marker were found in the configured custom IIS log directory after flushing HTTP logs.

The site, pool, specified account, group membership, inherited read/execute permissions, sub-application mapping and certificate binding passed the elevated audit. Setup and parameters are documented in the README.

The IIS file-lock correction from the original PR #1 is now included in main (commit `0771151`). Its script content was compared with the corrected script previously validated on this Windows machine and matched. Those two successful redeployments preserved the resource snapshots and restored endpoint access. The current audit reconfirmed endpoints, permissions, pool identity and fresh logs. The full redeployment was not repeated during this audit; this check relies on the earlier execution of the identical corrected script.

Redeployment stops a running pool, waits for file release and restores it in finally, causing brief downtime. It does not implement rollback or concurrent deployment locking.
