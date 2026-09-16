import mongoose, { Schema, Types } from 'mongoose';
import { randomUUID } from 'crypto';
import { UserModel, OTPModel } from '../user/user.model';
import { TrainerModel } from '../trainer/trainer.model';

const cleanupSchema = new Schema({
  userId: { type: Schema.Types.ObjectId, required: true, unique: true },
  assets: { type: [String], default: [] },
  status: { type: String, enum: ['pending_external_cleanup','complete'], required: true },
  deletedAt: { type: Date, required: true },
});
export const AccountDeletionCleanup = mongoose.models.AccountDeletionCleanup || mongoose.model('AccountDeletionCleanup',cleanupSchema);

/** Remove application personal data atomically. Retain payment/audit IDs; external
 * media deletion is durably queued and must be completed by the storage operator.
 * The UI must not claim every remote asset or retained financial record is erased.
 */
export async function deletePersonalAccount(id: string) {
  const session = await UserModel.startSession();
  try {
    await session.withTransaction(async () => {
      const user: any = await UserModel.findById(id).session(session).lean();
      if (!user || user.isDeleted) return;
      const objectId = new Types.ObjectId(id);
      const trainer: any = await TrainerModel.findOne({userId:objectId}).session(session).lean();
      const db = mongoose.connection.db!;
      const assets = [user.profilePicture,user.coverPhoto,trainer?.profileImage,trainer?.introVideoUrl].filter(v=>typeof v==='string' && v);
      const posts = await db.collection('userposts').find({userId:objectId},{session}).toArray();
      for (const post of posts) for (const key of ['beforeImageUrl','afterImageUrl']) if (typeof post[key]==='string' && post[key]) assets.push(post[key]);
      if (trainer) {
        const content = await db.collection('contents').find({trainerId:trainer._id},{session}).toArray();
        for (const item of content) for (const key of ['videoUrl','thumbnailUrl','muxAssetId']) if (typeof item[key]==='string' && item[key]) assets.push(item[key]);
        await db.collection('contents').deleteMany({trainerId:trainer._id},{session});
        await TrainerModel.collection.replaceOne({_id:trainer._id},{_id:trainer._id,userId:objectId,name:'Deleted trainer',isActive:false,isVerified:false},{session});
        await UserModel.updateMany({subscribedTrainer:trainer._id},{$set:{subscribedTrainer:null}},{session});
      }
      for (const collection of ['chats','trainerconversations','workouts','workoutstats','workoutrecords','workoutplans','userposts','devices','notifications','achievementunlocks','anamsessions','phoneverifications','trainerrequests']) {
        const query: any = {userId:objectId};
        if (trainer) { delete query.userId; query.$or=[{userId:objectId},{trainerId:trainer._id}]; }
        await db.collection(collection).deleteMany(query,{session});
      }
      await OTPModel.deleteMany({email:user.email},{session});
      await db.collection('subscriptions').updateMany({userId:objectId,status:'active'},{$set:{status:'cancelled',cancelledAt:new Date()}},{session});
      await db.collection('gymclaims').updateMany({ownerUserId:objectId},{$unset:{ownershipEvidence:1},$set:{representativeName:'Deleted account'}},{session});
      await AccountDeletionCleanup.updateOne({userId:objectId},{$set:{assets:[...new Set(assets)],deletedAt:new Date(),status:assets.length?'pending_external_cleanup':'complete'}},{upsert:true,session});
      // Replace instead of enumerating fields: health/memory/password/device fields
      // added in future releases cannot accidentally survive account deletion.
      await UserModel.collection.replaceOne({_id:objectId},{_id:objectId,isDeleted:true,isVerified:false,
        role:'user',firstName:'Deleted',lastName:'Account',email:`deleted-${randomUUID()}@example.invalid`,
        deletedAt:new Date()},{session});
    });
  } finally { await session.endSession(); }
}
