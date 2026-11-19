import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Max-Age': '86400',
};

// The production system prompt is kept private.
// In the live app it sets theology rules, an eight-part structure for every du'a,
// and filtering that turns harmful or despairing input into repentance and hope.
const SYSTEM_PROMPT = Deno.env.get('MUNAJAT_SYSTEM_PROMPT') ??
  'You write a sincere, personal du\'a in response to what the user shares.';

interface RequestPayload {
  raw_input: string;
  input_mode: 'type' | 'speak';
  dua_length?: 'concise' | 'balanced' | 'extended';
  include_sayyid_istighfar?: boolean;
  primary_focus?: string;
  client_request_id?: string;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  const requestId = crypto.randomUUID();

  try {
    // Parse request body
    let payload: RequestPayload;
    try {
      payload = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ error: 'invalid_json', request_id: requestId }),
        { status: 400, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    // Validate required fields
    const rawInput = (payload.raw_input || '').trim();
    if (rawInput.length < 10) {
      return new Response(
        JSON.stringify({ error: 'min_length', request_id: requestId }),
        { status: 400, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }
    if (rawInput.length > 2000) {
      return new Response(
        JSON.stringify({ error: 'max_length', request_id: requestId }),
        { status: 400, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    // Authenticate user
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', request_id: requestId }),
        { status: 401, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', request_id: requestId }),
        { status: 401, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    // ── Subscription entitlement check (fail-open) ──
    const ALLOWED_STATUSES = ['active', 'trial', 'trialing'];
    try {
      const serviceClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      );

      const { data: userRow, error: subError } = await serviceClient
        .from('users')
        .select('subscription_status')
        .eq('id', user.id)
        .single();

      const subscriptionStatus: string = userRow?.subscription_status ?? 'unknown';
      console.log('Subscription check:', { userId: user.id, status: subscriptionStatus });

      if (subError) {
        // DB query failed — fail open, log and continue
        console.error('Subscription check DB error (failing open):', subError);
      } else if (!ALLOWED_STATUSES.includes(subscriptionStatus)) {
        // User exists but subscription is not in an allowed state
        return new Response(
          JSON.stringify({
            error: 'subscription_required',
            message: 'An active subscription is required to generate du\'ās.',
            request_id: requestId,
          }),
          { status: 403, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
        );
      }
    } catch (subCheckErr) {
      // Unexpected error in subscription check — fail open
      console.error('Subscription check unexpected error (failing open):', subCheckErr);
    }

    // Extract optional parameters with defaults
    const duaLength = payload.dua_length || 'balanced';
    const includeSayyidIstighfar = payload.include_sayyid_istighfar !== false;
    const primaryFocus = payload.primary_focus || 'everything';
    const finalRequestId = payload.client_request_id || requestId;

    // Build user message with refine settings
    const userMessage = `${rawInput}\n\nRefine settings: length=${duaLength}, include_sayyid_istighfar=${includeSayyidIstighfar}, primary_focus=${primaryFocus}.`;

    // Call OpenAI
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY');
    if (!openaiApiKey) {
      console.error('OPENAI_API_KEY not configured');
      return new Response(
        JSON.stringify({ error: 'server_config_error', request_id: finalRequestId }),
        { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        temperature: 0.7,
        max_tokens: 600,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: userMessage },
        ],
      }),
    });

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text();
      console.error('OpenAI API error:', openaiResponse.status, errorText);
      return new Response(
        JSON.stringify({ error: 'openai_error', request_id: finalRequestId }),
        { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    const openaiData = await openaiResponse.json();
    const generatedText = openaiData.choices?.[0]?.message?.content?.trim() || '';

    if (!generatedText) {
      console.error('OpenAI returned empty content');
      return new Response(
        JSON.stringify({ error: 'empty_generation', request_id: finalRequestId }),
        { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
      );
    }

    // Return success response
    return new Response(
      JSON.stringify({
        english: generatedText,
        request_id: finalRequestId,
      }),
      { status: 200, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ error: 'internal_error', request_id: requestId }),
      { status: 500, headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' } }
    );
  }
});