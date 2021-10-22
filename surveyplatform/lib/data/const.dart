final bool dev = true; // use env

final String serverScheme = dev ? "http" : "http";
final int? serverPort = dev ? 8000 : null;
final String serverUrl = dev ? "localhost" : r"surveyplatform.net";
final String basePath = "/api/v1";
