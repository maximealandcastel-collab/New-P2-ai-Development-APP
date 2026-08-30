// ─────────────────────────────────────────────────────────────
// AI SERVICE
// Core LLM wrapper + trainer system prompts + memory summarizer
// ─────────────────────────────────────────────────────────────

import { BUILT_IN_TRAINER_SYSTEM_PROMPTS } from "../DB/builtInTrainers.data";

interface ICallAIParams {
  systemPrompt: string;
  userMessage: string;
  maxTokens?: number;
  conversationHistory?: Array<{ role: "user" | "assistant"; content: string }>;
  /** Pre-fill assistant with "{" so the model continues valid JSON */
  jsonPrefill?: boolean;
  /** Optional hard upper bound for this provider request. */
  timeoutMs?: number;
}

interface IMemoryUpdateResult {
  profile_updates: {
    limitations?: string | null;
    equipment?: string | null;
    preferences?: string | null;
  };
  session_summary: {
    workoutSummary: string;
    adherence: "completed" | "skipped" | "modified";
    rpe?: number | null;
    painNotes?: string | null;
    loadsUsed?: Record<string, string>;
    energyLevel?: number | null;
  };
  flags: string[];
}

// ─────────────────────────────────────────────────────────────
// CORE AI CALL
// ─────────────────────────────────────────────────────────────

export const WORKOUT_PROVIDER_TIMEOUTS_MS = {
  splits: {
    claude: 25_000,
    openai: 15_000,
  },
  program: {
    claude: 45_000,
    openai: 10_000,
  },
} as const;

export const summarizeAIProviderFailure = (error: unknown): string => {
  const message = error instanceof Error ? error.message : String(error || "unknown");
  const apiStatus = message.match(/^(OpenAI|AI) API error:\s*(\d{3})/i);
  if (apiStatus) return `${apiStatus[1]} API error: ${apiStatus[2]}`;
  if (message.includes("timed out")) return message;
  return message.slice(0, 300);
};

const fetchTextWithTimeout = async (
  input: string,
  init: RequestInit,
  timeoutMs?: number,
): Promise<{ ok: boolean; status: number; body: string }> => {
  const controller = new AbortController();
  const timeout = timeoutMs
    ? setTimeout(() => controller.abort(), timeoutMs)
    : undefined;
  try {
    const response = await fetch(input, { ...init, signal: controller.signal });
    const body = await response.text();
    return { ok: response.ok, status: response.status, body };
  } catch (error) {
    if (controller.signal.aborted) {
      throw new Error(`AI provider timed out after ${timeoutMs}ms`);
    }
    throw error;
  } finally {
    if (timeout) clearTimeout(timeout);
  }
};

export const callAI = async ({
  systemPrompt,
  userMessage,
  maxTokens = 2000,
  conversationHistory = [],
  jsonPrefill = false,
  timeoutMs,
}: ICallAIParams): Promise<string> => {
  const messages: Array<{ role: "user" | "assistant"; content: string }> = [
    ...conversationHistory,
    { role: "user", content: userMessage },
  ];

  if (jsonPrefill) {
    messages.push({ role: "assistant", content: "{" });
  }

  const response = await fetchTextWithTimeout("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": process.env.ANTHROPIC_API_KEY || "",
      "anthropic-version": "2023-06-01",
    },

    body: JSON.stringify({
      model: process.env.ANTHROPIC_MODEL || "claude-sonnet-4-6",
      max_tokens: maxTokens,
      system: systemPrompt,
      messages,
    }),
  }, timeoutMs);

  if (!response.ok) {
    throw new Error(`AI API error: ${response.status} — ${response.body}`);
  }

  const data = JSON.parse(response.body);
  const text = ((data.content?.[0]?.text as string) || "").trim();

  if (!text) {
    const stopReason = data.stop_reason as string | undefined;
    throw new Error(
      stopReason === "max_tokens"
        ? "AI response was truncated (max tokens). Try again."
        : "AI returned empty response",
    );
  }

  if (!jsonPrefill) return text;

  // Prefill sends assistant "{" — model may or may not repeat the brace
  return text.startsWith("{") ? text : `{${text}`;
};

/**
 * Generate workout plans through the user's explicitly configured OpenAI key.
 * This stays separate from callAI so existing trainer chat and memory flows
 * keep their current provider and behavior.
 */
export const callOpenAIWorkoutPlan = async ({
  systemPrompt,
  userMessage,
  maxTokens = 8192,
  timeoutMs,
}: {
  systemPrompt: string;
  userMessage: string;
  maxTokens?: number;
  timeoutMs?: number;
}): Promise<string> => {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured");
  }

  const response = await fetchTextWithTimeout(
    "https://api.openai.com/v1/chat/completions",
    {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: process.env.OPENAI_WORKOUT_MODEL || "gpt-5.4",
      max_completion_tokens: maxTokens,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userMessage },
      ],
    }),
    },
    timeoutMs,
  );

  if (!response.ok) {
    throw new Error(`OpenAI API error: ${response.status} — ${response.body}`);
  }

  const data = JSON.parse(response.body);
  const text = ((data.choices?.[0]?.message?.content as string) || "").trim();
  if (!text) {
    throw new Error("OpenAI returned an empty workout plan");
  }

  return text;
};

/** Extract and parse JSON from an LLM response (markdown fences, trailing text, etc.) */
export const parseAIJsonResponse = <T = Record<string, unknown>>(
  raw: string,
): T => {
  const text = raw.trim();
  if (!text) throw new Error("AI returned empty response");

  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  const candidates = [
    fenced?.[1]?.trim(),
    text,
    extractJsonObject(text),
  ].filter(Boolean) as string[];

  const repaired = repairTruncatedJson(text);
  if (repaired) candidates.push(repaired);

  for (const candidate of candidates) {
    try {
      return JSON.parse(candidate) as T;
    } catch {
      // try next candidate
    }
  }

  throw new Error("Could not parse JSON from AI response");
};

/** Close truncated JSON when the model hits max_tokens mid-object */
const repairTruncatedJson = (text: string): string | null => {
  const extracted = extractJsonObject(text);
  if (!extracted) return null;

  try {
    JSON.parse(extracted);
    return extracted;
  } catch {
    // fall through to bracket repair
  }

  let slice = extracted.replace(/,\s*([}\]])/g, "$1");
  slice = slice.replace(/,\s*"[^"]*"?\s*:?\s*("?[^"]*)?$/, "");
  slice = slice.replace(/,\s*$/, "");

  const stack: string[] = [];
  let inString = false;
  let escaped = false;

  for (const char of slice) {
    if (inString) {
      if (escaped) escaped = false;
      else if (char === "\\") escaped = true;
      else if (char === '"') inString = false;
      continue;
    }
    if (char === '"') {
      inString = true;
      continue;
    }
    if (char === "{") stack.push("}");
    else if (char === "[") stack.push("]");
    else if (char === "}" || char === "]") stack.pop();
  }

  while (stack.length) slice += stack.pop();

  try {
    JSON.parse(slice);
    return slice;
  } catch {
    return null;
  }
};

const extractJsonObject = (text: string): string | null => {
  const start = text.indexOf("{");
  if (start === -1) return null;

  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let i = start; i < text.length; i++) {
    const char = text[i];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char === "\\") {
        escaped = true;
      } else if (char === '"') {
        inString = false;
      }
      continue;
    }

    if (char === '"') {
      inString = true;
      continue;
    }

    if (char === "{") depth++;
    if (char === "}") {
      depth--;
      if (depth === 0) return text.slice(start, i + 1);
    }
  }

  return null;
};

// ─────────────────────────────────────────────────────────────
// TRAINER SYSTEM PROMPTS
// Each trainer has their own locked AI persona
// ─────────────────────────────────────────────────────────────

export const TRAINER_SYSTEM_PROMPTS: Record<string, string> = {
  ...BUILT_IN_TRAINER_SYSTEM_PROMPTS,
  // Legacy alias
  muscle_gain_b: BUILT_IN_TRAINER_SYSTEM_PROMPTS.muscle_gain_ryan,
};

// ─────────────────────────────────────────────────────────────
// GET TRAINER SYSTEM PROMPT
// Uses custom DB prompt if set, otherwise falls back to built-in
// ─────────────────────────────────────────────────────────────

export const getTrainerSystemPrompt = (
  personaKey: string | null,
  customSystemPrompt?: string,
): string => {
  if (customSystemPrompt) return customSystemPrompt;
  if (personaKey && TRAINER_SYSTEM_PROMPTS[personaKey]) {
    return TRAINER_SYSTEM_PROMPTS[personaKey];
  }
  // Default fallback
  return TRAINER_SYSTEM_PROMPTS["maintain_physique_gabriel"];
};

// ─────────────────────────────────────────────────────────────
// MEMORY SUMMARIZER
// Runs after each session to extract durable facts
// Input: last trainer-user exchange
// Output: structured memory update JSON
// ─────────────────────────────────────────────────────────────

export const summarizeSessionMemory = async (
  lastExchange: string,
): Promise<IMemoryUpdateResult | null> => {
  const systemPrompt = `You are a memory summarizer for a fitness app.
Extract structured facts from the trainer-user exchange provided.
Output ONLY valid JSON. No explanation. No markdown. No backticks.`;

  const userMessage = `
Extract memory facts from this session exchange:

${lastExchange}

Return this exact JSON structure:
{
  "profile_updates": {
    "limitations": "any new injury or limitation mentioned, or null",
    "equipment": "any equipment change mentioned, or null",
    "preferences": "any new preference mentioned, or null"
  },
  "session_summary": {
    "workoutSummary": "one sentence describing what was done",
    "adherence": "completed | skipped | modified",
    "rpe": null,
    "painNotes": "any pain mentioned or null",
    "loadsUsed": {},
    "energyLevel": null
  },
  "flags": []
}

Possible flags: "pain_flag", "low_adherence", "plateau_risk", "overtraining_risk", "low_energy"
`;

  const response = await callAI({
    systemPrompt,
    userMessage,
    maxTokens: 600,
  });

  try {
    return parseAIJsonResponse<IMemoryUpdateResult>(response);
  } catch {
    return null;
  }
};

// ─────────────────────────────────────────────────────────────
// EXERCISE BLOCK GENERATION PROMPT
// Used by trainer service to AI-generate exercise blocks
// ─────────────────────────────────────────────────────────────

export const buildExerciseBlockGenerationPrompt = (
  trainer: any,
  blockName: string,
  category: string,
  count: number,
  context?: string,
): string => {
  const kp = trainer.knowledgePack || {};

  return `
You are building an exercise block called "${blockName}" for trainer ${trainer.name}.

Trainer Specialty: ${trainer.specialty}
Category: ${category}
Number of exercises to generate: ${count}
Additional context: ${context || "none"}

Trainer Preferences:
- Rep ranges: ${kp.repRanges || "8-12"}
- Rest times: ${kp.restTimes || "60-90s"}
- Intensity measure: ${kp.intensityMeasure || "RPE"}
- Must-use exercises: ${(kp.mustUseExercises || []).join(", ") || "none specified"}
- Avoid exercises: ${(kp.avoidExercises || []).join(", ") || "none specified"}

Generate exactly ${count} exercises for the "${category}" category.

Return ONLY this exact JSON structure (no markdown, no explanation):
{
  "description": "Brief description of this exercise block",
  "exercises": [
    {
      "name": "Exercise Name",
      "muscleGroup": "${category}",
      "difficulty": "beginner | intermediate | advanced",
      "equipment": "equipment needed",
      "sets": 3,
      "reps": "8-12",
      "restTime": "60s",
      "rpe": "7-8",
      "steps": [
        { "order": 1, "instruction": "How to perform step 1", "tip": "Optional form tip" },
        { "order": 2, "instruction": "How to perform step 2" }
      ],
      "substitutions": {
        "noBarbell": "alternative without barbell",
        "noMachine": "alternative without machine",
        "homeOnly": "home-friendly alternative",
        "hotelGym": "hotel gym alternative"
      },
      "tags": ["compound", "push", "knee-friendly"]
    }
  ]
}
`;
};
