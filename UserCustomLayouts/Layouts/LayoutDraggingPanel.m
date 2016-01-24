//
//  LayoutDraggingPanel.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/30/15.
//
//

#import "LayoutDraggingPanel.h"

const float DraggingPanelAlpha = .7;

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
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
        _imageView.imageScaling = NSImageScaleAxesIndependently;
        self.contentView = _imageView;
        _state = LayoutDraggingPanelStateOrigin;
    }
    return self;
}

- (void)dealloc
{
    [_imageView release];
    [super dealloc];
}

- (void)snapshotView:(NSView *)view
{
    _originalSize = view.bounds.size;
    
    NSBitmapImageRep * bitmapRep = [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
    [bitmapRep setSize:_originalSize];
    
    [view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmapRep];
    
    NSImage* image = [[[NSImage alloc] initWithSize:_originalSize] autorelease];
    [image addRepresentation:bitmapRep];
    
    [_imageView setImage:image];
}

- (void)restoreToOrigin
{
    self.contentView = _imageView;
    [self setFrame:NSMakeRect(_frame.origin.x, _frame.origin.y, _originalSize.width, _originalSize.height) display:YES animate:NO];
    [self setAlphaValue:DraggingPanelAlpha];
    _state = LayoutDraggingPanelStateOrigin;
}

- (void)moveToLocation:(NSPoint)locationInScreen
{
    NSRect rect = NSMakeRect(locationInScreen.x-_originalSize.width/2.0, locationInScreen.y-_originalSize.height/2.0, _originalSize.width, _originalSize.height);
    if(_state == LayoutDraggingPanelStateAnimating) {//do nothing
        return;
    }
    else if(_state == LayoutDraggingPanelStateOrigin) {//set frame directly
        [self setFrame:rect display:YES animate:NO];
    }
    else {//state changed
        self.contentView = _imageView;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[NSAnimationContext currentContext] setDuration:.3];
            [[self animator] setFrame:rect display:YES];
            [[self animator] setAlphaValue:DraggingPanelAlpha];
        } completionHandler:^{
            _state = LayoutDraggingPanelStateOrigin;
        }];
        _state = LayoutDraggingPanelStateAnimating;
    }
}

- (void)placeToView:(NSView *)view frame:(NSRect)frame contentView:(NSView *)content
{
    if (view.window == nil) {
        //TODO view must have window
        return;
    }
    
    NSRect rect = [view convertRect:frame toView:nil];//view to window
    rect = [view.window convertRectToScreen:rect];//window to screen
    if(_state == LayoutDraggingPanelStateAnimating) {//do nothing
        return;
    }
    else if(_state == LayoutDraggingPanelStatePlaced && (content == self.contentView || (content==nil&&self.contentView==_imageView))) {//set frame directly
        [self setFrame:rect display:YES animate:NO];
    }
    else {//state changed
        self.contentView = _imageView;
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [[NSAnimationContext currentContext] setDuration:.3];
            [[self animator] setFrame:rect display:YES];
            [[self animator] setAlphaValue:1];
        } completionHandler:^{
            if(content != nil) {
                content.frame = NSMakeRect(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
                self.contentView = content;
            }
            _state = LayoutDraggingPanelStatePlaced;
        }];
        _state = LayoutDraggingPanelStateAnimating;
    }
}

@end
