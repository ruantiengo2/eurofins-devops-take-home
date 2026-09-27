namespace HelloWorldMonitor;

public class Worker(HttpClient client, Uri endpoint, ILogger<Worker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(60));

        try
        {
            // Check immediately, then every 60 seconds.
            do
            {
                await CheckWebsiteAsync(stoppingToken);
            }
            while (await timer.WaitForNextTickAsync(stoppingToken));
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            // Normal shutdown from the console or Windows Service Manager.
        }
    }

    private async Task CheckWebsiteAsync(CancellationToken cancellationToken)
    {
        try
        {
            using var response = await client.GetAsync(endpoint, cancellationToken);
            logger.LogInformation("{Url}: HTTP {StatusCode} {Message}",
                endpoint, (int)response.StatusCode, response.ReasonPhrase);
        }
        catch (HttpRequestException exception)
        {
            logger.LogError(exception, "Could not reach {Url}", endpoint);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            logger.LogError("Request to {Url} timed out", endpoint);
        }
    }
}
