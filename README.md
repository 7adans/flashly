# ⚡ Flashly

**Native-feeling toasts, alerts and loaders for Flutter, called in one line from anywhere in your app. No `BuildContext` plumbing.**

Every app I've shipped needed the same three things: a toast after an action, a confirmation dialog before a destructive one, and a blocking loader while a request runs. Each project ended up re-implementing them slightly differently, with context passed through five layers just to show a snackbar.

Flashly packages the version I use in production: one global navigator key, platform-adaptive styling (Cupertino on iOS, Material on Android), Lottie-animated states, and optional haptics.

```dart
showToast('Order placed', state: ToastState.success, enableHaptics: true);
```

## ✨ Features

- 🍞 **Animated toasts**: spring slide-in, auto-dismiss, success / info / error states, rich (two-style) text
- 💬 **Alerts & confirmations**: Lottie-animated success / error / warning / info, async `onPositive` callbacks, destructive styling
- ⏳ **Loaders**: blocking loader dialog with a fail-safe close button, timed loader, and an adaptive inline spinner
- 📳 **Haptics**: light / medium / heavy / vibrate, opt-in per call
- 🍏🤖 **Platform-adaptive**: Cupertino buttons and translucency on iOS, Material on Android
- 🌍 **Context-free**: call from BLoCs, controllers or services via `Flashly.navigatorKey`

## 🚀 Getting started

Flashly isn't on pub.dev yet. Add it from Git:

```yaml
dependencies:
  flashly:
    git:
      url: https://github.com/7adans/flashly.git
```

Register the navigator key once:

```dart
MaterialApp(
  navigatorKey: Flashly.navigatorKey,
  home: const HomePage(),
);
```

## 📖 Usage

### Toast

```dart
showToast('Saved');
showToast('Payment failed', state: ToastState.error, enableHaptics: true);
showToast('Signed in as ', richMessage: 'ladans', duration: const Duration(seconds: 4));
```

### Alert / confirmation

```dart
await showAlert(
  'Delete address?',
  description: 'This cannot be undone.',
  state: AlertState.warning,
  isDestructive: true,
  negativeTitle: 'Cancel',
  positiveTitle: 'Delete',
  onPositive: () async => repository.deleteAddress(id),
);
```

### Loader

```dart
showLoaderAlert(placeholder: 'Placing order');   // shows a close button after 45s as a fail-safe
await api.placeOrder();
closeLoaderAlert();

// Inline adaptive spinner
loader(size: 24, color: Colors.white);
```

### Haptics & press effect

```dart
haptics(impact: HapticImpact.light);

PressEffect(
  onPressed: onTap,
  child: const Card(child: Text('Tap me')),
);
```

## 🧱 Design decisions

- **Overlay-based toasts** are inserted into the navigator's `Overlay`, so they survive route changes and never fight with `ScaffoldMessenger`.
- **A global `GlobalKey<NavigatorState>`** keeps UI feedback callable from the presentation-logic layer (BLoC/Cubit/ViewModel) without leaking `BuildContext` into it.
- **Lottie assets ship with the package** (`package: 'flashly'`), so consumers don't need to configure any assets.

## 🗺️ Roadmap

- [ ] Localizable default button labels
- [ ] Widget tests + golden tests
- [ ] Example app with GIFs
- [ ] Publish to pub.dev

## 📄 License

MIT © Ladino Anselmo
