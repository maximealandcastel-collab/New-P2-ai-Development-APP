import { ITrainerKnowledgePack } from "./trainerKnowladge.interface";
import { TrainerKnowledgePackModel } from "./trainerKnowladge.model";

// ── Get knowledge pack for a trainer ──────────────────────────
export const getKnowledgePack = async (trainerId: string) => {
  return await TrainerKnowledgePackModel.findOne({ trainerId }).lean();
};

// ── Create knowledge pack (first time setup) ──────────────────
export const createKnowledgePack = async (
  trainerId: string,
  data: Partial<ITrainerKnowledgePack>,
) => {
  const existing = await TrainerKnowledgePackModel.findOne({ trainerId });
  if (existing)
    throw new Error("Knowledge pack already exists. Use update instead.");

  return await TrainerKnowledgePackModel.create({ trainerId, ...data });
};

// ── Upsert knowledge pack (create or update in one call) ──────
export const upsertKnowledgePack = async (
  trainerId: string,
  data: Partial<ITrainerKnowledgePack>,
) => {
  return await TrainerKnowledgePackModel.findOneAndUpdate(
    { trainerId },
    { $set: { ...data, trainerId } },
    { new: true, upsert: true },
  );
};

// ── Update knowledge pack ──────────────────────────────────────
export const updateKnowledgePack = async (
  trainerId: string,
  updates: Partial<ITrainerKnowledgePack>,
) => {
  const pack = await TrainerKnowledgePackModel.findOneAndUpdate(
    { trainerId },
    { $set: updates },
    { new: true },
  );
  if (!pack) throw new Error("Knowledge pack not found. Create one first.");
  return pack;
};

// ── Delete knowledge pack ──────────────────────────────────────
export const deleteKnowledgePack = async (trainerId: string) => {
  await TrainerKnowledgePackModel.findOneAndDelete({ trainerId });
  return { message: "Knowledge pack deleted" };
};
