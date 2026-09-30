# P2P Fit Tech AI — claimed gym brand system prompt

You are implementing the P2P enterprise gym experience in this Flutter
repository. Treat each activated gym as its own authorized tenant. Resolve the
tenant from the authenticated backend scope and selected gym ID; never infer
access from an email address, route, visual selection, or a logo. A franchise
supplies a default palette, while an approved location override may replace
its colors without changing that location's data or permissions.

For every claimed, verified, or activated gym, use one shared
`EnterpriseGymTheme`/`TenantBrandService` visual system on login, signup,
onboarding, member and trainer dashboards, workouts, history, calendar,
nutrition, gyms and gym detail, community posting and feed controls, content,
profile, admin and client screens, bottom navigation, center plus action,
dialogs, selected tabs and filters, and primary calls to action. Use the
tenant's approved primary/secondary/accent values. The selected tenant's
color must appear on its own home, community, calendar selection, and plus
button. Do not hand-style screens according to gym names.

The foundation is white or off-white. Use near-black text and keep existing
typography, layout, functionality, navigation, and APIs. Place restrained
charcoal-to-gym-color depth on priority actions and active states; use only a
faint gym-color tint on borders, card surfaces, and background highlights.
Keep the gym color recognizable and dominant. Avoid full-screen color washes,
neon, large glows, and P2P orange in a claimed gym's active controls. P2P's
own flagship remains charcoal-to-burnt-orange. YMCA is navy/charcoal-to-its
approved blue; KMF is charcoal-to-its approved green. These are examples,
not per-screen special cases.

Never redraw, recolor, crop away identifying details, overlay, or replace the
approved gym logo. The source logo image is independent of UI theme tokens.
An owner may choose exact colors in Claim Your Gym; an uploaded logo may
provide a suggested palette for review. A color suggestion never changes
the logo or bypasses ownership, licensing, and palette approval. If no
approved chromatic color is available, use neutral charcoal-to-graphite
until one is approved. Do not default a new gym to P2P orange.

On claim approval and tenant activation, the backend must publish the approved
tenant ID, logo URL, franchise inheritance or approved local override, and
brand palette to the existing tenant configuration. The Flutter client derives
theme tokens once and consumes them across shared components. Switching gyms,
signing out, or resuming a session must clear or restore the correct tenant
theme; never leak one gym's color or data into another gym's account.

Acceptance checks: sign in as members and admins of two distinct activated
gyms; inspect home, calendar, gym directory, community composer, plus button,
login, trainer/admin controls, and logout/resume. Confirm each screen shows
the selected gym's approved color with subtle black depth and white surfaces,
logos remain unchanged, and P2P orange returns only in the flagship session.
Confirm a new claim can choose a color or review a logo suggestion and that
the neutral fallback appears if no color can be extracted. Run Flutter analysis
and relevant tests, then archive an iOS CodeMagic build before claiming device
behavior is verified.
