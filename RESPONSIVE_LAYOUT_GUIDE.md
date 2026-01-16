# Responsive Chat Layout Implementation

## Overview
The chat screen now has custom behavior based on device profile:
- **Mobile (< 768px width)**: Original behavior - separate screens for chat list and messages
- **Tablet/Desktop (≥ 768px width)**: Split-screen layout with chat list on left and messages on right (WhatsApp Web style)

## Implementation Details

### Files Created/Modified

#### 1. **responsive_layout.dart** (New)
- Location: `lib/app/core/widgets/responsive_layout.dart`
- Purpose: Utility widget for responsive layout switching
- Breakpoint: 768px (mobile vs desktop/tablet)
- Usage:
  ```dart
  ResponsiveLayout(
    mobile: Widget(), // Shows on < 768px
    desktop: Widget(), // Shows on ≥ 768px
  )
  ```

#### 2. **desktop_chat_layout.dart** (New)
- Location: `lib/app/modules/home/desktop_chat_layout.dart`
- Purpose: Split-screen chat layout for desktop/tablet
- Components:
  - **DesktopChatLayout**: Main layout with Row containing chat list and chat view
  - **DesktopChatListTile**: Chat list item with selection state
  - Left panel (380px): Chat list with header and search
  - Right panel (flexible): Selected chat messages or empty state

#### 3. **home_controller.dart** (Modified)
- Added `selectedChat` observable to track selected chat in desktop mode
- Added `isDesktopLayout` observable to track current layout mode
- Modified `openChat()` method:
  - Desktop mode: Updates `selectedChat` to show in right panel
  - Mobile mode: Navigates to separate chat screen
- Added `closeChat()` method for desktop mode

#### 4. **home_view.dart** (Modified)
- Wrapped with `ResponsiveLayout` widget
- `_buildMobileLayout()`: Original home screen with bottom navigation
- `_buildDesktopLayout()`: Uses `DesktopChatLayout` for split view
- Updates `isDesktopLayout` flag based on active layout

## User Experience

### Mobile Behavior (< 768px)
- Chat list shown in full screen
- Tapping a chat navigates to separate chat screen
- Back button returns to chat list
- Bottom navigation bar visible

### Desktop/Tablet Behavior (≥ 768px)
- Chat list shown on left (380px width)
- Chat messages shown on right (remaining width)
- Clicking a chat updates the right panel
- Selected chat highlighted with purple tint
- No back button needed (both panels always visible)
- Empty state shown when no chat selected

## Design Features

### Desktop Chat List
- Fixed 380px width
- Scrollable list of chats
- Header with profile, search, and menu
- Selected state with primary color tint
- Unread count badges
- Online status indicators

### Desktop Chat View
- Full-height message area
- Chat header with avatar, name, online status
- Action buttons (video call, voice call, more)
- Scrollable message list
- Message input bar at bottom
- Empty state with helpful message

## Technical Notes

- Uses GetX reactive state management
- Breakpoint detection via `LayoutBuilder` and `MediaQuery`
- Chat controller reinitialized when selecting different chats in desktop mode
- Layout mode detected and stored in controller for conditional logic
- No duplicate code - mobile view reuses existing components

## Testing

To test responsive behavior:
1. Run app in Chrome: `flutter run -d chrome`
2. Resize browser window:
   - Width < 768px → Mobile layout
   - Width ≥ 768px → Desktop split layout
3. Verify:
   - Chat selection works in desktop mode
   - Navigation works in mobile mode
   - Smooth transitions between layouts

## Future Enhancements

Possible improvements:
- Resizable split panel divider
- Tablet-specific layout (different from desktop)
- Animation transitions when selecting chats
- Multi-select mode for desktop
- Keyboard shortcuts for desktop navigation
