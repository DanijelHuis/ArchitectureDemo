This demo is meant to accompany my CV and provide insight into what kind of architecture I currently use. The focus is on the architecture and testability. 

Overall architecture tries to follow clean architecture, adapted for SwiftUI and state-based unidirectional approach. In the text below I explain everything more detailed.

App is simple RSS reader, it allows user to add RSS feeds and view its contents. It also allows adding favourites.

## UI architecture
I have extensive experience with MVC and MVVM architectures but for this demo I chose simple MVI architecture implementing unidirectional data flow pattern, this is something we used on our last project and it worked very well. Important parts are:
- view is reflection of a state. State is simple struct without any logic. State can contain only finalised formatted data ready to present on the view. This means that View is dependent only on data that it really needs so we can easily make previews and snapshot tests.
- view cannot change state directly, it can send actions (intent) and listen to changes in state. This makes app easier to reason with and more predictable.
- view knows only about state and action, it doesn't need to know concrete view model. This also makes it easy to make previews and snapshot tests.

This architecture has some similarities with architectures like The Composable Architecture (TCA) and Redux - it has state and action and is unidirectional. On the other hand it is very different - it doesn't allow scoping and composing states/reducers and it doesn't have single state for whole app. It is much more similar to MVVM, where view model contains state only for the view.

## Clean architecture & modularisation
I've split the demo app into four layers - Infrastructure, Domain, Data and Presentation. The goals are:
- to restrict dependencies between layers. Lower layers (e.g. Domain) shouldn't know anything about higher layers (e.g. Presentation). Full dependency graph is at the end of this readme. Note the direction of dependencies and injection of protocols.
- define entties and protocols in domain layer and use only those in the app, that way app is far less susceptible to changes in outside world.
- we define use cases to simplify logic and so we can inject only protocols that are needed (interface segregation).
- improve testability by loose coupling (injecting protocols) between layers.

Note that this kind of modularisation won't help much regarding build times or separating work between teams, that is not the purpose of it. Per-feature modularistaion is a better choice if we want that.

## Combine, async/await, AsyncSequence
I use async/await, AsyncSequence, structured concurrency and actor isolation everyhere I can. I very much prefer the top-down readability of async/await (AsyncSequence) code compared to closure based Combine. I also prefer error handling, cancellation propagation and composability of async throwable functions. Combine currently doesn't support actor isolation which is also big downside.

All that said, Combine is still needed if we need multiple subscribers or some advanced operations that AsyncSequence currently doesn't offer. Also, Combine is very convenient to use as data binding for SwiftUI.

## Unit testing, snapshot testing, UI testing
On my previous project we started using snapshot testing alongside unit testing. I find it very powerful and very easy to write. It has already proven its use many times in my previous project, e.g. we found some UI bugs when updating app to iOS 17. All views and components in demo app have snapshot tests.

![ArchitectureDemo](ReadmeResources/snapshot1.png?raw=true "List snapshot tests")

For UI testing I only have experience with Maestro and I find it very easy and intuitive to use. It uses some sort of magic to handle all timings and async events in the app, we don't need to think about it, it just works.

<video src="https://github.com/DanijelHuis/ArchitectureDemo/assets/5382135/8983fe4f-914a-48c1-92f8-c1c53f4fdb7a"></video>

## Coordinator
Demo app uses coordinator pattern to decouple views. I like to inject coordinator into reducer/view model and not call it directly from the view, that way I can test it.

Coordinator in demo app uses one enum split in sub-enums, each sub-enum has its own child coordinator. I have used many approaches in the past, including completely decentralised routes, standard parent-child coordinator and so on. I ended up using completely centrealised coordinator for simplicity and because I like having one function that can open any view in the app. Also having single mock for all unit tests is great. Note that my implementation of Coordinator is not perfect, I am aware of that (AnyView), it is built for ultimate convenience of use.

## SwiftUI
App uses SwiftUI which works very well with unidrectional data flow. Some notes:
- having one cetralised place for fonts, button styles, text styles etc. is very important for achieving consistent UI. Nothing in the app uses strings or numbers, everything has its own enum or style, even spacing and sizings values are defined on one place
- SwiftUI is great for making small components, that is why I separated small components such as ErrorView, TryAgainView, LoadMore etc. and reused them between views.
- views don't depend on concrete stores so we can make mock stores for preview and snapshot testing.

## Dependency injection
I use constructor dependency injection. Previously I've used *Factory* , it is useful and convenient but construction injection works well for this demo.


