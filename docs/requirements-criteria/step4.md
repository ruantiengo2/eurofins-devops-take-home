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

- [x] Configure service recovery to restart the service after 300 seconds following a failure, including subsequent failures.
- [x] Ensure the monitor's failure exit is recognized by Windows service recovery.

## Completion criteria

- [x] Verify that the installed service starts successfully under the specified user.
- [x] Verify that the service logs the HelloWorld website HTTP status every 60 seconds.
- [x] Verify that an HTTP response other than 200 is logged and stops the service.
- [x] Verify that Windows restarts the failed service after 300 seconds.

## Supporting validation and documentation

- [x] Configure a monitored URL that returns HTTP 200 when the IIS application is healthy; account for HTTP-to-HTTPS redirects and certificate trust for the service account.
- [ ] Verify that rerunning the deployment script updates the existing service without creating duplicates.
- [x] Document prerequisites, script parameters, account permissions, deployment commands and recovery settings.
- [x] Record evidence of service identity, Automatic startup, recovery configuration, periodic logs, failure and restart timing.

The deployment, account, startup and 300-second recovery requirements come from Step 4 of the [assignment](<../DevOpsEngenieerTakeHome - Ram. Team 1 (1).pdf>). Secure credential handling, repeatable deployment and the documentation checks support those requirements.

Deployment and service-account setup are implemented by scripts/publish-monitor.ps1, scripts/deploy-monitor.ps1 and scripts/ServiceLogonRight.cs. Recovery actions and all completion criteria have been validated. Only the unchecked supporting items remain pending.

## Deployment validation

Validated on Windows 11 with Windows PowerShell 5.1, SDK 10.0.401 and runtime 10.0.12:

- Published the monitor for win-x64 with a framework-dependent Windows apphost.
- Installed a real Windows service with Automatic startup and verified its Running state.
- Confirmed both the registered binary path and running process point to HelloWorldMonitor.exe, including a deployment path containing spaces.
- Confirmed an HTTP 200 entry in status.log using a controlled local HTTP endpoint.
- Confirmed an incomplete publish is rejected before creating a service or deployment directory.
- Confirmed an existing service is rejected without replacing it or restarting its process.
- Removed the temporary test service after validation.

The initial deployment test used LocalSystem. The additional account validation below covers deployment under a specified user. The later recovery test below covers the real IIS HTTPS endpoint and the 300-second restart, with temporary certificate trust during validation. See the README for installation prerequisites and parameters.
## Service-account validation

A fresh Windows deployment was tested with a temporary, non-administrator local account and a random password held only in memory:

- The installed service identity and the actual worker process owner matched the supplied account.
- The service started with Automatic startup and logged HTTP 200 beside its executable.
- Local policy contained SeServiceLogonRight for the account; granting it again succeeded.
- The executable granted the account read/execute without write access; status.log granted Modify.
- The same unprivileged service appended an HTTP 503 result and stopped, exercising error logging.
- All 11 checks passed; the temporary service, account and test logon-right assignment were removed afterward.

The deployment passes PSCredential directly to New-Service without converting its password to plaintext in script code. The caller should use Get-Credential as documented; no credential files or password arguments are required.
## Recovery validation against IIS

Validated with the published Windows executable under a temporary non-administrator account against the actual HelloWorld IIS application over HTTPS:

- Two HTTP 200 entries were logged 59.56 seconds apart.
- Stopping only HelloWorldApiPool produced an HTTP 503, which was logged before the monitor process exited with code 1.
- The IIS pool was restored immediately after the monitor stopped. No manual monitor start was issued during recovery.
- Windows Service Control Manager event 7031 reported an unexpected termination and a restart action after 300000 milliseconds.
- The next HTTP 200 was logged 300.24 seconds after the failure. Polling observed the new Running process after 301.05 seconds; its owner was the same specified user.
- `sc.exe qfailure` confirmed restart actions with 300000-ms delays for first, second and subsequent failures; `qfailureflag` confirmed non-crash failure recovery enabled. One full 300-second recovery cycle was timed; later failures use the configured repeated action.
- Console regression still logged HTTP 503 and exited with code 1. Both existing API integration tests passed.

The test temporarily trusted the IIS localhost certificate in the machine certificate store so the service account could validate TLS. The temporary trust, service, account and account logon right were removed afterward, and the IIS application pool was left running. Persistent endpoint/certificate provisioning remains an operational prerequisite.
## Checklist review

The monitored URL requirement was exercised by the recorded real service recovery test: `https://localhost:8443/api/` returned 200 and the machine trusted the exact localhost certificate during the test, making trust available to the specified service account. Temporary trust was removed during cleanup; a persistent installation must provision its own certificate trust.

Updating an existing service remains unchecked. The installer explicitly rejects an existing `HelloWorldMonitor` service before modifying it. Earlier Windows tests verified this rejection; it does not implement an in-place update.