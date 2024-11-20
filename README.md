# state_management_app

<a name="readme-top"></a>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#inherited-widget">InheritedWidget: where it all starts</a></li>
        <li><a href="#provider">Provider: wrap it up!</a></li>
        <li><a href="#cubit">Cubit: keep it simple, stupid.</a></li>
        <li><a href="#bloc">Bloc: all you need</a></li>
        <li><a href="#riverpod">Riverpod: mixed feelings</a></li>
        <li><a href="#june">June: uhm, what?</a></li>
        <li><a href="#mobx">Mobx: there's no one else like me</a></li>
      </ul>
    </li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

Is there anything more controversial, more debated, more "love it or hate it", than state management in Flutter? 

Let's take a break, already, and allow me to quote the 21st century Bard:
```
The worst hated God who perpetrated odd favors
Demonstrated in the perforated Rod Lavers
… In all quad flavors, Lord save us.
```

[Beautiful](https://highbrowshawn.medium.com/mf-doom-hip-hops-worst-kept-secret-206043ae139d). Now, let's get back to state management. 

I have been using Bloc religiously for several years now, and I know it inside out.
It's easy to use, well maintained, well documented, and developer friendly.
Once a pattern has been established, the entire application can be built around it pretty easily.

But, just like with all things religious, the benefit of the doubt can lead to more mature faith.
I therefore embarked on an exploratory trip to the official [list of state management approaches](https://docs.flutter.dev/data-and-backend/state-mgmt/options).

I soon realized I knew very little about state management in Flutter, a dried up information sponge.
But, as absorbent and porous as I am, and since nautical nonsense is something I definitely wished, I decided to drop on the deck and flop like a fish. 

I therefore decided to create this little project, for the sole purpose of comparing (the most popular) solutions against each other. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INHERITED WIDGET -->
### InheritedWidget: where it all starts

[Inherited Widget Class](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html) is the basic building bloc of state management in Flutter. 
[In one of my previous weekend projects](https://github.com/FeelHippo/JavascriptNinjaSkills/blob/main/flutter/example_inherited_widget_usage.dart) you can find a break down of all the bits and pieces that make this class work, including BuildContext Element, and InheritedElement.

Flutter's definition is so concise and yet meaningful, I suspect it was composed by MF DOOM himself:

```
Base class for widgets that efficiently propagate information down the tree.
```

[BuildContext.dependOnInheritedWidgetOfExactType](https://github.com/FeelHippo/JavascriptNinjaSkills/blob/a482a9ebc0a8362bef7e5c7830d997158dc5936d/flutter/elements/build_context.dart#L16) allows you to obtain the nearest instance of a particular type of inherited widget. 
An InheritedWidget will only be rebuilt if `bool updateShouldNotify(covariant InheritedWidget oldWidget);`, which can be programmatically implemented, will confirm that the data held by the previous build has changed. 

And this is it. That is how state management works in Flutter. If the Widget's associated Element is [marked](https://github.com/FeelHippo/JavascriptNinjaSkills/blob/a482a9ebc0a8362bef7e5c7830d997158dc5936d/flutter/elements/element.dart#L72) as `dirty`, the Widget will be rebuilt and replaced.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- PROVIDER -->
### Provider: wrap it up!

[The Provider Package](https://pub.dev/packages/provider) is "a wrapper around InheritedWidget to make them easier to use and more reusable."
By looking at the [GitHub repository](https://github.com/rrousselGit/provider/tree/master), one can see the advantages over an InheritedWidget:
- it provides additional devtools extensions, to improve the overall developer experience
- it makes state management [more concise](https://github.com/rrousselGit/provider/blob/3a81a9148001728d74b1f307dc966352684e6748/packages/provider/lib/src/provider.dart#L147C5-L147C69) by replacing the need to create StatefulWidget's for something trivial. 
- it is [created lazily](https://github.com/rrousselGit/provider/blob/3a81a9148001728d74b1f307dc966352684e6748/packages/provider/lib/src/provider.dart#L172), when the value is first read as opposed to when the widget is inserted into the tree
- `class Provider<T> extends InheritedProvider<T> {}` => if you look at its implementation you will (probably not) be surprised! [Look](https://github.com/rrousselGit/provider/blob/3a81a9148001728d74b1f307dc966352684e6748/packages/provider/lib/src/inherited_provider.dart#L43)! `InheritedProvider is a generic implementation of an [InheritedWidget].`
- it [makes it easy](https://pub.dev/documentation/provider/latest/provider/Provider/of.html) to obtain the nearest `Provider<T>` up the widget tree, and return its value:
  - [find nearest Element](https://github.com/rrousselGit/provider/blob/3a81a9148001728d74b1f307dc966352684e6748/packages/provider/lib/src/provider.dart#L272)
  - [access Element and its value from BuildContext](https://github.com/rrousselGit/provider/blob/3a81a9148001728d74b1f307dc966352684e6748/packages/provider/lib/src/provider.dart#L315)
- it [introduces](https://pub.dev/documentation/provider/latest/provider/Consumer-class.html) a `Consumer`, which obtains a `Provider<T>` from its ancestors and passes its value to a `builder`
  - it allows obtaining a value from a provider when we don't have a BuildContext that is a descendant of said provider, and therefore cannot use Provider.of


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CUBIT -->
### Cubit: keep it simple, stupid.

[Cubit](https://bloclibrary.dev/bloc-concepts/#cubit) is "a class which extends BlocBase and can be extended to manage any type of state."

Doesn't help much, doesn't it. Let's try to come up with the best possible definition of a [Cubit](https://github.com/felangel/bloc/blob/841651f6901d3f7817ac8a47d4a2162606dd794c/packages/bloc/lib/src/cubit.dart#L3). 
Funny, or maybe not, story, I recently absolutely botched the final interview for a dream job on the following question:

`can you provide an exhaustive definition of Cubit?`. That's it. That was my task to make $$$$$$.

I proceeded to dance around it like a russian ballerina. I murdered Cubit like an Italian reciting Shakespear. What a ding dong!

The Merriam Webster dictionary provides the following definition: `Middle English, from Latin cubitum elbow, cubit`.

Nope, not helpful. 

So, enough about me and my poetry. According to the official documentation:
`A Cubit can expose functions which can be invoked to trigger state changes.`

So, assuming you have:
    - created a Cubit
    - initialized the state with a value
    - created an update method on the class
    - instantiated the Cubit

.. your cubit will then be `and object that can be updated, observed, and consumed for representing a state`.

Something like that. On top of that, it also exposes a `Stream`, which allows to receive real-time state updates. 
If you are familiar with Bloc, you will recognize some of the defining traits. 
The main difference, I would argue, is the lack of an out of the box way to "use" a Cubit, such as events, state emitters, a well defined consumer, provider or builder. 
That's all taken care of by ...

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- BLOC -->
### Bloc: all you need

Now, Cubit is cool and all. It "can" be used to build a full scale application.
However, you'd soon regret your life choices.
Cubits are meant for very simple data with basically no state flow logic at all. Like an int. Or maybe a DarkTheme/LightTheme switch.
You'd need to instantiate cubits all over the place, figure out how to trigger the event methods, how to react to state changes, etc etc

This is where Bloc shines. 

The official definition is intimidating, in that it uses more than 5 words:
```
A Bloc is a more advanced class which relies on events to trigger state changes rather than functions.
Bloc also extends BlocBase which means it has a similar public API as Cubit.
However, rather than calling a function on a Bloc and directly emitting a new state, 
Blocs receive events and convert the incoming events into outgoing states.
```

For illiterate donkeys like me:

- a Bloc is a `Stream`, that listens for `Events` in response to which it emits a `State`
  - a Bloc needs to be instantiated once,
  - it will then be available in its sub tree
- trigger a change? `event`
- update data? `state`
- consume data and react to a change?
  - [BlocListener](https://github.com/felangel/bloc/blob/841651f6901d3f7817ac8a47d4a2162606dd794c/packages/flutter_bloc/lib/src/bloc_listener.dart#L15) if you want to "do" anything in response to `state` changes such as navigation
  - [BlocBuilder](https://github.com/felangel/bloc/blob/841651f6901d3f7817ac8a47d4a2162606dd794c/packages/flutter_bloc/lib/src/bloc_builder.dart) for building a widget in response to new `states`
  - [BlocConsumer](https://github.com/felangel/bloc/blob/841651f6901d3f7817ac8a47d4a2162606dd794c/packages/flutter_bloc/lib/src/bloc_consumer.dart) for a combination of the above. 

I think of it as my local Pizza Chef, Luigi. 
When his application (the pizzeria) is open, up and running, he's there waiting for calls, possibly consuming questionable content from questionable web sites, but that is not our business. 
When I give him a call, I emit an `Event` for an order. Ring Ring! "Luigi's! What do I gett'ya?". "A pineapple pine and apple pizza, please.".
He then processes the order, possibly asynchronously calling the ingredients, converting them from DTO into a repository level model. Pack the whole thing into a questionable box.
The data is now ready, it's time to ship it. His brother, Gianmarialuigi, delivers my order to me, at which point I can update my `State`, and I immediately react to those changes by consuming my pizza.

That's it. This is Bloc. 
Of course, before you can get up to speed, you need to decide how to inject blocs into your application, find the right place to instantiate them, establish a clear patterns that can be replicated, define error handling, observation, etc etc. 
I have got you covered, I have a few examples [here](https://github.com/FeelHippo/stadtplan_mobile_app/tree/main/lib/presentation)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- RIVERPOD -->
### Riverpod: mixed feelings

I have very mixed feeling about Riverpod. As mentioned above, I am a big Bloc fanboi. 
Now, if you take a quick look at the two components in the `./state_managements` folder, you will notice that:
- Riverpod, for simple applications, is way more concise: 39 lines of code vs. 117 for Bloc
- it works in a symmetrical way to Bloc:
  - Bloc: inside your presentational component, you use a consumer to react to state changes to a bloc, which was instantiated and injected up the widget tree. 
  - Riverpod: up the widget tree you wrap the subtree in a `ProviderScope` widget, inside of which all `ConsumerWidget`s have access to the `WidgetRef`, which is a wrapper for the state.  
- the way in which `ref` can be watched or listened, in my own personal opinion, feels flimsy and inconsistent, compared to Bloc's Events. 
- you would expect that to result in less boilerplate, but once you start digging into the docs, oh my. I would not choose Riverpod for large scale apps.
- it is not very opinionated when it comes to overall architecture, but makes things more zigzaggy than Bloc. [Andrea Bizzotto](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) is a Riverpod contributor, and probably the best at explaining Flutter thingies. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- JUNE -->
### June: uhm, what?

The best I can do here, is to copy paste the description from Flutter's docs: 

```
A lightweight and modern state management library that focuses on providing a pattern similar to Flutter's built-in state management.
```

Lightweight? OK. The snippet in this project is probably the shortest, ex aequo with Riverpod. 
It's also the one that I could not make work for the love of my life. It's supposed to be "declare your state and call setState to update the UI".
No way to make it work. 

After flipping stupp around for a while, and try each and every pattern from the docs, the very last (of course...) made it update the listTile. 
Which, in my opinion, should be easier. 

I don't know, if I were to choose a state management strategy for something this simple, I would still prefer Cubit. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MOBX -->
### Mobx: there's no one else like me

```
MobX is a state-management library that makes it simple to connect the reactive data of your application with the UI.
This wiring is completely automatic and feels very natural. As the application-developer, 
you focus purely on what reactive-data needs to be consumed in the UI (and elsewhere) without worrying about keeping the two in sync.

It's not really magic but it does have some smarts around what is being consumed (observables) and where (reactions), 
and automatically tracks it for you. When the observables change, all reactions are re-run. 
What's interesting is that these reactions can be anything from a simple console log, a network call to re-rendering the UI.
```

The "Start Guide" is written in JavaScript. We are, however, reassured that `the concepts are 100% applicable to Dart and Flutter`.

`event.stopPropagation()` to my applications, as far as I am concerned. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>
