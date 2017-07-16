# WillowTreeScrollingTabController

The ScrollingTabController provides a tab based container view with navigational tabs at the top and a swipeable content area below. This component follows a similar design and functionality as the Android tab interface.  The following features are supported:

* Support for a large number of tabs and view controllers.
* Customizable tab cells, dividers, and delegate callbacks to configure each cell
* Customizable selection indicator
* Dynamic tab sizes
* Customizable tab selection positioning.

<img src="docs/example.gif" width="300">

## Installation

The preferred method to install is to use CocoaPods

pod 'WillowTreeScrollingTabController'

## Getting Started

The ScrollingTabController supports instantiation either through InterfaceBuilder or through code and may also easily be subclassed to provide the necessary data and view controllers.  The ScrollingTabControllerExample project shows the basic subclassing method of creating the view controller.  The basic setup involves the following:

1. Provide the controller with the set of view controllers that it will manager through the ```viewControllers``` property.
2. Implement the


  ```func tabView(tabView: ScrollingTabController, configureTitleCell cell: UICollectionViewCell, atIndex index: Int) -> UICollectionViewCell?```

protocol method of ScrollingTabControllerDataSource to provide the titles for the tabs in the view controller.

## Customizing the View

There are several options for customizing the tab controller.  In addition to the ability to configure the tab cells by implementing the TabDataSource protocol, the ScrollingTabController itself has the following properties to configure appearance:

* ```sizeTabItemsToFit``` - Specifies if the tabs should resize to fit the size of the tab title
* ```centerSelectTabs``` - Specifies if the selected tab should remain centered in the view

In addition, even more customization of the tab bar itself can be had by accessing the ```tabBar``` property of the controller.  The tab bar has the following properties to configure appearance.

* ```selectionIndicatorOffset``` - Specify the offset of the selection indicator from the bottom of the view
* ```selectionIndicator``` - Direct access to change the selection indicator view
* ```selectionIndicatorHeight``` - Height of the selection indicator
* ```selectionIndicatorEdgeInsets``` - Edge insets for the selection indicator
* ```classForCell``` - Custom class to use for the tabs
* ```classForDivider``` - Custom decorator view to use for tab separators

## Changes

### 0.1.0

Update to Swift 3.

### 0.0.7

When the view controller specified an initial tab before it was
displayed, that tab was not set before the appearance happened. This
changes the order so that the tab is selected in viewWillAppear to fix
the issue.

### 0.0.6

* Add support for programatically channging the selected tab. You can now call 

### 0.0.5

* Fix crash when the bounds of the tab controller were 0.
* Manually manage appearance calls to child VCs
    * In order to support only calling the view lifecycle calls (willAppear,
didAppear, willDisappear, didDisappear) when the child view controller
is in that state, update the scrolling tab controller to manually
control the view lifecycle of the child controllers.

### 0.0.4

* Add support for changing the height of the tab bar.
* Add support for cell highlighting.

### 0.0.3

* Breaking API change of removing the data source delegate to the scrolling controller. This was not used heavily and lead to confusion. The new API is much more in-line with UITabBarController

## Contributing / Questions

We are always open to contributions and pull requests on GitHub. Please follow us at @willowtreeapps on Twitter or http://www.willowtreeapps.com
