//
//  LayoutDraggingPanel.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/30/15.
//
//

#import <Cocoa/Cocoa.h>

@interface LayoutDraggingPanel : NSPanel

@property (nonatomic, readonly) NSSize originalSize;

- (void)snapshotView:(NSView*)view;

- (void)restoreToOrigin:(BOOL)animated;
- (void)placeToView:(NSView*)view frame:(NSRect)frame animated:(BOOL)animated;
- (void)moveToLocation:(NSPoint)locationInScreen animated:(BOOL)animated;

@end
