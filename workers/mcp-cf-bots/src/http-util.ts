export function withHeaders(response: Response, extra?: Record<string, string>): Response {
  const headers = new Headers(response.headers);
  headers.set("X-Content-Type-Options", "nosniff");
  headers.set("Cache-Control", "no-store");
  if (extra) {
    for (const [k, v] of Object.entries(extra)) {
      headers.set(k, v);
    }
  }
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

export function jsonResponse(
  data: unknown,
  status = 200,
  extraHeaders?: Record<string, string>,
): Response {
  return withHeaders(
    Response.json(data, { status }),
    extraHeaders,
  );
}

export function apiError(
  status: number,
  message: string,
  code?: string,
): Response {
  return jsonResponse(
    { error: message, code: code ?? httpCodeToApiCode(status) },
    status,
  );
}

function httpCodeToApiCode(status: number): string {
  if (status === 401) return "unauthorized";
  if (status === 403) return "forbidden";
  if (status === 404) return "not_found";
  if (status === 413) return "payload_too_large";
  if (status >= 500) return "internal_error";
  return "bad_request";
}

/** Constant-time string compare (mitigate timing leaks on bearer). */
export function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}
