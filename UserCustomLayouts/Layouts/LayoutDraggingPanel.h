//
//  LayoutDraggingPanel.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/30/15.
//
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    LayoutDraggingPanelStateOrigin,
    LayoutDraggingPanelStatePlaced,
    LayoutDraggingPanelStateAnimating,
} LayoutDraggingPanelState;

@interface LayoutDraggingPanel : NSPanel
{
    NSImageView* _imageView;
    LayoutDraggingPanelState _state;
}

@property (nonatomic, readonly) NSSize originalSize;

- (void)snapshotView:(NSView*)view;

- (void)restoreToOrigin;
- (void)moveToLocation:(NSPoint)locationInScreen;
- (void)placeToView:(NSView*)view frame:(NSRect)frame contentView:(NSView*)content;

@end
