# Architecture Rules

## Overview

This application aims to be a sample app for showing MVVM pattern for Flutter app.

## What is MVVM?

MVVM is one of the design patterns that separates the UI from the business logic of the application.

Though this pattern is familiar to the developers who have experiences in the web/mobile development, it was originally introduced from the development on Windows, and MVVM is supposed to be used with WPF, not Flutter.

So, this application doesn't strictly follow MVVM which Microsoft introduced in the article below.

[https://learn.microsoft.com/en-us/dotnet/architecture/maui/mvvm](https://learn.microsoft.com/en-us/dotnet/architecture/maui/mvvm)

However, as the original idea of MVVM is "Presentation Model", which was introduced by Martin Fowler, this application tries to refer to this and implement it with Flutter.

Note that in this application, we call "Presentation Model" as "ViewModel" for convenience.

## Rules

MVVM consists of three parts: Model, ViewModel(Presentation Model), and View.

Each part follows the rules below.

### Model

Model represents "business logic" of the application, which is always implemented in pure Dart code.

Model is independent from the View, and ViewModel, meaning it doesn't have any dependencies on the View or ViewModel classes.

Because Model and its preserving data can be referenced by multiple ViewModel, it "notifies" the change of the data to the ViewModel using `Stream` with broadcast mode.

Model classes are defined in the `lib/model` directory.

### View

View represents the UI of the application, and it is implemented with Flutter widgets.

View always refers to the corresponding ViewModel class, and View can't refers directly to the Model classes.

View classes are defined in the `lib/view` directory.

### ViewModel

ViewModel represents the "presentation logic" of the application, and it is implemented with pure Dart code.

ViewModel has three main responsibilities stated below:

1. Communicate with the Model
1. Generate the exact data for the corresponding View
1. Synchronize the data with the corresponding View

ViewModel potentially has multiple references to the Model classes, while it only has one reference to the View.

Because we are developing Flutter app, synchronization between View and ViewModel doesn't require any special tricks, but ordinal mechanism prepared by Flutter, such as `ValueNotifier` and `ValueListenableBuilder`.

For robust data management, ViewModel preserves only one object for View's state named `ViewState`.

ViewModel classes are defined in the `lib/view_model` directory.

The typical implementation of ViewModel is as follows:

1. Define the `ViewState` class
1. Define the `ViewModel` class extending `ValueNotifier<ViewState>`

For example, if we are developing a simple counter app, the ViewModel class would be like the following:

```dart
class CounterViewState {
  CounterViewState({required this.count});

  final int count;
}

class CounterViewModel extends ValueNotifier<CounterViewState> {
  CounterViewModel(this.model) : super(CounterViewState(count: 0)) {
    model.stateStream.listen((state) {
      value = state;
    });
  }

  final CounterModel model;

  void increment() {
    model.increment();
  }
}
```

### Storage

In addition to each parts of MVVM, this application hires "on memory storage" where model classes store and fetch data.

This part is a replacement of the database, such like Firestore, Supabase, or Web API.

Storage classes are defined in the `lib/storage` directory.
