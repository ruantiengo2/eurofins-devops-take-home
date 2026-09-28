# Step 4 - Windows Service Deployment Checklist

## Deployment script

- [ ] Create a PowerShell script to deploy the monitor from Step 3 as a Windows service.
- [ ] Publish the monitor for Windows and validate the path to its `.exe` file.
- [ ] Create the Windows service and point it to the published executable.
- [ ] Set the service startup type to Automatic.
- [ ] Start the installed service.

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

All items remain pending for Step 4. The temporary Windows service used to validate Step 3 ran with manual startup under LocalSystem and was removed after testing; it does not validate deployment under a specified user, Automatic startup or recovery after 300 seconds.
