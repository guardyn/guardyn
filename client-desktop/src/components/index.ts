/**
 * Components Index
 *
 * Central export for all UI components.
 */

// Core UI
export { default as IncomingCall } from './IncomingCall';
export { default as Sidebar } from './Sidebar';
export { ProfileSection, type UserProfile, type ProfileSectionProps } from './ProfileSection';

// Error Handling
export {
    EmptyState, ErrorBoundary, LoadingSpinner, ToastContainer, dismissToast, showToast
} from './ErrorHandling';

// Loading States
export {
    FullPageSkeleton,
    LoadingIndicator, SkeletonAvatar, SkeletonBox, SkeletonCallParticipant, SkeletonConversationItem,
    SkeletonConversationList,
    SkeletonMessage,
    SkeletonMessageList,
    SkeletonProfileCard, SkeletonSearchResult, SkeletonSettingsSection, SkeletonText
} from './Skeleton';

// Network Status
export {
    ConnectionStatus, ErrorState, OfflineBanner, RetryButton, initNetworkListeners, useNetworkStatus
} from './NetworkStatus';

// Keyboard Shortcuts
export {
    ShortcutHint, ShortcutsModal, closeShortcutsModal, openShortcutsModal
} from './KeyboardShortcuts';

// Accessibility
export {
    A11yButton, Announce, FocusTrap, FormField, LiveRegion, SkipLink, VisuallyHidden, createAnnouncer, useHighContrast, useReducedMotion
} from './Accessibility';

// Responsive Layout
export {
    AdaptiveContainer, CollapsibleSidebar,
    ResizablePanel, ResponsiveProvider, ShowAbove,
    ShowBelow, SplitView,
    WindowConstraint,
    breakpoints, useResponsive
} from './ResponsiveLayout';
export type { Breakpoint } from './ResponsiveLayout';

// Theme
export { ThemeSwitcher, ThemeToggle } from './ThemeSwitcher';

// User Search
export { UserCard, UserSearch, type UserCardProps, type UserSearchProps } from './UserSearch';

// Chat Components
export * from './chat';

// Shared Components
export * from './shared';

// Media Components
export * from './media';
