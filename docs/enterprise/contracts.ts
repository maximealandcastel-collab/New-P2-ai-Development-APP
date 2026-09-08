/** Proposed wire contract for the EXISTING P2P Express/Mongoose backend.
 * These types are not mounted endpoints or a replacement server.
 * Keep existing auth tokens and sendResponse conventions; IDs serialize to strings.
 */
export type Id = string;
export type Role = 'owner' | 'admin' | 'trainer' | 'member';
export interface Envelope<T> { success: boolean; statusCode?: number; status?: number; message: string; data: T }
export interface Page<T> { items: T[]; nextCursor: string | null }
export interface Location { id?: Id; name: string; address: string; city: string; zipCode: string; lat?: number; lng?: number }
export interface TenantConfiguration {
  schemaVersion: 1; id: Id; name: string; logoUrl: string; slogan: string;
  primaryColor: string; secondaryColor: string; accentColor: string;
  timezone: string; photos: string[]; locations: Location[];
  contact: { email?: string; phone?: string; website?: string };
  category?: string; tags?: string[];
}
export interface AuthorizedContext { tenant: TenantConfiguration; roles: Role[]; capabilities: string[] }
export interface ContextResponse { context: AuthorizedContext | null }
export interface TenantRecord { id: Id; tenantId: Id; createdAt: string; updatedAt: string }
export interface Membership extends TenantRecord {
  userId: Id; name: string; roles: Role[]; status: 'active' | 'suspended' | 'removed';
}
export interface MembershipChoice { id: Id; tenantId: Id; name: string; status: 'active' | 'invited'; roles: Role[] }
export interface JoinRequest extends TenantRecord { userId: Id; status: 'submitted' | 'approved' | 'declined' }
export interface Invitation extends TenantRecord { email: string; roles: Role[]; expiresAt: string; status: 'pending' | 'accepted' | 'expired' | 'revoked' }
export interface Plan extends TenantRecord { name: string; description?: string; durationDays: number; status: 'active' | 'archived' }
export interface Subscription extends TenantRecord {
  membershipId: Id; planId: Id; startsAt: string; endsAt: string;
  status: 'active' | 'cancelled' | 'expired';
}
export interface Trainer extends TenantRecord { membershipId: Id; name: string; bio?: string; status: 'active' | 'removed' }
export interface GymClass extends TenantRecord { name: string; trainerId: Id; locationId: Id; startsAt: string; capacity: number; status: 'scheduled' | 'cancelled' }
export interface Enrollment extends TenantRecord { classId: Id; membershipId: Id; status: 'enrolled' | 'cancelled' }
export interface Content extends TenantRecord { title: string; description?: string; mediaUrl?: string; status: 'published' | 'archived' }
export interface Activity extends TenantRecord { actorUserId: Id; action: string; resourceType: string; resourceId: Id; detail?: string }
export interface DisplayRecord { id: Id; name?: string; title?: string; email?: string; allowedActions?: string[]; [key: string]: unknown }
export interface Dashboard {
  administrator: { firstName?: string; lastName?: string };
  counts: { signups: number; members: number; activeSubscriptions: number; trainers: number };
  recentSignups: DisplayRecord[]; activeSubscriptions: DisplayRecord[];
  recentTrainers: DisplayRecord[]; recentActivity: DisplayRecord[];
}
export interface AnalyticsRow extends DisplayRecord { date: string; signups: number; members: number; activeSubscriptions: number; trainers: number }
export interface ProvisionRequest { configuration: TenantConfiguration; ownerEmail?: string }
export interface ProvisionResult { tenantId: Id; created: boolean; invitationId?: Id }
