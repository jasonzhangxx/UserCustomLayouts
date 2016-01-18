//
//  LayoutView.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutView.h"
#import "LayoutHandler.h"

@implementation LayoutView

//debug
- (void)drawRect:(NSRect)aRect
{
    [[NSColor greenColor] set];
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:[self bounds]];
    [bp stroke];
    
    NSString* str = [NSString stringWithFormat:@"View%lu",(unsigned long)_id];
    [str drawAtPoint:NSZeroPoint withAttributes:nil];
}

const float LayoutPlacedInitializeProportion = .3;
const float LayoutBorderWidth = 4;

static NSUInteger layoutViewIdx = 0;

@synthesize identifier = _id;
@synthesize handler = _handler;

- (instancetype) init
{
    self = [super init];
    if (self) {
        _id = layoutViewIdx++;
        _resizing = NO;
    }
    return self;
}

- (instancetype)initWithHandler:(LayoutHandler *)handler
{
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSSize)layoutMinSize
{
    return NSZeroSize;
}

#pragma mark - mouse handle
- (void)mouseDown:(NSEvent *)theEvent
{
    //handler resize event
    _resizing = NO;
    NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (location.x <= LayoutBorderWidth && [self isResizeAvailable:LayoutRelativeDirectionLeft]) {
        _resizing = YES;
        _resizeDirection = LayoutRelativeDirectionLeft;
        _mouseDownRelativeLocation = location;
    }
    else if (self.bounds.size.width-location.x <= LayoutBorderWidth && [self isResizeAvailable:LayoutRelativeDirectionRight]) {
        _resizing = YES;
        _resizeDirection = LayoutRelativeDirectionRight;
        _mouseDownRelativeLocation = NSMakePoint(_frame.size.width-location.x, location.y);
    }
    else if (location.y <= LayoutBorderWidth && [self isResizeAvailable:LayoutRelativeDirectionBottom]) {
        _resizing = YES;
        _resizeDirection = LayoutRelativeDirectionBottom;
        _mouseDownRelativeLocation = location;
    }
    else if (self.bounds.size.height-location.y <= LayoutBorderWidth && [self isResizeAvailable:LayoutRelativeDirectionTop]) {
        _resizing = YES;
        _resizeDirection = LayoutRelativeDirectionTop;
        _mouseDownRelativeLocation = NSMakePoint(location.x, _frame.size.height-location.y);
    }
    
    if (_resizing == NO) {
        [_handler handleMouseEvent:self type:LayoutDragStateBegin location:theEvent.locationInWindow];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_resizing == YES) {
        NSPoint location = [self convertPoint:theEvent.locationInWindow fromView:nil];
//        NSLog(@"mouse down location %@", NSStringFromPoint(_mouseDownLocation));
//        NSLog(@"location %@", NSStringFromPoint(location));
        
        switch (_resizeDirection) {
            case LayoutRelativeDirectionLeft:
            {
                [_handler handleResizeEvent:self variation:(location.x-_mouseDownRelativeLocation.x) direction:_resizeDirection];
                break;
            }
            case LayoutRelativeDirectionRight:
            {
                [_handler handleResizeEvent:self variation:(_frame.size.width-location.x-_mouseDownRelativeLocation.x) direction:_resizeDirection];
                break;
            }
            case LayoutRelativeDirectionBottom:
            {
                [_handler handleResizeEvent:self variation:(location.y-_mouseDownRelativeLocation.y) direction:_resizeDirection];
                break;
            }
            case LayoutRelativeDirectionTop:
            {
                [_handler handleResizeEvent:self variation:(_frame.size.height-location.y-_mouseDownRelativeLocation.y) direction:_resizeDirection];
                break;
            }
            default:
                break;
        }
    }
    
    if (_resizing == NO) {
        [_handler handleMouseEvent:self type:LayoutDragStateDraging location:theEvent.locationInWindow];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (_resizing == NO) {
        [_handler handleMouseEvent:self type:LayoutDragStateEnd location:theEvent.locationInWindow];
    }
    
    _resizing = NO;
}

#pragma mark - resize
- (BOOL)isResizeAvailable:(LayoutRelativeDirection)dir
{
    switch (dir) {
        case LayoutRelativeDirectionLeft: {
            return _frame.origin.x>=0.01;
        }
        case LayoutRelativeDirectionRight: {
            return self.superview.bounds.size.width-(_frame.origin.x+_frame.size.width)>=0.01;
        }
        case LayoutRelativeDirectionBottom: {
            return _frame.origin.y>=0.01;
        }
        case LayoutRelativeDirectionTop: {
            return self.superview.bounds.size.height-(_frame.origin.y+_frame.size.height)>=0.01;
        }
        default:
            break;
    }
    return NO;
}

- (void)resetCursorRects
{
    //filter parentView's edge
    if ([self isResizeAvailable:LayoutRelativeDirectionLeft] == YES) {
        [self addCursorRect:NSMakeRect(0, 0, LayoutBorderWidth, self.frame.size.height) cursor:[NSCursor resizeLeftRightCursor]];
    }
    if ([self isResizeAvailable:LayoutRelativeDirectionRight]) {
        [self addCursorRect:NSMakeRect(self.frame.size.width-LayoutBorderWidth, 0, LayoutBorderWidth, self.frame.size.height) cursor:[NSCursor resizeLeftRightCursor]];
    }
    if ([self isResizeAvailable:LayoutRelativeDirectionBottom]) {
        [self addCursorRect:NSMakeRect(0, 0, self.frame.size.width, LayoutBorderWidth) cursor:[NSCursor resizeUpDownCursor]];
    }
    if ([self isResizeAvailable:LayoutRelativeDirectionTop]) {
        [self addCursorRect:NSMakeRect(0, self.frame.size.height-LayoutBorderWidth, self.frame.size.width, LayoutBorderWidth) cursor:[NSCursor resizeUpDownCursor]];
    }
}

#pragma mark - layout sender delegate
- (LayoutView*)layoutWillMove
{
    [[self retain] autorelease];
    [_handler removeLayoutView:self];
    return self;
}

#pragma mark - layout drag responser
- (LayoutRelativeDirection)checkLayoutPlacedDirection:(NSPoint)location
{
    if (!NSPointInRect(location, self.frame)) {
        return LayoutRelativeDirectionNone;
    }
    
    NSPoint locationInView = [self convertPoint:location fromView:self.superview];
    float slope = self.frame.size.height/self.frame.size.width;
    
    if (locationInView.x < LayoutPlacedInitializeProportion*self.frame.size.width && locationInView.y > locationInView.x * slope) {
        return LayoutRelativeDirectionLeft;
    }
    else if(locationInView.x > (1.0-LayoutPlacedInitializeProportion)*self.frame.size.width && locationInView.y > self.frame.size.height-locationInView.x * slope) {
        return LayoutRelativeDirectionRight;
    }
    else if (locationInView.y < LayoutPlacedInitializeProportion*self.frame.size.height) {
        return LayoutRelativeDirectionBottom;
    }
    else {
        return LayoutRelativeDirectionNone;
    }
}

- (NSRect)getPlacedFrame:(LayoutRelativeDirection)direction
{
    switch (direction) {
        case LayoutRelativeDirectionLeft:
        {
            float width = self.frame.size.width*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, 0, width, self.frame.size.height);
        }
        case LayoutRelativeDirectionRight:
        {
            float width = self.frame.size.width*LayoutPlacedInitializeProportion;
            return NSMakeRect(self.frame.size.width-width, 0, width, self.frame.size.height);
        }
        case LayoutRelativeDirectionBottom:
        {
            float height = self.frame.size.height*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, 0, self.frame.size.width, height);
        }
        case LayoutRelativeDirectionTop:
        {
            float height = self.frame.size.height*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, self.frame.size.height-height, self.frame.size.width, height);
        }
        default:
        {
            break;
        }
    }
    return NSZeroRect;
}

- (void)onLayoutDragIn
{
//    NSLog(@"view%lu drag in", (unsigned long)_id);
}

- (void)onLayoutDragOut
{
//    NSLog(@"view%lu drag out", (unsigned long)_id);
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    if (event.sender == self) {
        return NO;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location];
        if (direction != LayoutRelativeDirectionNone) {
            [event.panel placeToView:self frame:[self getPlacedFrame:direction] animated:YES];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    if (event.sender == self) {
        return YES;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location];
        if (direction != LayoutRelativeDirectionNone) {
            LayoutView* view = [event.sender layoutWillMove];
            if (view != nil) {
                [_handler addLayoutView:view to:self direction:direction size:[self getPlacedFrame:direction].size];
            }
            return YES;
        }
        else {
            return NO;
        }
    }
}

@end
