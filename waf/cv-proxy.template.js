export default {
  async fetch(request, env, ctx) {
    const GCP_FUNCTION_URL = "{{SERVERLESS_URL}}";
    const SECRET_TOKEN = "{{SECRET_TOKEN}}";

    const url = new URL(request.url);
    const searchParams = url.search;

    const newRequest = new Request(GCP_FUNCTION_URL + searchParams, {
      method: request.method,
      headers: {
        ...request.headers,
        "x-cf-secret-token": SECRET_TOKEN,
      },
    });

    return await fetch(newRequest);
  },
};
