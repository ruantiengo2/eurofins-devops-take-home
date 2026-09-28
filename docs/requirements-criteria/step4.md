# Step 4 - Windows Service Deployment Checklist

## Deployment script

- [x] Create a PowerShell script to deploy the monitor from Step 3 as a Windows service.
- [x] Publish the monitor for Windows and validate the path to its `.exe` file.
- [x] Create the Windows service and point it to the published executable.
- [x] Set the service startup type to Automatic.
- [x] Start the installed service.

## Service account and permissions

- [ ] Configure the service to run as a specified user.
- [ ] Supply the account password securely without storing it in source control.
- [ ] Ensure the account can log on as a service, execute the monitor and write its log beside the executable.

## Error recovery

- [ ] Configure service recovery to restart the service after 300 seconds following a failure, including subsequent failures.
- [ ] Ensure the monitor's failure exit is recognized by Windows service recovery.

## Completion criteria

- [ ] Verify that the installed service starts successfully under the specified user.
- [ ] Verify that the service logs the HelloWorld website HTTP status every 60 seconds.
- [ ] Verify that an HTTP response other than 200 is logged and stops the service.
- [ ] Verify that Windows restarts the failed service after 300 seconds.

## Supporting validation and documentation

- [ ] Configure a monitored URL that returns HTTP 200 when the IIS application is healthy; account for HTTP-to-HTTPS redirects and certificate trust for the service account.
- [ ] Verify that rerunning the deployment script updates the existing service without creating duplicates.
- [ ] Document prerequisites, script parameters, account permissions, deployment commands and recovery settings.
- [ ] Record evidence of service identity, Automatic startup, recovery configuration, periodic logs, failure and restart timing.

The deployment, account, startup and 300-second recovery requirements come from Step 4 of the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Secure credential handling, repeatable deployment and the documentation checks support those requirements.

The five deployment-script items are implemented by scripts/publish-monitor.ps1 and scripts/deploy-monitor.ps1. The remaining items are pending. This initial installer uses LocalSystem and does not configure a specified user or recovery actions.

## Deployment validation

Validated on Windows 11 with Windows PowerShell 5.1, SDK 10.0.401 and runtime 10.0.12:

- Published the monitor for win-x64 with a framework-dependent Windows apphost.
- Installed a real Windows service with Automatic startup and verified its Running state.
- Confirmed both the registered binary path and running process point to HelloWorldMonitor.exe, including a deployment path containing spaces.
- Confirmed an HTTP 200 entry in status.log using a controlled local HTTP endpoint.
- Confirmed an incomplete publish is rejected before creating a service or deployment directory.
- Confirmed an existing service is rejected without replacing it or restarting its process.
- Removed the temporary test service after validation.

This test does not claim that the current IIS URL/certificate configuration, a specified service account or 300-second recovery is ready. See the README for installation prerequisites and parameters.