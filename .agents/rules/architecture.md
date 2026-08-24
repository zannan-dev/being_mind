# Architecture & State Management

**Architecture Pattern**: Model-View-ViewModel (MVVM)
**State Management**: Vanilla Flutter State Management

## Guidelines
- Follow the **MVVM (Model-View-ViewModel)** architectural pattern strictly.
- **Do not** use external state management libraries (e.g., Provider, Riverpod, GetX, BLoC).
- Rely solely on **Vanilla Flutter State Management**. This includes, but is not limited to:
  - `setState()` for localized ephemeral state.
  - `ChangeNotifier` and `ListenableBuilder` (or `AnimatedBuilder`) for reactive ViewModels.
  - `ValueNotifier` and `ValueListenableBuilder` for simple state updates.
  - `InheritedWidget` or `InheritedNotifier` for dependency injection or propagating state down the widget tree when necessary.

## Implementation Details
- **Model**: Represents the domain data and business logic. Models should be independent of Flutter imports.
- **ViewModel**: Extends `ChangeNotifier`. It acts as the bridge between the View and the Model. It exposes state to the View and handles user intents/actions. Call `notifyListeners()` to update the View.
- **View**: A Flutter `StatelessWidget` or `StatefulWidget` that listens to the ViewModel (e.g., using `ListenableBuilder`) and renders the UI based on its state. The View should be as declarative and logic-free as possible.
