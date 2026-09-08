#!/usr/bin/env node
// Client tool for proposed platform endpoints. Does not implement those endpoints.
import { readFile, realpath } from 'node:fs/promises';
import { resolve, sep, basename } from 'node:path';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));
function check(ok, message) { if (!ok) throw new Error(message); }
function validate(value, schema, path = 'configuration') {
  if ('const' in schema) check(value === schema.const, `${path}: invalid version`);
  if (schema.type === 'object') {
    check(value !== null && typeof value === 'object' && !Array.isArray(value), `${path}: expected object`);
    for (const key of schema.required ?? []) check(key in value, `${path}.${key}: required`);
    for (const key of Object.keys(value)) {
      check(schema.properties[key] !== undefined, `${path}: unknown field ${key}`);
      validate(value[key], schema.properties[key], `${path}.${key}`);
    }
  }
  if (schema.type === 'string') {
    check(typeof value === 'string', `${path}: expected string`);
    if (schema.minLength) check(value.trim().length >= schema.minLength, `${path}: empty string`);
    if (schema.pattern) check(new RegExp(schema.pattern).test(value), `${path}: invalid format`);
  }
  if (schema.type === 'number') check(typeof value === 'number' && Number.isFinite(value) && value >= schema.minimum && value <= schema.maximum, `${path}: out of range`);
  if (schema.type === 'array') {
    check(Array.isArray(value), `${path}: expected array`);
    check(value.length >= (schema.minItems ?? 0), `${path}: too few entries`);
    if (schema.uniqueItems) check(new Set(value.map(JSON.stringify)).size === value.length, `${path}: duplicate entries`);
    value.forEach((item, index) => validate(item, schema.items, `${path}[${index}]`));
  }
}
function safeBase(raw) {
  const url = new URL(raw);
  check(!url.username && !url.password && !url.search && !url.hash, 'API base must not contain credentials/query/fragment');
  check(url.protocol === 'https:' || (url.protocol === 'http:' && ['localhost','127.0.0.1','[::1]'].includes(url.hostname)), 'API base requires HTTPS (HTTP only for local testing)');
  return url.href.replace(/\/$/, '');
}
async function main() {
  const args = process.argv.slice(2), options = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    check(['--config','--key','--owner-email','--dry-run'].includes(key), `Unknown option: ${key}`);
    check(!(key in options), `Repeated option: ${key}`);
    if (key === '--dry-run') options[key] = true;
    else { check(args[i + 1] && !args[i + 1].startsWith('--'), `Missing value: ${key}`); options[key] = args[++i]; }
  }
  check(options['--config'], 'Usage: node scripts/provision-enterprise.mjs --config <json> [--dry-run] [--key <id>] [--owner-email <email>]');
  const config = JSON.parse(await readFile(resolve(options['--config']), 'utf8'));
  const schema = JSON.parse(await readFile(resolve(root, 'docs/enterprise/tenant.schema.json'), 'utf8'));
  validate(config, schema);
  new Intl.DateTimeFormat('en', { timeZone: config.timezone }).format();
  const email = options['--owner-email'];
  if (email) check(/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email), 'Invalid owner email');
  const localAssets = new Map();
  const assetsRoot = await realpath(resolve(root, 'assets'));
  for (const asset of new Set([config.logoUrl, ...config.photos])) {
    if (asset.startsWith('assets/')) {
      const path = await realpath(resolve(root, asset));
      check(path.startsWith(assetsRoot + sep), 'Asset path escapes assets directory');
      const bytes = await readFile(path);
      check(bytes.length > 0 && bytes.length <= 10 * 1024 * 1024, 'Local image must be 1 byte to 10 MB');
      const mime = bytes.subarray(0, 3).equals(Buffer.from([255,216,255])) ? 'image/jpeg'
        : bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])) ? 'image/png'
        : bytes.toString('ascii',0,4) === 'RIFF' && bytes.toString('ascii',8,12) === 'WEBP' ? 'image/webp' : null;
      check(mime, 'Unsupported local image signature (JPEG/PNG/WebP only)');
      localAssets.set(asset, {bytes, mime});
    } else {
      const url = new URL(asset);
      check(url.protocol === 'https:' && !url.username && !url.password, 'Remote assets require HTTPS without credentials');
      if (!options['--dry-run']) check(!/(^|\.)example\.(com|org|net)$/.test(url.hostname), 'Replace placeholder assets before provisioning');
    }
  }
  if (options['--dry-run']) {
    console.log(`Validated ${config.id}; ${localAssets.size} local assets. No network calls; remote assets not fetched.`);
    return;
  }
  const key = options['--key'], token = process.env.ENTERPRISE_PLATFORM_TOKEN;
  check(key && /^[A-Za-z0-9._:-]{1,120}$/.test(key), 'Supply a stable --key (1-120 letters/digits/._:-)');
  check(token && process.env.ENTERPRISE_API_BASE, 'Set ENTERPRISE_API_BASE and ENTERPRISE_PLATFORM_TOKEN');
  const base = safeBase(process.env.ENTERPRISE_API_BASE);
  async function post(path, body, idempotencyKey, json = false) {
    const response = await fetch(`${base}/enterprise/platform/${path}`, {
      method: 'POST', redirect: 'error', signal: AbortSignal.timeout(30000),
      headers: {Authorization: `Bearer ${token}`, 'Idempotency-Key': idempotencyKey, ...(json ? {'Content-Type':'application/json'} : {})},
      body: json ? JSON.stringify(body) : body,
    });
    check(response.ok, `Platform ${path}: HTTP ${response.status}`);
    const result = await response.json();
    check(result.success === true && result.data && typeof result.data === 'object', `Invalid platform ${path} response`);
    return result.data;
  }
  const replacements = new Map();
  for (const [asset, {bytes, mime}] of localAssets) {
    const form = new FormData();
    form.set('file', new Blob([bytes], {type:mime}), basename(asset));
    const hash = createHash('sha256').update(bytes).digest('hex');
    const result = await post('assets', form, `${key}:asset:${hash}`);
    const url = new URL(result.url);
    check(url.protocol === 'https:' && !url.username && !url.password, 'Platform asset URL must use HTTPS');
    replacements.set(asset, url.href);
  }
  config.logoUrl = replacements.get(config.logoUrl) ?? config.logoUrl;
  config.photos = config.photos.map(asset => replacements.get(asset) ?? asset);
  const result = await post('tenants', {configuration:config, ...(email ? {ownerEmail:email} : {})}, key, true);
  check(result.tenantId === config.id, 'Provisioning returned a different tenant ID');
  console.log(`Provisioned ${config.id}. Verify directory and owner access before release.`);
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
