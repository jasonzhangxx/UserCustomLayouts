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

////debug
//- (void)drawRect:(NSRect)aRect
//{
//    [[NSColor greenColor] set];
//    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:[self bounds]];
//    [bp stroke];
//    
//    NSString* str = [NSString stringWithFormat:@"View%lu",(unsigned long)_id];
//    [str drawAtPoint:NSZeroPoint withAttributes:nil];
//}

const float LayoutPlacedInitializeProportion = .3;

static NSUInteger layoutViewIdx = 0;

@synthesize layoutIdentifier = _id;
@synthesize handler = _handler;

- (instancetype) init
{
    self = [super init];
    if (self) {
        _id = layoutViewIdx++;
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

- (BOOL)checkDragSenderIsSelf:(LayoutDragEvent *)event
{
    return event.sender == self;
}

-(NSView*)getPlacedDisplayView
{
    return nil;
}

#pragma mark - layout sender delegate
- (LayoutView*)layoutWillMove
{
    [[self retain] autorelease];
    [_handler removeLayoutView:self];
    return self;
}

#pragma mark - layout drag responser
- (LayoutRelativeDirection)checkLayoutPlacedDirection:(NSPoint)location outspread:(CGFloat)outspread
{
    NSPoint locationInView = [self convertPoint:location fromView:self.superview];
    if (!NSPointInRect(locationInView, NSMakeRect(-outspread, -outspread, self.bounds.size.width+outspread*2, self.bounds.size.height+outspread*2))) {
        return LayoutRelativeDirectionNone;
    }
    
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
    if ([self checkDragSenderIsSelf:event] == YES) {
        return NO;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location outspread:0];
        if (direction != LayoutRelativeDirectionNone) {
            [event.panel placeToView:self frame:[self getPlacedFrame:direction] contentView:[event.sender getPlacedDisplayView]];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    if ([self checkDragSenderIsSelf:event] == YES) {
        return YES;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location outspread:0];
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
