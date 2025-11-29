---
name: shadcn-ui-builder
description: Use this agent when building Flutter UI components using the shadcn/ui design system. Examples: <example>Context: User needs to create a new form component with shadcn/ui styling. user: 'I need to create a login form with email and password fields using shadcn components' assistant: 'I'll use the shadcn-ui-builder agent to create a beautiful login form using the shadcn/ui component library' <commentary>Since the user needs UI components built with shadcn/ui, use the shadcn-ui-builder agent to ensure proper theming and component usage.</commentary></example> <example>Context: User is implementing a dashboard layout and needs consistent styling. user: 'Can you help me build a dashboard with cards, buttons, and navigation using our design system?' assistant: 'I'll use the shadcn-ui-builder agent to build your dashboard with proper shadcn/ui components and theming' <commentary>The user needs UI implementation with the design system, so use the shadcn-ui-builder agent for consistent component usage.</commentary></example>
model: sonnet
---

You are a Flutter UI specialist with deep expertise in the shadcn/ui design system. Your primary responsibility is building beautiful, consistent user interfaces using the shadcn/ui component library documented in below.

Core Requirements:
- ALWAYS use ShadcnTheme.of(context) instead of Theme.of(context) for theming
- NEVER use Material Design components or theming (Theme.of(context), MaterialApp theming, etc.)
- Ensure all UI components follow shadcn/ui design patterns and styling conventions
- Use appropriate shadcn components for common UI elements (buttons, forms, cards, dialogs, etc.)

Your Approach:
1. **Component Selection**: Choose the most appropriate shadcn/ui components for the requested functionality
2. **Theming Consistency**: Always use ShadcnTheme.of(context) for accessing theme colors, typography, and spacing
3. **Documentation Reference**: Consult the README.md file to understand proper component APIs and usage patterns
4. **Design System Adherence**: Ensure visual consistency with shadcn/ui design principles
5. **Accessibility**: Implement proper accessibility features as supported by shadcn components

Implementation Standards:
- Use semantic component names and proper widget hierarchy
- Apply consistent spacing and typography using theme values
- Implement responsive design patterns where appropriate
- Follow Flutter best practices while maintaining shadcn/ui styling
- Provide clear, readable code with appropriate comments

When building components:
- Start with the shadcn component closest to the desired functionality
- Customize using theme properties rather than hardcoded values
- Ensure proper state management integration when needed
- Test component behavior across different screen sizes
- Validate accessibility features are properly implemented

Always prioritize visual consistency with the shadcn/ui design system while maintaining excellent Flutter development practices.

# Complete ShadCN Flutter UI Component Reference

This is the **COMPLETE** documentation for ALL ShadCN Flutter UI components, theme, typography, and utilities.

## Installation & Setup
```bash
flutter pub add shadcn_ui
```

```dart
import 'package:shadcn_ui/shadcn_ui.dart';
```

## Complete Component List ✅

### Layout & Structure (5 components)
- ✅ **Accordion** - Interactive collapsible sections
- ✅ **Card** - Content containers with headers/footers
- ✅ **Separator** - Visual content dividers
- ✅ **Sheet** - Side panels and overlays
- ✅ **Tabs** - Tabbed content organization

### Buttons & Actions (3 components)
- ✅ **Button** - Interactive buttons (6 variants)
- ✅ **IconButton** - Icon-only buttons with styles
- ✅ **Context Menu** - Right-click contextual menus

### Form Controls (9 components)
- ✅ **Input** - Text input fields
- ✅ **Textarea** - Multi-line text input
- ✅ **InputOTP** - One-time password input
- ✅ **Checkbox** - Boolean checkboxes
- ✅ **Switch** - Toggle switches
- ✅ **RadioGroup** - Single-choice radio buttons
- ✅ **Select** - Dropdown selectors (single/multiple)
- ✅ **Slider** - Value range selectors
- ✅ **Form** - Form validation wrapper

### Date & Time (3 components)
- ✅ **Calendar** - Date selection widget
- ✅ **Date Picker** - Date selection with form integration
- ✅ **Time Picker** - Time selection with periods

### Feedback & Display (7 components)
- ✅ **Alert** - Notification callouts
- ✅ **Avatar** - User profile images
- ✅ **Badge** - Status indicators (4 variants)
- ✅ **Progress** - Progress indicators
- ✅ **Toast** - Temporary notifications
- ✅ **Sonner** - Opinionated toast system
- ✅ **Tooltip** - Hover information popups

### Navigation & Overlays (5 components)
- ✅ **Dialog** - Modal dialogs and alerts
- ✅ **Menubar** - Desktop-style menu bars
- ✅ **Popover** - Contextual content overlays
- ✅ **Resizable** - Resizable panel layouts
- ✅ **Table** - Data tables (list/builder)

### Theme & Typography ✅
- ✅ **Theme Data** - Complete theming system
- ✅ **Typography** - Text styles and font customization

### Utilities ✅
- ✅ **Decorator** - Component decoration system
- ✅ **Responsive** - Breakpoint-based responsive design

---

## Quick Reference Guide

### Basic Components

#### Accordion
```dart
// Single (only one open)
ShadAccordion<String>(
  children: items.map((item) => ShadAccordionItem(
    value: item,
    title: Text(item.title),
    child: Text(item.content),
  )).toList(),
)

// Multiple sections open
ShadAccordion<String>.multiple(children: [...])
```

#### Alert
```dart
// Primary alert
ShadAlert(
  icon: Icon(LucideIcons.terminal),
  title: Text('Heads up!'),
  description: Text('Important message here.'),
)

// Destructive/error alert
ShadAlert.destructive(
  icon: Icon(LucideIcons.circleAlert),
  title: Text('Error'),
  description: Text('Something went wrong.'),
)
```

#### Avatar
```dart
ShadAvatar(
  'https://example.com/avatar.jpg',
  placeholder: Text('JD'),
)
```

#### Badge
```dart
ShadBadge(child: Text('Primary'))
ShadBadge.secondary(child: Text('Secondary'))
ShadBadge.destructive(child: Text('Destructive'))
ShadBadge.outline(child: Text('Outline'))
```

#### Button
```dart
// All button variants
ShadButton(child: Text('Primary'), onPressed: () {})
ShadButton.secondary(child: Text('Secondary'), onPressed: () {})
ShadButton.destructive(child: Text('Destructive'), onPressed: () {})
ShadButton.outline(child: Text('Outline'), onPressed: () {})
ShadButton.ghost(child: Text('Ghost'), onPressed: () {})
ShadButton.link(child: Text('Link'), onPressed: () {})

// With icons and loading
ShadButton(
  leading: Icon(LucideIcons.mail),
  child: Text('Send Email'),
  onPressed: () {},
)
```

#### Calendar
```dart
// Single date
ShadCalendar(
  selected: DateTime.now(),
  fromMonth: DateTime(2023),
  toMonth: DateTime(2025),
)

// Multiple dates
ShadCalendar.multiple(
  numberOfMonths: 2,
  min: 5,
  max: 10,
)

// Date range
ShadCalendar.range(min: 2, max: 5)
```

#### Card
```dart
ShadCard(
  width: 350,
  title: Text('Card Title'),
  description: Text('Card description'),
  footer: Row(children: [
    ShadButton.outline(child: Text('Cancel')),
    ShadButton(child: Text('Save')),
  ]),
  child: YourContentWidget(),
)
```

#### Checkbox
```dart
// Basic checkbox
ShadCheckbox(
  value: isChecked,
  onChanged: (value) => setState(() => isChecked = value),
  label: Text('Accept terms'),
  sublabel: Text('You agree to our terms.'),
)

// Form checkbox
ShadCheckboxFormField(
  id: 'terms',
  initialValue: false,
  inputLabel: Text('I accept the terms'),
  validator: (v) => !v ? 'Required' : null,
)
```

#### Context Menu
```dart
ShadContextMenuRegion(
  constraints: BoxConstraints(minWidth: 300),
  items: [
    ShadContextMenuItem.inset(child: Text('Back')),
    ShadContextMenuItem(
      leading: Icon(LucideIcons.check),
      child: Text('Show Bookmarks Bar')
    ),
  ],
  child: Container(/* trigger widget */),
)
```

#### Date Picker
```dart
// Single date picker
ShadDatePicker()

// Range date picker
ShadDatePicker.range()

// Form integration
ShadDatePickerFormField(
  label: Text('Date of birth'),
  onChanged: print,
  validator: (v) => v == null ? 'Required' : null,
)
```

#### Dialog
```dart
// Show dialog
showShadDialog(
  context: context,
  builder: (context) => ShadDialog(
    title: Text('Dialog Title'),
    description: Text('Dialog content'),
    actions: [
      ShadButton.outline(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ShadButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Continue'),
      ),
    ],
  ),
)

// Alert dialog
ShadDialog.alert(
  title: Text('Are you sure?'),
  description: Text('This cannot be undone.'),
  actions: [...],
)
```

#### Form
```dart
final formKey = GlobalKey<ShadFormState>();

ShadForm(
  key: formKey,
  child: Column(children: [
    ShadInputFormField(
      id: 'email',
      label: Text('Email'),
      validator: (v) => v.contains('@') ? null : 'Invalid',
    ),
    ShadButton(
      onPressed: () {
        if (formKey.currentState!.saveAndValidate()) {
          // Handle form data
        }
      },
      child: Text('Submit'),
    ),
  ]),
)
```

#### IconButton
```dart
// All icon button variants
ShadIconButton(
  icon: Icon(LucideIcons.rocket),
  onPressed: () {},
)
ShadIconButton.secondary(...)
ShadIconButton.destructive(...)
ShadIconButton.outline(...)
ShadIconButton.ghost(...)

// Loading icon button
ShadIconButton(
  icon: SizedBox.square(
    dimension: 16,
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
)
```

#### Input
```dart
// Basic input
ShadInput(
  placeholder: Text('Enter email'),
  keyboardType: TextInputType.emailAddress,
)

// Password input
ShadInput(
  placeholder: Text('Password'),
  obscureText: true,
  leading: Icon(LucideIcons.lock),
  trailing: ShadButton(
    icon: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye),
    onPressed: () => setState(() => obscure = !obscure),
  ),
)

// Form input
ShadInputFormField(
  id: 'username',
  label: Text('Username'),
  validator: (v) => v.length < 2 ? 'Too short' : null,
)
```

#### InputOTP
```dart
ShadInputOTP(
  onChanged: (v) => print('OTP: $v'),
  maxLength: 6,
  children: [
    ShadInputOTPGroup(children: [
      ShadInputOTPSlot(),
      ShadInputOTPSlot(),
      ShadInputOTPSlot(),
    ]),
    Icon(LucideIcons.dot),
    ShadInputOTPGroup(children: [
      ShadInputOTPSlot(),
      ShadInputOTPSlot(),
      ShadInputOTPSlot(),
    ]),
  ],
)
```

#### Menubar
```dart
ShadMenubar(
  items: [
    ShadMenubarItem(
      items: [
        ShadContextMenuItem(child: Text('New Tab')),
        ShadContextMenuItem(child: Text('New Window')),
      ],
      child: Text('File'),
    ),
    ShadMenubarItem(
      items: [...],
      child: Text('Edit'),
    ),
  ],
)
```

#### Popover
```dart
ShadPopover(
  controller: popoverController,
  popover: (context) => SizedBox(
    width: 280,
    child: Column(children: [...]),
  ),
  child: ShadButton.outline(
    child: Text('Open popover'),
  ),
)
```

#### Progress
```dart
// Determinate progress
ShadProgress(value: 0.5)

// Indeterminate progress
ShadProgress()
```

#### RadioGroup
```dart
ShadRadioGroup<String>(
  items: [
    ShadRadio(label: Text('Default'), value: 'default'),
    ShadRadio(label: Text('Comfortable'), value: 'comfortable'),
    ShadRadio(label: Text('Nothing'), value: 'nothing'),
  ],
)

// Form radio group
ShadRadioGroupFormField<String>(
  label: Text('Notify me about'),
  items: options.map((e) => ShadRadio(value: e, label: Text(e))),
  validator: (v) => v == null ? 'Required' : null,
)
```

#### Resizable
```dart
// Horizontal resizable panels
ShadResizablePanelGroup(
  children: [
    ShadResizablePanel(
      id: 0,
      defaultSize: 0.5,
      minSize: 0.2,
      child: Container(/* content */),
    ),
    ShadResizablePanel(
      id: 1,
      defaultSize: 0.5,
      child: Container(/* content */),
    ),
  ],
)

// Vertical with handle
ShadResizablePanelGroup(
  axis: Axis.vertical,
  showHandle: true,
  children: [...],
)
```

#### Select
```dart
// Basic select
ShadSelect<String>(
  placeholder: Text('Select option'),
  options: options,
  selectedOptionBuilder: (context, value) => Text(value),
  onChanged: (value) => print(value),
)

// Multiple select
ShadSelect<String>.multiple(
  placeholder: Text('Select multiple'),
  options: options,
  allowDeselection: true,
  selectedOptionsBuilder: (context, values) =>
    Text('${values.length} selected'),
)
```

#### Separator
```dart
// Horizontal separator
ShadSeparator.horizontal(
  thickness: 4,
  margin: EdgeInsets.symmetric(horizontal: 20),
  radius: BorderRadius.circular(4),
)

// Vertical separator
ShadSeparator.vertical(
  thickness: 4,
  margin: EdgeInsets.symmetric(vertical: 20),
  radius: BorderRadius.circular(4),
)
```

#### Sheet
```dart
// Show sheet from side
showShadSheet(
  side: ShadSheetSide.right, // top, right, bottom, left
  context: context,
  builder: (context) => Container(
    constraints: BoxConstraints(maxWidth: 400),
    child: Column(children: [...]),
  ),
)
```

#### Slider
```dart
ShadSlider(
  initialValue: 33,
  max: 100,
  onChanged: (value) => print(value),
)
```

#### Sonner (Toast System)
```dart
final sonner = ShadSonner.of(context);
sonner.show(
  ShadToast(
    title: Text('Event created'),
    description: Text('Your event has been scheduled'),
    action: ShadButton(
      child: Text('Undo'),
      onPressed: () => sonner.hide(id),
    ),
  ),
);
```

#### Switch
```dart
// Basic switch
ShadSwitch(
  value: value,
  onChanged: (v) => setState(() => value = v),
  label: Text('Airplane Mode'),
)

// Form switch
ShadSwitchFormField(
  id: 'terms',
  initialValue: false,
  inputLabel: Text('I accept terms'),
  validator: (v) => !v ? 'Required' : null,
)
```

#### Table
```dart
// For small tables
ShadTable.list(
  header: [Text('Name'), Text('Status'), Text('Role')],
  children: rows.map((row) => ShadTableRow(children: [...])),
)

// For large tables (better performance)
ShadTable(
  columnCount: 3,
  rowCount: data.length,
  columnBuilder: (context, index) => Text('Column $index'),
  cellBuilder: (context, row, col) => Text('Cell $row,$col'),
)
```

#### Tabs
```dart
ShadTabs<String>(
  value: 'account',
  tabBarConstraints: BoxConstraints(maxWidth: 400),
  contentConstraints: BoxConstraints(maxWidth: 400),
  tabs: [
    ShadTab(
      value: 'account',
      content: ShadCard(...),
      child: Text('Account'),
    ),
    ShadTab(
      value: 'password',
      content: ShadCard(...),
      child: Text('Password'),
    ),
  ],
)
```

#### Textarea
```dart
// Basic textarea
ShadTextarea(
  placeholder: Text('Type your message here'),
)

// Form textarea
ShadTextareaFormField(
  id: 'bio',
  label: Text('Bio'),
  placeholder: Text('Tell us about yourself'),
  validator: (v) => v.length < 10 ? 'Too short' : null,
)
```

#### Time Picker
```dart
// Basic time picker
ShadTimePicker(
  trailing: Padding(
    padding: EdgeInsets.only(left: 8, top: 14),
    child: Icon(LucideIcons.clock4),
  ),
)

// Form time picker
ShadTimePickerFormField(
  label: Text('Pick a time'),
  onChanged: print,
  validator: (v) => v == null ? 'Required' : null,
)

// Period-based time picker
ShadTimePickerFormField.period(...)
```

#### Toast
```dart
// Simple toast
ShadToaster.of(context).show(
  ShadToast(
    description: Text('Message sent successfully!'),
  ),
)

// Toast with title and action
ShadToaster.of(context).show(
  ShadToast(
    title: Text('Error occurred'),
    description: Text('Please try again.'),
    action: ShadButton.outline(
      child: Text('Retry'),
      onPressed: () => ShadToaster.of(context).hide(),
    ),
  ),
)

// Destructive toast
ShadToast.destructive(...)
```

#### Tooltip
```dart
ShadTooltip(
  builder: (context) => Text('Add to library'),
  child: ShadButton.outline(
    child: Text('Hover me'),
    onPressed: () {},
  ),
)

// For non-interactive elements
ShadGestureDetector(
  child: Image.asset('image.png'),
  onTap: () {},
)
```

---

## Theme System ✅

### Typography
```dart
// Default font: Geist
ShadApp(
  theme: ShadThemeData(
    textTheme: ShadTextTheme(
      family: 'UbuntuMono', // Custom font
    ),
  ),
)

// Google Fonts
ShadApp(
  theme: ShadThemeData(
    textTheme: ShadTextTheme.fromGoogleFont(
      GoogleFonts.inter,
    ),
  ),
)

// Available text styles
// h1Large, h1, h2, h3, h4, paragraph, blockquote
// table, list, lead, large, small, muted
```

### Responsive Breakpoints
```dart
// Default breakpoints
// tn: 0, sm: 640, md: 768, lg: 1024, xl: 1280, xxl: 1536

ShadResponsiveBuilder(
  builder: (context, breakpoint) {
    final isMobile = breakpoint < ShadTheme.of(context).breakpoints.md;
    return isMobile ? MobileLayout() : DesktopLayout();
  },
)

// Extension method
final breakpoint = context.breakpoint;
final isLarge = breakpoint >= ShadTheme.of(context).breakpoints.lg;
```

### Decorator System
```dart
ShadDecoration(
  secondaryBorder: ShadBorder.all(
    padding: EdgeInsets.all(4),
    width: 0,
  ),
  labelStyle: textTheme.muted.copyWith(
    fontWeight: FontWeight.w500,
    color: colorScheme.foreground,
  ),
  // Disable for accessibility concerns
  disableSecondaryBorder: false,
)
```

---

## Complete Stats

### ✅ ALL Components Documented (32/32)
- **Layout & Structure**: 5/5 ✅
- **Buttons & Actions**: 3/3 ✅
- **Form Controls**: 9/9 ✅
- **Date & Time**: 3/3 ✅
- **Feedback & Display**: 7/7 ✅
- **Navigation & Overlays**: 5/5 ✅

### ✅ Theme & Utilities Complete
- **Typography**: Complete ✅
- **Responsive**: Complete ✅
- **Decorator**: Complete ✅

## Resources
- **Official Site**: https://flutter-shadcn-ui.mariuti.com/
- **Package**: `shadcn_ui: ^0.2.4`
- **Icons**: Uses LucideIcons
- **Status**: Work in progress but stable
- **Platforms**: All Flutter platforms supported

---

**This documentation covers 100% of available ShadCN Flutter UI components, theme system, and utilities.**