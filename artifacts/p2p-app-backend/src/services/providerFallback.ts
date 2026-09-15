/** Start the backup on primary failure or after a bounded delay. Only a fully
 * validated result may win. Abort the other request and always enforce a deadline. */
export function runWithProviderBackup<T>({
  primary, backup, backupDelayMs, deadlineMs,
}: {
  primary: (signal: AbortSignal) => Promise<T>;
  backup: (signal: AbortSignal) => Promise<T>;
  backupDelayMs: number;
  deadlineMs: number;
}): Promise<T> {
  if (!Number.isFinite(backupDelayMs) || backupDelayMs < 0 ||
      !Number.isFinite(deadlineMs) || deadlineMs <= backupDelayMs) {
    return Promise.reject(new Error("Invalid provider deadline configuration"));
  }
  return new Promise<T>((resolve, reject) => {
    const controller = new AbortController();
    let settled = false;
    let backupStarted = false;
    const failures: unknown[] = [];
    const finish = (value?: T, error?: unknown) => {
      if (settled) return;
      settled = true;
      clearTimeout(backupTimer);
      clearTimeout(deadlineTimer);
      controller.abort();
      if (error !== undefined) reject(error); else resolve(value as T);
    };
    const attempt = async (provider: (signal: AbortSignal) => Promise<T>) => {
      try {
        const value = await provider(controller.signal);
        finish(value);
      } catch (error) {
        if (settled) return;
        failures.push(error);
        startBackup();
        if (failures.length === 2) finish(undefined, new Error("Both workout providers failed validation or delivery"));
      }
    };
    const startBackup = () => {
      if (settled || backupStarted) return;
      backupStarted = true;
      void attempt(backup);
    };
    const backupTimer = setTimeout(startBackup, backupDelayMs);
    const deadlineTimer = setTimeout(() => finish(undefined,
      new Error(`Workout provider deadline exceeded after ${deadlineMs}ms`)), deadlineMs);
    void attempt(primary);
  });
}
