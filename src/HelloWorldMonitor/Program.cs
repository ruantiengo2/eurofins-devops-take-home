using HelloWorldMonitor;

var builder = Host.CreateApplicationBuilder(new HostApplicationBuilderSettings
{
    Args = args,
    ContentRootPath = AppContext.BaseDirectory
});

var url = builder.Configuration["Monitor:Url"];
if (!Uri.TryCreate(url, UriKind.Absolute, out var endpoint) ||
    (endpoint.Scheme != Uri.UriSchemeHttp && endpoint.Scheme != Uri.UriSchemeHttps))
{
    throw new InvalidOperationException("Monitor:Url must be an absolute HTTP or HTTPS URL.");
}

builder.Services.AddSingleton(endpoint);
builder.Services.AddSingleton(_ => new HttpClient(new HttpClientHandler
{
    AllowAutoRedirect = false
})
{
    Timeout = TimeSpan.FromSeconds(10)
});
builder.Services.AddWindowsService(options => options.ServiceName = "HelloWorldMonitor");
builder.Services.AddHostedService<Worker>();

await builder.Build().RunAsync();
