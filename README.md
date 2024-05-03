This demo is meant to accompany my CV and provide insight into what kind of architecture I currently use or I am simply interested in.

App uses PokeAPI to fetch list of pokemons and present details.

## UI architecture
Unidirection data flow is definitely my choice when it comes to SwiftUI. There are many flavours of it, the main characteristics that I like are:
- view is reflection of a state. State is simple struct without any logic.
- view cannot change state directly, it can send actions and listen to changes in state (unidirectional).
- view knows only about state and action, it doesn't need to know concrete view model / store. This makes it easy to make previews and snapshot tests.

The nearest implementation of this for Swift is The Composable Architecture which is inspired by Redux/Elm. These architectures have shared state for whole app, that is great but I prefer to have isolated state for each view because it simplifies whole architecture and avoids many problems (scoping state and reducer etc.). For demo purposes app uses custom implementation of unidirectional data flow pattern.

## Clean architecture
I used Infrastructure, Domain, Data and Presentation layers (SPM packages) to control depenency direction and separate responsibilites. The goals are:
- define entties and protocols in domain layer and use only those in the app, that way app is far less susceptible to changes in outside world.
- restricting dependencies between layers and packages, e.g, low level layers (e.g. Domain) shouldn't know anything about higher level layers (e.g. Presentation). Full dependency graph is below.
- improve testability by loose coupling (injecting protocols) between layers.

## Modularisation
As mentioned above, app is separated into four layers for given reasons. Note that this kind of modularisation won't help much regarding build times or separating work between teams, that is not the purpose of it. Per-feature modularistaion is a better choice if we want that.

## SwiftUI
App uses SwiftUI which works very well with unidrectional data flow. Some notes:
- having one cetralised place for fonts, button styles, text styles, even spacings and sizes, is very important for achieving consistent UI. Nothing in the app uses strings or numbers, everything has its own enum or style, even spacing and sizings values are defined on one place
- SwiftUI is great for making small components, that is why I separated small components such as ErrorView, TryAgainView, LoadMore etc. and reused them between views.
- views don't depend on concrete stores so we can make mock stores for preview and snapshot testing.

