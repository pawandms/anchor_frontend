# Responsive Layout Architecture

## State Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Browser Window Resize                        │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│               LayoutBuilder (in HomeView)                        │
│  • Detects constraint changes                                   │
│  • Calculates: isDesktop = width >= 768                         │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│        controller.updateLayoutMode(isDesktop)                    │
│  • Checks if mode actually changed                              │
│  • Updates: isDesktopLayout.value = isDesktop                   │
│  • Clears selectedChat if switching to mobile                   │
│  • Logs: "Layout mode changed to: Desktop/Mobile"               │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│             Obx Widget (Reactive Builder)                        │
│  • Listens to: isDesktopLayout.value                            │
│  • Automatically rebuilds when value changes                    │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
        ┌─────────────────────┐ ┌─────────────────────┐
        │   Mobile Layout     │ │   Desktop Layout    │
        │  (< 768px)          │ │   (>= 768px)        │
        │                     │ │                     │
        │ • Full screen list  │ │ • Split screen      │
        │ • Bottom nav        │ │ • No bottom nav     │
        │ • Navigation mode   │ │ • Panel mode        │
        └─────────────────────┘ └─────────────────────┘
```

## Reactive State Management

```
HomeController (GetX Controller)
├── isDesktopLayout: RxBool (false.obs)
│   └── Observable that triggers UI rebuilds
│
├── selectedChat: Rx<ChatModel?> (null)
│   └── Stores selected chat for desktop mode
│
├── updateLayoutMode(bool isDesktop)
│   ├── Updates isDesktopLayout.value
│   ├── Clears selectedChat when switching to mobile
│   └── Logs mode change
│
└── openChat(ChatModel chat)
    ├── if (isDesktopLayout.value == true)
    │   └── selectedChat.value = chat  // Desktop: Update panel
    │
    └── if (isDesktopLayout.value == false)
        └── Get.toNamed(AppRoutes.chat)  // Mobile: Navigate
```

## Component Hierarchy

```
HomeView (GetView<HomeController>)
│
├── LayoutBuilder
│   ├── Monitors: constraints.maxWidth
│   ├── Calculates: isDesktop = maxWidth >= 768
│   └── Calls: controller.updateLayoutMode(isDesktop)
│
└── Obx (Reactive Builder)
    ├── Observes: controller.isDesktopLayout.value
    │
    ├── Branch 1: Mobile Layout (isDesktopLayout = false)
    │   └── Scaffold
    │       ├── AppBar (with search, menu)
    │       ├── Body: ListView (Chat list)
    │       ├── FloatingActionButton (New chat)
    │       └── BottomNavigationBar (4 tabs)
    │
    └── Branch 2: Desktop Layout (isDesktopLayout = true)
        └── Scaffold
            └── Body: DesktopChatLayout
                └── Row
                    ├── Left Panel (380px)
                    │   ├── Header (Profile, search, menu)
                    │   └── Chat List (scrollable)
                    │       └── Obx: Highlights selectedChat
                    │
                    └── Right Panel (flexible)
                        └── Obx: Observes selectedChat
                            ├── if null: Empty state
                            └── if not null: Chat content
                                ├── Chat header
                                ├── Messages list
                                └── Input bar
```

## User Interaction Flows

### Desktop Mode: Select Chat
```
User clicks chat in list
    ↓
ChatListTile.onTap()
    ↓
controller.openChat(chat)
    ↓
Check: isDesktopLayout.value == true
    ↓
selectedChat.value = chat  (Update observable)
    ↓
Obx in right panel detects change
    ↓
Rebuilds right panel with chat content
    ↓
ChatController initialized with selected chat
    ↓
Messages loaded and displayed
```

### Mobile Mode: Select Chat
```
User clicks chat in list
    ↓
ChatListTile.onTap()
    ↓
controller.openChat(chat)
    ↓
Check: isDesktopLayout.value == false
    ↓
Get.toNamed(AppRoutes.chat, arguments: chat)
    ↓
Navigate to new screen
    ↓
ChatBinding creates ChatController
    ↓
ChatController.onInit() reads Get.arguments
    ↓
Messages loaded and displayed
```

### Window Resize: Desktop → Mobile
```
User resizes browser window to < 768px
    ↓
LayoutBuilder detects constraint change
    ↓
Calculates: isDesktop = false
    ↓
controller.updateLayoutMode(false)
    ↓
isDesktopLayout.value = false
selectedChat.value = null  (Clear selection)
    ↓
Obx in HomeView detects change
    ↓
Rebuilds with mobile layout
    ↓
Shows chat list with bottom navigation
```

### Window Resize: Mobile → Desktop
```
User resizes browser window to >= 768px
    ↓
LayoutBuilder detects constraint change
    ↓
Calculates: isDesktop = true
    ↓
controller.updateLayoutMode(true)
    ↓
isDesktopLayout.value = true
    ↓
Obx in HomeView detects change
    ↓
Rebuilds with desktop layout
    ↓
Shows split-screen with empty right panel
```

## GetX Reactive Patterns Used

### 1. Observable State (.obs)
```dart
final isDesktopLayout = false.obs;
// Creates reactive boolean that triggers rebuilds
```

### 2. Reactive Type (Rx<T>)
```dart
final selectedChat = Rx<ChatModel?>(null);
// Nullable observable for complex types
```

### 3. Obx Widget
```dart
Obx(() {
  return controller.isDesktopLayout.value 
      ? DesktopLayout() 
      : MobileLayout();
})
// Automatically rebuilds when observables change
```

### 4. GetView<T>
```dart
class HomeView extends GetView<HomeController> {
  // Automatically gets controller instance
  // Access via: controller.property
}
```

## Performance Optimizations

### 1. Conditional Update
```dart
if (isDesktopLayout.value != isDesktop) {
  // Only update if actually changed
  isDesktopLayout.value = isDesktop;
}
```

### 2. Selective Rebuilds
- Only Obx widgets rebuild, not entire tree
- LayoutBuilder only rebuilds on constraint changes
- Chat list items rebuild individually on selection

### 3. Controller Lifecycle
```dart
Get.delete<ChatController>();  // Clean up old controller
Get.put(ChatController(), permanent: false);  // Create new one
```

## Breakpoint Strategy

```
Width Range         Layout Mode      Behavior
─────────────────────────────────────────────────────────
0px - 767px         Mobile          Separate screens
768px - 1199px      Desktop         Split-screen (tablet)
1200px+             Desktop         Split-screen (desktop)

Breakpoint at 768px:
- Aligns with common tablet sizes
- Provides enough space for split view
- Matches WhatsApp Web behavior
```

## State Synchronization

```
Window Width → LayoutBuilder → updateLayoutMode() → isDesktopLayout.obs
                                                            ↓
                                    ┌───────────────────────┴────────────────────────┐
                                    ↓                                                ↓
                            Obx in HomeView                                  openChat() logic
                         (Switches layout)                              (Navigation vs Selection)
                                    ↓                                                ↓
                        UI updates immediately                          Correct action taken
```

## Key Benefits

1. ✅ **Real-time Reactivity**: Window resize immediately updates layout
2. ✅ **Clean State Management**: Single source of truth in controller
3. ✅ **Automatic UI Updates**: Obx handles rebuilds automatically
4. ✅ **Type Safety**: GetX provides compile-time type checking
5. ✅ **Memory Efficient**: Only rebuilds affected widgets
6. ✅ **Testable**: Controller logic separated from UI
7. ✅ **Maintainable**: Clear separation of concerns
8. ✅ **Performant**: Minimal rebuilds, efficient updates
