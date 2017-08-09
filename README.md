# BWCollectionView [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

a collectionView made for Sprite Kit

## installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that provides binary frameworks for your projects.

you can install Carthage through [Homebrew](http://brew.sh/), with the following command:

```bash
$ brew update
$ brew install carthage
```

Then you need to tell carthage to integrate this framework in your Xcode project, by adding the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ogdl
github "bwide/BWCollectionView"
```

Now:

1. On your project folder, run `carthage update` 
1. On your application target, drag `BWCollectionView.framework` into your Xcode project `Embedded Binaries`

### important

If you plan to upload your app you must follow additional instructions on Carthage's [README](https://github.com/Carthage/Carthage/blob/master/README.md) on adding frameworks to your application if you're building for iOS, tvOS, or watchOS.

## usage

Usage is pretty similar to the known UICollectionView, after you create your `BWCollectionView` object you'll need to give it some data to display with a data source object, which is any object that conforms to the `BWCollectionViewDataSource` protocol.

For finer control you can also five it a `BWCollectionViewDelegate` object.

## important
1. you have to call the collection's `update(_ currentTime:)` method in your SKScene's Update method for it to properly work
1. also, before presenting another scene, be sure to call `removeFromParent()`

