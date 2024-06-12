This demo is meant to accompany my CV and provide insight into my code and how I structure and test apps. 

Demo app uses principles from clean architecture for model part. For UI part, same code is implemented in MVVM and MVI architectures (I will add TCA implementation in near future). There are two packages:
- PresentationMVI: Unidirectional state-action based MVI implementation adapted for SwiftUI and easy previews/snapshot testing.
- PresentationMVVM: Classic MVVM used in iOS. This uses new @Observable so this is available only on iOS 17.
To switch between UI implementations, open RSSCoordinator.swift and specify "import PresentationMVI" or "import PresentationMVVM".

The app is a simple RSS reader, it allows users to add RSS feeds and view their contents. It also allows for adding favorites.

## MVVM vs. MVI vs. TCA
I've summarized all the differences between architectures and put it into table below. Note that this comparison focuses on UI sides of these architecutres.
![architecture_comparison](https://github.com/DanijelHuis/ArchitectureDemo/assets/5382135/3562f072-14a8-422a-921a-7a93f60f9bd0)

## Clean architecture & modularization
I've split the demo app into multiple layers: infrastructure, domain, data, and presentation. The goals are:
- to restrict dependencies between layers. Lower layers (e.g. domain) shouldn't know anything about higher layers (e.g. presentation).
- define entities and protocols in domain layer and use only those in the app, that way app is far less susceptible to changes in the outside world.
- we define use cases to simplify logic, so we can inject only protocols that are needed (interface segregation).
- improve testability by loose coupling (injecting protocols) between layers.

Note that this kind of modularization won't help much regarding build times or separating work between teams, that is not the purpose of it. Per-feature modularization is a better choice if we want that.

## Combine, async/await, asyncSequence
I use async/await, async sequence, structured concurrency and actor isolation everywhere I can. I very much prefer the top-down readability of async/await (AsyncSequence) code compared to closure-based combine. I also prefer error handling, cancellation propagation and the composability of async throwable functions. Combine currently doesn't support actor isolation which is also a big downside.

All that said, Combine is still needed if we need multiple subscribers or some advanced operations that AsyncSequence currently doesn't offer. Also, Combine is very convenient to use as data binding for SwiftUI.

## Unit testing, snapshot testing, UI testing
On my previous project, we started using snapshot testing alongside unit testing. I find it very powerful and very easy to write. It has already proven its use many times in my previous project, e.g. we found some UI bugs when updating app to iOS 17. All views and components in the demo app have snapshot tests. Below is an example of snapshot tests for RSS list in all 4 states (loading, empty, loaded, error).

![snapshot_tests](https://github.com/DanijelHuis/ArchitectureDemo/blob/master/ReadmeResources/snapshot1.png)

For UI testing I used Maestro. I find it very easy and intuitive to use. It uses some sort of magic to handle all timings and async events in the app, we don't need to think about it - it just works.

<video src="https://github.com/DanijelHuis/ArchitectureDemo/assets/5382135/3018304e-d2db-45fd-8f59-0bfcc5d62ce5"></video>

## Coordinator
The demo app uses a coordinator pattern to decouple views. I like to inject the coordinator into the view model and not call it directly from the view, that way I can test it.

The coordinator in the demo app uses one enum split into sub-enums, each sub-enum has its own child coordinator. I have used many approaches in the past, including completely decentralized routes, standard parent-child coordinator and so on. I ended up using a centralized coordinator for simplicity and because I like having one function that can open any view in the app. Also, having a single mock for all unit tests is great. Note that my implementation of Coordinator is not perfect, I am aware of that (AnyView), it is built for ultimate convenience of use.

## SwiftUI
The app uses SwiftUI which works very well with unidrectional data flow. Some notes:
- having one central place for fonts, button styles, text styles etc. is very important for achieving consistent UI. Nothing in the app uses strings or numbers, everything has its own enum or style, even spacing and sizing values are defined on one place
- SwiftUI is great for making small components, which is why I separated small components such as ErrorView, TryAgainView, LoadMore etc. and reused them between views.
- views don't depend on concrete view models so we can make mock view models for preview and snapshot testing.

## Dependency injection
I use constructor dependency injection. Previously I've used *Factory* , it is useful and convenient but construction injection works well for this demo.
