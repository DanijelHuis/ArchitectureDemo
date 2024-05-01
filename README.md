This demo is meant to accompany my CV and provide insight into what kind of architecture I currently use or I am simply interested in.

App uses PokeAPI to fetch list of pokemons and present details.

### UI architecture
App uses custom implementaion of unidirectional data flow pattern. Initially I made a custom implementation because I wanted to understand how everything works but ended up using it for this demo because it is simple and demonstrates all the main concepts well. Implementations such as The Composable Architecture are great but I have limited experience with it.

Key components are:
- view state: simple struct without any logic, it contains all the data that view needs to display the content. This is the only input that view needs.
- action: view cannot modify the state directly, it can send action to store that then modifies the state. This is the output.
- reducer/view model: It receives action and state and returns modified state. Main logic is done in here.
- store: proxy between view and reducer. It holds the state and manages side effects (async operation).

I do not use single state for whole app, but rather have isolated state for each view. This simplifies whole architecture and avoids many problems (scoping state, reducer etc.).

### Clean architecture
I used Infrastructure, Domain, Data and Presentation layers (SPM packages) to control depenency direction and separate responsibilites. The goals are:
- define entties and protocols in domain layer and use only those in the app, that way app is far less susceptible to changes in outside world.
- restricting dependencies between layers and packages, e.g, low level layers (e.g. Domain) shouldn't know anything about higher level layers (e.g. Presentation). Full dependency graph is below.
- improve testability by loose coupling (injecting protocols) between layers.

### Modularisation
As mentioned above, app is separated into four layers only to restrict dependency direction. This kind of modularisation won't help much regarding build times or separating work between teams, for that per-feature modularistaion is a better choice.

### SwiftUI
App uses SwiftUI which works very well with single view state pattern described above. Some notes:
- having one cetralised place for fonts, button styles, text styles, even spacings and sizes, is very important for achieving consistent UI. Nothing in the app uses strings or numbers, everything has its own enum or style, even spacing and sizings values are defined on one place
- SwiftUI is great for making small components, that is why I separated small components such as ErrorView, TryAgainView, LoadMore etc. and reused them between views.
- views don't depend on concrete stores so we can make mock stores for preview and snapshot testing.

