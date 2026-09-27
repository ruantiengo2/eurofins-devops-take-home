# Step 3 - Log Status Checklist

## Windows service

- [x] Create an application that can run as a Windows service.
- [x] Support running the application from the IDE for local validation.
- [x] Check the HelloWorld application hosted in IIS every 60 seconds.

## Status logging

- [x] Write the HTTP status code and message from each check to a log file.
- [x] Store the log file in the same directory as the executable.
- [x] Append new results without overwriting previous entries.
- [x] Include the date and time of each check.

## Stop behavior

- [ ] Stop the monitoring service when the HTTP status code is different from 200 OK.
- [ ] Write the non-200 result to the log before stopping.
- [ ] Log connection errors or timeouts and stop the monitoring service when no HTTP response is received.

## Quality and validation

- [ ] Verify from the IDE that HTTP 200 results are logged every 60 seconds.
- [ ] Verify from the IDE that a non-200 response is logged and stops the monitoring service.
- [ ] Verify that connection errors or timeouts are logged and stop the monitoring service.
- [x] Verify that the log is created beside the executable, regardless of the working directory.
- [ ] Document the monitored URL, log location, and how to run the application locally.
