import { EnterpriseRoutes } from "../modules/enterprise/enterprise.route";
import { UserRoutes } from "../modules/user/user.route";
import { TermsRoutes } from "../modules/settings/Terms/Terms.route";
import { AboutRoutes } from "../modules/settings/About/About.route";
import { PrivacyRoutes } from "../modules/settings/privacy/Privacy.route";
import { NotificationRoutes } from "../modules/notifications/notification.route";

import {
  AppInstruction,
  htmlRoute,
} from "../modules/settings/privacy/Privacy.controller";
import { AdminRoutes } from "../modules/admin/admin.route";

import { CategoryRoutes } from "../modules/category/category.route";
import { ContentRoutes } from "../modules/content/content.route";
import { VideoStreamRoutes } from "../modules/content/videoStream.route";
import { ContentFeedRoutes } from "../modules/content/feed.route";
import { WorkoutRoutes } from "../modules/workoutGoal/workoutGoal.route";
import { ExerciseRoutes } from "../modules/exercise/exercise.route";
import { ExerciseStepRoutes } from "../modules/exerciseStep/exerciseStep.route";
import { TrainerKnowledgePackRoutes } from "../modules/trainerKnowladge/trainerKnowladge.route";
import { TrainerRoutes } from "../modules/trainer/trainer.route";
import { ChatRoutes } from "../modules/chat/chat.route";
import {
  ExerciseBlockRoutes,
  ExerciseBlockStandaloneRoutes,
} from "../modules/exerciseBlock/exerciseBlock.route";
import { AnamRoutes } from "../modules/anam/anam.routes";
import { TrainerRequestRoutes } from "../modules/trainerRequest/trainerRequest.route";
import { InvoiceRoutes } from "../modules/invoice/invoice.route";
import { SubscriptionRoutes } from "../modules/subscription/subscription.route";
import { PaymentRoutes } from "../modules/payment/payment.route";
import { UpdateRoutes } from "../modules/update/update.route";
import { CommissionRoutes } from "../modules/commission/commission.route";
import { WithdrawalRoutes } from "../modules/withdrawal/withdrawal.route";
import { PromoCodeRoutes } from "../modules/promoCode/promoCode.route";
import { DefaultContentRoutes } from "../modules/defaultContent/defaultContent.route";
import { IAPRoutes } from "../modules/iap/iap.route";
import { AffiliateRoutes } from "../modules/affiliate/affiliate.route";
import { PhoneVerificationRoutes } from "../modules/phoneVerification/phoneVerification.route";
// Sendblue removed

// import { PaymentRoute } from "../modules/unused_payments/payment.route";

import { DeviceRoutes } from "../modules/device/device.route";
import { FunxtionRoutes } from "../modules/funxtion/funxtion.route";
import { WorkoutPlanRoutes } from "../modules/workoutPlan/workoutPlan.route";
import { UserPostRoutes } from "../modules/user-posts/userPost.route";
import { MuxRoutes } from "../modules/mux/mux.routes";
import { StreamRoutes } from "../modules/stream/stream.routes";
import { HyperHumanRoutes } from "../modules/hyperhuman/hyperhuman.route";
import { AchievementRoutes } from "../modules/achievement/achievement.route";
import { GymAdminRoutes } from "../modules/gymAdmin/gymAdmin.route";
import { TenantAccessRoutes } from "../modules/tenantAccess/tenantAccess.route";
import { PublicStatsRoutes } from "../modules/publicStats/publicStats.route";

export const routesConfig = [
  { path: "enterprise", handler: EnterpriseRoutes },
  { path: "auth", handler: UserRoutes },
  { path: "category", handler: CategoryRoutes },
  { path: "content", handler: VideoStreamRoutes },
  { path: "content", handler: ContentFeedRoutes },
  { path: "content", handler: ContentRoutes },
  { path: "default-content", handler: DefaultContentRoutes },
  { path: "workout", handler: WorkoutRoutes },
  { path: "trainer", handler: TrainerRoutes },
  { path: "trainerKnowladge", handler: TrainerKnowledgePackRoutes },
  { path: "exercise", handler: ExerciseRoutes },
  { path: "exerciseBlock", handler: ExerciseBlockRoutes },
  { path: "block", handler: ExerciseBlockStandaloneRoutes },
  { path: "exercise-steps", handler: ExerciseStepRoutes },
  { path: "chat", handler: ChatRoutes },
  { path: "anam", handler: AnamRoutes },
  { path: "trainer-request", handler: TrainerRequestRoutes },
  { path: "invoice", handler: InvoiceRoutes },
  { path: "subscription", handler: SubscriptionRoutes },
  { path: "payment", handler: PaymentRoutes },
  { path: "update", handler: UpdateRoutes },
  { path: "commission", handler: CommissionRoutes },
  { path: "withdrawal", handler: WithdrawalRoutes },
  { path: "promo", handler: PromoCodeRoutes },
  { path: "iap", handler: IAPRoutes },
  { path: "affiliate", handler: AffiliateRoutes },
  { path: "devices", handler: DeviceRoutes },
  { path: "auth", handler: PhoneVerificationRoutes },
  { path: "funxtion", handler: FunxtionRoutes },
  { path: "workout-plan", handler: WorkoutPlanRoutes },
  { path: "user-posts", handler: UserPostRoutes },
  { path: "mux", handler: MuxRoutes },
  { path: "stream", handler: StreamRoutes },
  { path: "hyperhuman", handler: HyperHumanRoutes },
  { path: "achievements", handler: AchievementRoutes },
  // Sendblue removed

  { path: "terms", handler: TermsRoutes },
  { path: "about", handler: AboutRoutes },
  { path: "privacy", handler: PrivacyRoutes },
  { path: "notification", handler: NotificationRoutes },

  // { path: "/api/v1/payment", handler: PaymentRoute },

  { path: "admin", handler: AdminRoutes },
  { path: "gym-admin", handler: GymAdminRoutes },
  { path: "tenants", handler: TenantAccessRoutes },
  { path: "public", handler: PublicStatsRoutes },

  //------>publishing app <--------------
  { path: "/privacy-policy-page", handler: htmlRoute },
  { path: "/app-instruction", handler: AppInstruction },
];
