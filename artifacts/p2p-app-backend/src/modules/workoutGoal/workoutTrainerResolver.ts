import { Types } from "mongoose";
import { TrainerModel } from "../trainer/trainer.model";

type WorkoutUser = {
  _id: Types.ObjectId;
  role?: string;
  subscribedTrainer?: Types.ObjectId;
};

export const resolveWorkoutTrainer = async (
  user: WorkoutUser,
  preferredTrainerId?: unknown,
) => {
  const assignedTrainerId = preferredTrainerId || user.subscribedTrainer;
  if (assignedTrainerId && Types.ObjectId.isValid(String(assignedTrainerId))) {
    const assignedTrainer = await TrainerModel.findById(assignedTrainerId);
    if (assignedTrainer) return assignedTrainer;
  }

  // Trainer/admin accounts are allowed to test the user workout flow, but they
  // do not subscribe to themselves. Resolve only their own trainer profile;
  // regular users still require a real subscribed trainer.
  if (user.role === "trainer" || user.role === "admin") {
    return TrainerModel.findOne({
      userId: user._id,
      isActive: { $ne: false },
    });
  }

  return null;
};