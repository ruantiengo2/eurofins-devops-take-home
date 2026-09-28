# Step 4 - Windows Service Deployment Checklist

## Deployment script

- [x] Create a PowerShell script to deploy the monitor from Step 3 as a Windows service.
- [x] Publish the monitor for Windows and validate the path to its `.exe` file.
- [x] Create the Windows service and point it to the published executable.
- [x] Set the service startup type to Automatic.
- [x] Start the installed service.

## Service account and permissions

- [x] Configure the service to run as a specified user.
- [x] Supply the account password securely without storing it in source control.
- [x] Ensure the account can log on as a service, execute the monitor and write its log beside the executable.

## Error recovery

- [ ] Configure service recovery to restart the service after 300 seconds following a failure, including subsequent failures.
- [ ] Ensure the monitor's failure exit is recognized by Windows service recovery.

## Completion criteria

- [x] Verify that the installed service starts successfully under the specified user.
- [ ] Verify that the service logs the HelloWorld website HTTP status every 60 seconds.
- [ ] Verify that an HTTP response other than 200 is logged and stops the service.
- [ ] Verify that Windows restarts the failed service after 300 seconds.

## Supporting validation and documentation

- [ ] Configure a monitored URL that returns HTTP 200 when the IIS application is healthy; account for HTTP-to-HTTPS redirects and certificate trust for the service account.
- [ ] Verify that rerunning the deployment script updates the existing service without creating duplicates.
- [ ] Document prerequisites, script parameters, account permissions, deployment commands and recovery settings.
- [ ] Record evidence of service identity, Automatic startup, recovery configuration, periodic logs, failure and restart timing.

The deployment, account, startup and 300-second recovery requirements come from Step 4 of the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Secure credential handling, repeatable deployment and the documentation checks support those requirements.

Deployment and service-account setup are implemented by scripts/publish-monitor.ps1, scripts/deploy-monitor.ps1 and scripts/ServiceLogonRight.cs. Recovery actions and the unchecked validation items remain pending.

## Deployment validation

Validated on Windows 11 with Windows PowerShell 5.1, SDK 10.0.401 and runtime 10.0.12:

- Published the monitor for win-x64 with a framework-dependent Windows apphost.
- Installed a real Windows service with Automatic startup and verified its Running state.
- Confirmed both the registered binary path and running process point to HelloWorldMonitor.exe, including a deployment path containing spaces.
- Confirmed an HTTP 200 entry in status.log using a controlled local HTTP endpoint.
- Confirmed an incomplete publish is rejected before creating a service or deployment directory.
- Confirmed an existing service is rejected without replacing it or restarting its process.
- Removed the temporary test service after validation.

The initial deployment test used LocalSystem. The additional account validation below covers deployment under a specified user. The current IIS URL/certificate configuration and 300-second recovery remain pending. See the README for installation prerequisites and parameters.
## Service-account validation

A fresh Windows deployment was tested with a temporary, non-administrator local account and a random password held only in memory:

- The installed service identity and the actual worker process owner matched the supplied account.
- The service started with Automatic startup and logged HTTP 200 beside its executable.
- Local policy contained SeServiceLogonRight for the account; granting it again succeeded.
- The executable granted the account read/execute without write access; status.log granted Modify.
- The same unprivileged service appended an HTTP 503 result and stopped, exercising error logging.
- All 11 checks passed; the temporary service, account and test logon-right assignment were removed afterward.

The deployment passes PSCredential directly to New-Service without converting its password to plaintext in script code. The caller should use Get-Credential as documented; no credential files or password arguments are required.