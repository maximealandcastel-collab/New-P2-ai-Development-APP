/** Shared by provider validation and the deterministic fallback. */
const upper = ["chest", "back", "shoulders", "biceps", "triceps", "arms"];
const lower = ["legs", "quads", "hamstrings", "glutes", "calves"];
const words = (value: string) => value.toLowerCase().replace(/[^a-z]+/g, " ").trim().split(/\s+/);

export const splitDayMuscles = (title: string): string[] | null => {
  const tokens = words(title.replace(/\blower[ _-]+back\b/ig, "back"));
  if (/\b(full|total)[ -]?body\b/i.test(title)) return [...upper, ...lower, "core"];
  const muscles = new Set<string>();
  for (const token of tokens) {
    const group = token === "upper" ? upper
      : ["lower", "leg", "legs"].includes(token) ? lower
      : token === "push" ? ["chest", "shoulders", "triceps"]
      : token === "pull" ? ["back", "biceps"]
      : token === "arms" ? ["arms", "biceps", "triceps"]
      : token === "abs" ? ["core"]
      : [...upper, ...lower, "core", "cardio", "conditioning"].includes(token) ? [token] : [];
    group.forEach(item => muscles.add(item));
  }
  return muscles.size ? [...muscles] : null;
};

export const exerciseMatchesSplitDay = (muscleGroup: string | undefined, title: string): boolean => {
  const target = splitDayMuscles(title);
  if (!target) return false;
  const aliases: Record<string, string> = {
    abdominals: "core", abs: "core", abdominal: "core", quadriceps: "quads",
    lats: "back", latissimus: "back", traps: "back", deltoids: "shoulders",
    pectorals: "chest", glute: "glutes", leg: "legs", shoulder: "shoulders",
  };
  return words(muscleGroup || "").some(word => target.includes(aliases[word] || word));
};

export const selectSplitDayExercises = <T extends { _id: unknown; muscleGroup?: string }>(
  library: T[], title: string, dayIndex: number, count: number,
): T[] => {
  const seen = new Set<string>();
  const eligible = library.filter(exercise => {
    const id = String(exercise._id);
    if (seen.has(id) || !exerciseMatchesSplitDay(exercise.muscleGroup, title)) return false;
    seen.add(id);
    return true;
  });
  if (eligible.length < 2) {
    throw new Error(`Not enough approved exercises for split day ${title} and selected equipment`);
  }
  const start = (dayIndex * count) % eligible.length;
  return [...eligible.slice(start), ...eligible.slice(0, start)].slice(0, count);
};
