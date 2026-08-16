/**
 * Stream Chat Service
 *
 * Wraps the Stream Chat Node.js SDK.
 * All stream credentials stay server-side — the Flutter client only ever
 * receives a short-lived user token and the channel ID.
 *
 * Environment variables required:
 *   STREAM_API_KEY    – Stream app API key
 *   STREAM_API_SECRET – Stream app API secret
 */

import { StreamChat } from "stream-chat";

let _client: StreamChat | null = null;

function getClient(): StreamChat {
  if (_client) return _client;
  const key    = process.env.STREAM_API_KEY;
  const secret = process.env.STREAM_API_SECRET;
  if (!key || !secret) {
    throw new Error("STREAM_API_KEY and STREAM_API_SECRET are required");
  }
  _client = StreamChat.getInstance(key, secret);
  return _client;
}

export function isStreamConfigured(): boolean {
  return !!(process.env.STREAM_API_KEY && process.env.STREAM_API_SECRET);
}

// ─────────────────────────────────────────────────────────────────────────────
// Upsert a user in Stream (create or update their display name / photo)
// Called on login and when a user's profile changes.
// ─────────────────────────────────────────────────────────────────────────────
export async function upsertStreamUser(user: {
  id: string;
  name: string;
  image?: string;
  role?: "trainer" | "user";
}): Promise<void> {
  const client = getClient();
  const payload = {
    id:    user.id,
    name:  user.name,
    ...(user.image ? { image: user.image } : {}),
    role:  "user", // Stream built-in role; use custom data for trainer flag
  } as any;
  await client.upsertUsers([payload]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Generate a short-lived Stream user token (valid 24h)
// The Flutter client sends this to StreamChatClient.connectUser()
// ─────────────────────────────────────────────────────────────────────────────
export function generateStreamToken(userId: string): string {
  const client = getClient();
  const expiresAt = Math.floor(Date.now() / 1000) + 24 * 60 * 60; // 24h
  return client.createToken(userId, expiresAt);
}

// ─────────────────────────────────────────────────────────────────────────────
// Get or create the messaging channel between a trainer and a subscriber.
// Channel ID is deterministic so calling this multiple times is idempotent.
// ─────────────────────────────────────────────────────────────────────────────
export async function getOrCreateChannel(opts: {
  trainerId:    string;
  trainerName:  string;
  trainerImage?: string;
  userId:       string;
  userName:     string;
  userImage?:   string;
}): Promise<{ channelId: string; channelType: string }> {
  const client = getClient();

  // Upsert both users so Stream knows their display names
  await client.upsertUsers([
    {
      id:   opts.trainerId,
      name: opts.trainerName,
      ...(opts.trainerImage ? { image: opts.trainerImage } : {}),
    },
    {
      id:   opts.userId,
      name: opts.userName,
      ...(opts.userImage ? { image: opts.userImage } : {}),
    },
  ]);

  // Deterministic channel ID — both sides can reconstruct it
  const channelId   = `t_${opts.trainerId}_u_${opts.userId}`;
  const channelType = "messaging";

  const channel = client.channel(channelType, channelId, {
    members: [opts.trainerId, opts.userId],
    created_by_id: opts.trainerId,
  } as any);

  await channel.create();
  return { channelId, channelType };
}

// ─────────────────────────────────────────────────────────────────────────────
// Send a system message into a channel (e.g. "Workout plan shared")
// Used when a trainer shares a meal/workout plan — appears as a chat message.
// ─────────────────────────────────────────────────────────────────────────────
export async function sendSystemMessage(opts: {
  channelId:   string;
  channelType: string;
  senderId:    string;
  text:        string;
  attachments?: Array<{ type: string; title: string; text?: string; asset_url?: string }>;
}): Promise<void> {
  const client  = getClient();
  const channel = client.channel(opts.channelType, opts.channelId);
  await channel.sendMessage({
    text:        opts.text,
    user_id:     opts.senderId,
    ...(opts.attachments ? { attachments: opts.attachments } : {}),
  });
}
