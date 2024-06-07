This demo is meant to accompany my CV and provide insight into my code and how I structure apps. 

Demo app uses clean architecture for model part. UI architecture is done in 3 ways:
- MVVM (Model-View-ViewModel) [NOT YET IMPLEMENTED]
- MVI (Model-View-Intent) 
- TCA (The Composable Architecture) [NOT YET IMPLEMENTED]

The app is a simple RSS reader, it allows users to add RSS feeds and view their contents. It also allows for adding favorites.

## MVI
My version of Intent is basically a view model that is adapted for state, action and unidirectional flow. Note that I use view model naming in the demo app because it is more familiar to iOS world. We used this architecture on our last project and it worked very well. Key points are:
- instead of separate reactive properties, view model has one reactive state.
- instead of multiple functions, view model has only one send(action) function which takes action enum.
- view is a reflection of a state. 
- view cannot change state directly, it can send actions (intents) and listen to changes in state. This makes the app easier to reason with and more predictable.
- view knows only about state and action, it doesn't need to know concrete view model. This makes it easy to make previews and snapshot tests.

This architecture has some similarities with The Composable Architecture (TCA) and Redux/Elm/Flux - it has state and action and it is unidirectional. On the other hand it is very different - it doesn't allow scoping and composing states/reducers and it doesn't have single state for the whole app. Also, MVI is not as predictable as TCA, state can be changed from anywhere in the view model (compared to state being mutated only by reduce function in TCA). Also, there is no separation between store and reducer, view model acts as both.

## Clean architecture & modularization
I've split the demo app into four layers: infrastructure, domain, data, and presentation. The goals are:
- to restrict dependencies between layers. Lower layers (e.g. domain) shouldn't know anything about higher layers (e.g. presentation).
- define entities and protocols in domain layer and use only those in the app, that way app is far less susceptible to changes in the outside world.
- we define use cases to simplify logic, so we can inject only protocols that are needed (interface segregation).
- improve testability by loose coupling (injecting protocols) between layers.

Note that this kind of modularization won't help much regarding build times or separating work between teams, that is not the purpose of it. Per-feature modularization is a better choice if we want that.

## Combine, async/await, asyncSequence
I use async/await, async sequence, structured concurrency and actor isolation everywhere I can. I very much prefer the top-down readability of async/await (AsyncSequence) code compared to closure-based combine. I also prefer error handling, cancellation propagation and the composability of async throwable functions. Combine currently doesn't support actor isolation which is also a big downside.

All that said, Combine is still needed if we need multiple subscribers or some advanced operations that AsyncSequence currently doesn't offer. Also, Combine is very convenient to use as data binding for SwiftUI.

## Unit testing, snapshot testing, UI testing
On my previous project, we started using snapshot testing alongside unit testing. I find it very powerful and very easy to write. It has already proven its use many times in my previous project, e.g. we found some UI bugs when updating app to iOS 17. All views and components in the demo app have snapshot tests.

![ArchitectureDemo](ReadmeResources/snapshot1.png?raw=true "List snapshot tests")

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
