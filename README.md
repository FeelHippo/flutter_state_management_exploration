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

Doesn't help much, doesn't it. Let's try to come up with the best possible definition of a Cubit. 
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
