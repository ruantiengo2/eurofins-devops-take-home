# Eurofins DevOps Take-Home

Simple Hello World API built with .NET 10.

## Run locally

Install the .NET 10 SDK, then run these commands from the repository root:

```bash
dotnet restore
dotnet run --project src/HelloWorldApi --launch-profile http
```

The API runs at `http://localhost:5184`. Press `Ctrl+C` to stop it.

## Build and test

```bash
dotnet build --configuration Release
dotnet test --configuration Release
```

Tests start the API in memory, so you don't need to run it separately.

## Endpoints

| Method | Path | Response |
| --- | --- | --- |
| GET | `/` | `200 OK` — `Hello World!` |
| GET | `/health` | `200 OK` — `Healthy` |

## Download the package

Open the repository's **Actions** tab, select a successful **CI** run, and download **HelloWorldApi** from **Artifacts**. You need to be signed in to GitHub.

The ZIP contains the published API and its dependencies. The target server needs the ASP.NET Core 10 runtime.

## Website monitor

`HelloWorldMonitor` checks the website immediately, then every 60 seconds. The default URL is `http://localhost:8080/api/`, set in `src/HelloWorldMonitor/appsettings.json` under `Monitor:Url`.

For local testing, start the API using the command above, then open another terminal:

```bash
dotnet run --project src/HelloWorldMonitor -- --Monitor:Url http://localhost:5184/
```

In the IDE, select `HelloWorldMonitor` as the startup project and set `Monitor:Url` to the URL you want to check before running or debugging it.

Results are appended to `status.log` beside the monitor executable, with a timestamp, URL, HTTP code and message. For a default local build, the file is in `src/HelloWorldMonitor/bin/Debug/net10.0/`. The service account must have write permission in that directory.

To check the behavior:

- Leave the API running for over a minute: two `HTTP 200 OK` entries should appear and the monitor should stay running.
- Run the monitor with `http://localhost:5184/does-not-exist`: it should log `404` and exit with code 1.
- Stop the API and run the monitor again: it should log a connection error and exit with code 1.
- Requests taking longer than 10 seconds are logged as timeouts and also stop the monitor.

Redirects are not followed: only HTTP 200 keeps the monitor running. For the IIS HTTPS endpoint, use `https://localhost:8443/api/` with a certificate trusted by the machine running the monitor.

Console behavior and execution as an installed Windows service have been checked locally. IDE debugging remains pending; see Step 4 below for installation scope and validation.

## Install the monitor as a Windows service (Step 4)

Publish with the .NET 10 SDK from the repository root:

```powershell
.\scripts\publish-monitor.ps1
```

This produces a framework-dependent Windows x64 executable at `artifacts/HelloWorldMonitor/win-x64/HelloWorldMonitor.exe`. Keep the whole published directory; the target needs the .NET 10 x64 runtime. Use `-OutputDir` to choose another publish directory.

Then open **64-bit Windows PowerShell 5.1 as Administrator** and run:

```powershell
$credential = Get-Credential -UserName "$env:COMPUTERNAME\HelloWorldUser" -Message 'Existing account for the monitor service'
.\scripts\deploy-monitor.ps1 -MonitorUrl 'https://localhost:8443/api/' -Credential $credential
```

The URL must return HTTP 200 directly. The monitor does not follow redirects, so the IIS HTTP URL that returns 307 is unsuitable. For HTTPS, configure a certificate trusted by the service account before starting the service; the development self-signed certificate is not trusted automatically. The script does not bypass TLS validation.

The deployment copies the publish directory to `C:\Program Files\HelloWorldMonitor`, registers `HelloWorldMonitor` pointing directly to the quoted `.exe` path, sets Automatic startup and starts it. `status.log` is written beside the executable. Optional `-PublishDir` and `-DeploymentDir` parameters override the source and destination directories.

Use an existing enabled local or domain account. The mandatory `-Credential` parameter accepts a `PSCredential` from `Get-Credential`; the password is passed directly to Windows service registration and is not written to a file, command-line argument or source control. Windows stores the service credential. Do not put a plaintext password into a script.

The installer grants `SeServiceLogonRight` to that account through the local Windows LSA API without replacing other policy assignments. Keep `scripts/ServiceLogonRight.cs` beside the deployment script. Domain policy or a deny-logon policy can override this grant; resolve those policies if startup reports a logon failure.

The fresh deployment directory gives Administrators and SYSTEM full control and the service account inherited read/execute access. The installer pre-creates `status.log` and grants the account Modify on that file only, so logging does not require write access to the application binaries. It also registers the monitor's Windows Event Log source while elevated.

The installer configures the first, second and subsequent failures to restart the service after **300 seconds** (300000 milliseconds), with the failure count reset after 24 hours without failures. The monitor finishes writing the failure to `status.log` before exiting with code 1. When hosted as a Windows service it terminates the process so the Service Control Manager recognizes the failure and performs recovery; console execution still uses normal host shutdown with exit code 1. An intentional `Stop-Service` uses normal cancellation, not this failure-exit path.

An existing service or nonempty destination is rejected without overwriting it; in-place updates are not implemented. If startup fails, the installed service, recovery configuration and assigned rights are retained for diagnosis; inspect `status.log`, the target URL/certificate and account credentials. Disable the service while diagnosing if automatic retries are unwanted. Removing the service does not automatically revoke account rights; review them when decommissioning a dedicated account.

```powershell
Get-Service HelloWorldMonitor
Get-CimInstance Win32_Service -Filter "Name='HelloWorldMonitor'" |
    Select-Object Name, State, StartMode, PathName, StartName
Get-Content 'C:\Program Files\HelloWorldMonitor\status.log' -Tail 10
sc.exe qfailure HelloWorldMonitor
sc.exe qfailureflag HelloWorldMonitor
```

For an end-to-end recovery check, first observe two healthy IIS log entries 60 seconds apart. Make the monitored endpoint return a non-200 response, confirm the result is logged and the monitor stops, then restore the endpoint. Do not manually start the monitor: Windows should restart it after 300 seconds and a new HTTP 200 entry should appear. Service-hosted failure handling follows [Microsoft's Windows service recovery guidance](https://learn.microsoft.com/en-us/dotnet/core/extensions/windows-service#service-recovery-options-and-net-backgroundservice-instances).

Implementation and validation status: [Step 4 checklist](docs/requirements-criteria/step4.md).

## Docker image (Step 5)

The pipeline targets the Linux amd64 image at `ghcr.io/ruantiengo2/eurofins-devops-take-home`. Each successful main CI publication pushes `sha-<full-commit-SHA>` and updates `latest`. Use the commit tag or the digest recorded in the CI image job summary for reproducible deployment; `latest` moves. Pull requests build and test the image without publishing.

The multi-stage Dockerfile publishes the API with the .NET 10 SDK and ships the ASP.NET Core 10 runtime. It runs as the image's non-root app user and listens on **HTTP port 8080**. Its routes are `/` and `/health`; the IIS `/api` prefix does not apply. TLS should be terminated by the hosting platform or reverse proxy.

Install Docker Engine, or Docker Desktop using **Linux containers** on Windows. From the repository root:

```sh
docker build --pull -t helloworld-api:local .
docker run --rm --name helloworld-api -p 8080:8080 helloworld-api:local
```

In another terminal, check `http://localhost:8080/` (HTTP 200, `Hello World!`) and `http://localhost:8080/health` (HTTP 200, `Healthy`). Choose another host port, such as `-p 18080:8080`, if IIS already uses 8080.

To run a published version, replace the example tag with a full commit SHA from a successful CI run:

```sh
docker pull ghcr.io/ruantiengo2/eurofins-devops-take-home:sha-<full-commit-SHA>
docker run --rm -p 18080:8080 ghcr.io/ruantiengo2/eurofins-devops-take-home:sha-<full-commit-SHA>
```

GHCR packages are private by default. Private pulls require an account with package read access and a personal access token (classic) with `read:packages`; use `docker login ghcr.io -u YOUR_GITHUB_USERNAME` and enter the token at the password prompt. Never put tokens in files or commit them. Public packages allow anonymous pulls. The owner can manage visibility and access in the GitHub package settings.

CI authenticates with the short-lived `GITHUB_TOKEN` and job-scoped `packages: write`; no personal token or registry password is stored in source control. The package is associated with this repository through its OCI source label. Repository or organization policy must allow package creation and workflow writes; an existing package must grant this repository Actions access.

CI retains the solution build, integration tests and downloadable `HelloWorldApi` package. The image job waits for those checks, builds the image, verifies both endpoint status codes and bodies, publishes both tags, pulls the commit tag and runs the pulled digest through the same checks. Build, push, pull or smoke-test errors fail the workflow. On Linux with Docker and curl, repeat the smoke test with `bash scripts/test-container.sh IMAGE_REFERENCE`.

Validation evidence and completion status: [Step 5 checklist](docs/requirements-criteria/step5.md).

## Deploy to Docker Engine (Step 6)

Run `scripts/deploy-docker.ps1` in Windows PowerShell 5.1 or PowerShell 7 on Windows, or PowerShell 7 on Linux. Install Docker CLI and start a **Linux container engine** accessible to your user. On Windows, Docker Desktop must use Linux containers; a Windows-only container engine cannot run the Step 5 image. The script uses the current Docker context, so confirm its target with `docker context show` before deployment.

For private GHCR images, first run `docker login ghcr.io -u YOUR_GITHUB_USERNAME` and enter a token with `read:packages` and package access at the password prompt. Public pulls need no login. Use Docker's credential store/helper; never put passwords or tokens in the script or repository. The script uses your existing Docker authentication.

From the repository root:

```powershell
# Replace the tag with an image actually published by a successful Step 5 run.
./scripts/deploy-docker.ps1 -Image 'ghcr.io/ruantiengo2/eurofins-devops-take-home:sha-FULL_COMMIT_SHA' -HostPort 18080
# A full repository@sha256:digest reference is also accepted.
# When the application image is unavailable, explicitly use the assignment alternative:
./scripts/deploy-docker.ps1 -UseHelloWorld
```

Parameters: `-Image` defaults to `ghcr.io/ruantiengo2/eurofins-devops-take-home:latest`; `-ContainerName` defaults to `helloworld-api`; `-HostPort` defaults to 18080 and maps to container port 8080. `-UseHelloWorld` selects `hello-world:latest` and defaults the name to `helloworld-example`; it cannot be combined with `-Image`. Official `hello-world` references supplied through `-Image` are also recognized.

The script checks engine access and Linux mode, rejects an existing container name, pulls the image, then creates and starts the container. It does not silently fall back after a failed application pull. The web container stays detached; the script checks its running state after two seconds. Port publication uses all host interfaces; host firewall/network policy controls external access. On the Docker host, validate `http://localhost:18080/` and `http://localhost:18080/health` (adjust for `-HostPort`). Running state alone does not verify HTTP readiness.

The official example has no web server: no port is published, and the script waits up to 30 seconds for exit code 0 and checks for `Hello from Docker!` in its logs. The stopped example container is retained.

An existing name is rejected without replacement. Choose another name or inspect and explicitly remove the old container. Failures return a script error; any created container is kept for diagnosis. No unrelated containers are removed:

```powershell
docker logs helloworld-api
docker stop helloworld-api
docker rm helloworld-api
# Remove the completed alternative example:
docker rm helloworld-example
```

Implementation and validation status: [Step 6 checklist](docs/requirements-criteria/step6.md).

## IIS deployment (Step 2)

Use 64-bit Windows PowerShell 5.1 as Administrator on Windows with IIS, its WebAdministration management module, and the .NET 10 Hosting Bundle installed. If IIS was installed after the Hosting Bundle, repair the bundle to register AspNetCoreModuleV2. Create or select an enabled local account before deployment.

Download the HelloWorldApi ZIP from a successful CI run and save it as `artifacts/HelloWorldApi.zip` in the repository. The ZIP must contain the published files at its root. Run:

```powershell
./scripts/deployment-script.ps1
```

The entry script has no command-line parameters. Its configuration variables select `HelloWorldUser`, `HelloWorldApiUsers` and `C:\inetpub\HelloWorldApi`; it prompts for the account password as a SecureString. The called `configure-iis.ps1` accepts `-DeploymentDir` and `-Credential` and configures site `HelloWorldApi`, pool `HelloWorldApiPool`, application `/api`, HTTP 8080, HTTPS 8443 and logs under `C:\inetpub\logs\HelloWorldApi`.

Use `http://localhost:8080/api/` in a browser; it redirects to `https://localhost:8443/api/`. The corresponding health endpoint is `/api/health`. The generated localhost certificate requires explicit trust for clients; the deployment does not establish trust. For monitoring, use the HTTPS URL with certificate trust for the service account, because the monitor does not follow HTTP redirects.

Redeployment stops an existing running pool and waits up to 60 seconds for files to be released before extraction. It restores an originally running pool in `finally`; an already stopped pool stays stopped. This incurs brief downtime and does not provide rollback or concurrent deployment locking. The correction from the original PR #1 is included in this repository.