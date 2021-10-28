final bool dev = false; // use env

final String serverScheme = dev ? "http" : "https";
final int? serverPort = dev ? 8000 : null;
final String serverUrl = dev ? "localhost" : r"surveyplatform.net";
final String basePath = "/api/v1";
final String fullServerUrl =
    "$serverScheme://$serverUrl:${serverPort ?? ''}$basePath";
