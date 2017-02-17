###User Custom Layouts

A solution for user custom layouts on Mac application. It's not something like "Auto Layouts". It makes the users can arrange their layouts by themselves. Also, it supports multiple windows.

####How to use

1. Create a handler.
2. Create a view confirms to TabLayoutContentInterface ( It's a protocol ).
3. Create a TabLayoutView.
4. Add TabLayoutView to the handler.

```
_hanlder = [[LayoutHandler alloc] initWithView:_window.contentView];
YourView* view = [[[YourView alloc] init] autorelease];
TabLayoutView *tabView = [[[TabLayoutView alloc] initWithHandler:_hanlder view] autorelease];
[_hanlder addLayoutView:tabView toNode:_hanlder.firstResponsedRoot direction:LayoutRelativeDirectionLeft size:NSZeroSize relativeNode:nil];
```
