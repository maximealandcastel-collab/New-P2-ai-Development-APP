/** Equipment preferences are workout constraints, never tenant authorization. */
export const equipmentToken = (value: string): string =>
  value.trim().toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");

const aliases: Record<string, string> = {
  dumbbell: "dumbbells", kettlebell: "kettlebells", barbells: "barbell",
  resistance_band: "resistance_bands", bands: "resistance_bands",
  machine: "machines", cable: "cable_machine", cables: "cable_machine",
  cable_machines: "cable_machine", pullup_bar: "pull_up_bar",
  bodyweight: "bodyweight_only", body_weight: "bodyweight_only",
  none: "bodyweight_only", no_equipment: "bodyweight_only",
};
const known = new Set([
  "barbell", "dumbbells", "machines", "resistance_bands", "kettlebells",
  "pull_up_bar", "bench", "cable_machine", "treadmill", "bodyweight_only",
  "boxing_bag", "jump_rope", "others",
]);
const canonical = (value: string): string => {
  const token = equipmentToken(value);
  return aliases[token] || token;
};

export const normalizeEquipment = (value: unknown): string[] => {
  if (!Array.isArray(value) || value.some(item => typeof item !== "string")) {
    throw new Error("Equipment must be a list of equipment names");
  }
  const result = [...new Set(value.map(canonical))];
  if (result.some(item => !known.has(item))) {
    throw new Error("Unsupported equipment selection; choose a listed equipment type");
  }
  return result;
};

/** Undefined inventory preserves personal workouts; [] means bodyweight only. */
export const resolveWorkoutEquipment = (
  selected: unknown,
  facilityEquipment?: unknown,
): string[] => {
  const personal = normalizeEquipment(selected);
  if (!personal.length) throw new Error("Select equipment or no equipment");
  if (facilityEquipment === undefined) return personal;
  const inventory = new Set(normalizeEquipment(facilityEquipment));
  inventory.add("bodyweight_only");
  const effective = personal.filter(item => inventory.has(item) && item !== "others");
  if (!effective.length) {
    throw new Error("None of the selected equipment is available at this facility; update your selections");
  }
  return effective;
};

/** Match every required item, never a substring or an unrestricted 'others'. */
export const exerciseMatchesEquipment = (
  required: unknown,
  available: readonly string[],
): boolean => {
  if (typeof required !== "string" || !required.trim()) return false;
  const requirements = required.split(/\s*(?:,|\+|&|\/|\band\b)\s*/i).map(canonical);
  const allowed = new Set(available.map(canonical));
  return requirements.length > 0 && requirements.every(item =>
    item === "bodyweight_only" || (known.has(item) && item !== "others" && allowed.has(item)),
  );
};
