//
//  LayoutDraggingPanel.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/30/15.
//
//

#import "LayoutDraggingPanel.h"

@implementation LayoutDraggingPanel

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)cancelOperation:(id)sender
{
    [self close];
}


- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        NSImageView* imageView = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
        self.contentView = imageView;
    }
    return self;
}

- (void)snapshotView:(NSView *)view
{
    _originalSize = view.bounds.size;
    
    NSBitmapImageRep * bitmapRep = [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
    [bitmapRep setSize:_originalSize];
    
    [view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmapRep];
    
    NSImage* image = [[[NSImage alloc] initWithSize:_originalSize] autorelease];
    [image addRepresentation:bitmapRep];
    
    [(NSImageView*)self.contentView setImage:image];
}

- (void)restoreToOrigin:(BOOL)animated
{
    [self setFrame:NSMakeRect(_frame.origin.x, _frame.origin.y, _originalSize.width, _originalSize.height) display:YES animate:animated];
    [self setOpaque:NO];
    [self setAlphaValue:.8];
}

- (void)placeToView:(NSView *)view frame:(NSRect)frame animated:(BOOL)animated
{
    if (view.window == nil) {
        //TODO view must have window
        return;
    }
    [self setOpaque:YES];
    NSRect rect = [view convertRect:frame toView:nil];//view to window
    rect = [view.window convertRectToScreen:rect];//window to screen
    [self setFrame:rect display:YES animate:animated];
}

- (void)moveToLocation:(NSPoint)locationInScreen animated:(BOOL)animated
{
    [self setFrame:NSMakeRect(locationInScreen.x-_originalSize.width/2.0, locationInScreen.y-_originalSize.height/2.0, _originalSize.width, _originalSize.height) display:YES animate:animated];
}

@end
