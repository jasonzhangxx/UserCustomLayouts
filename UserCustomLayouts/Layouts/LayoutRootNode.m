//
//  LayoutRootNode.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutRootNode.h"
#import "LayoutView.h"

@implementation LayoutRootNode

-(instancetype)initWithHandler:(LayoutHandler *)handler view:(NSView *)view
{
    self = [super initWithHandler:handler];
    if (self) {
        _autoRemovedWhenEmpty = NO;
        _view = view;
        _root = self;
        _virtualNode = [[[LayoutNode alloc] initWithHandler:handler] autorelease];
        [super addSubNode:_virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
        
        [self setFrame:NSMakeRect(0, 0, _view.frame.size.width, _view.frame.size.height)];
    }
    return self;
}

- (void)dealloc
{
    [[NSArray arrayWithArray:_view.subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id<LayoutDragResponserDelegate>)responser
{
    return self;
}

-(void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [_virtualNode setFrame:frame];
}

-(void)addSubNode:(LayoutNode*)node direction:(LayoutRelativeDirection)direction relativeNode:(LayoutNode *)relativeNode
{
    //do nothing
}

-(void)removeSubNode:(LayoutNode*)node
{
    //do nothing
}

-(void)replaceNode:(LayoutNode*)node withNode:(LayoutNode*)newNode
{
    if (node == _virtualNode) {
        [super replaceNode:node withNode:newNode];
        _virtualNode = newNode;
    }
}

#pragma mark - view frame observer
- (void)onViewDidResize:(NSNotification*)noti
{
    if(noti.object == _view) {
        [self setFrame:NSMakeRect(0, 0, _view.frame.size.width, _view.frame.size.height)];
    }
}

#pragma mark - Layout Responser, default handler
static CGFloat outspreadWidth = 24;
- (LayoutRelativeDirection)checkLayoutPlacedDirection:(NSPoint)location
{
    if (!NSPointInRect(location, NSMakeRect(-outspreadWidth, -outspreadWidth, _view.bounds.size.width+outspreadWidth*2, _view.bounds.size.height+outspreadWidth*2))) {
        return LayoutRelativeDirectionNone;
    }
    
    float slope = _view.bounds.size.height/_view.bounds.size.width;
    if (location.x < LayoutPlacedInitializeProportion*_view.bounds.size.width && location.y > location.x * slope) {
        return LayoutRelativeDirectionLeft;
    }
    else if(location.x > (1.0-LayoutPlacedInitializeProportion)*_view.bounds.size.width && location.y > _view.bounds.size.height-location.x * slope) {
        return LayoutRelativeDirectionRight;
    }
    else if (location.y < LayoutPlacedInitializeProportion*_view.bounds.size.height) {
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
            float width = _view.bounds.size.width*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, 0, width, _view.bounds.size.height);
        }
        case LayoutRelativeDirectionRight:
        {
            float width = _view.bounds.size.width*LayoutPlacedInitializeProportion;
            return NSMakeRect(_view.bounds.size.width-width, 0, width, _view.bounds.size.height);
        }
        case LayoutRelativeDirectionBottom:
        {
            float height = _view.bounds.size.height*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, 0, _view.bounds.size.width, height);
        }
        case LayoutRelativeDirectionTop:
        {
            float height = _view.bounds.size.height*LayoutPlacedInitializeProportion;
            return NSMakeRect(0, _view.bounds.size.height-height, _view.bounds.size.width, height);
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
    
}

- (void)onLayoutDragOut
{
    
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    if (_virtualNode.subNodes.count == 0) {
        [event.panel placeToView:_view frame:_view.bounds animated:YES];
        return YES;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location];
        if (direction != LayoutRelativeDirectionNone) {
            [event.panel placeToView:_view frame:[self getPlacedFrame:direction] animated:YES];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    if (_virtualNode.subNodes.count == 0) {
        LayoutView* view = [event.sender layoutWillMove];
        if (view != nil) {
            [_handler addLayoutView:view toNode:_virtualNode direction:LayoutRelativeDirectionBottom size:NSZeroSize relativeNode:nil];
        }
        return YES;
    }
    else {
        LayoutRelativeDirection direction = [self checkLayoutPlacedDirection:event.location];
        if (direction != LayoutRelativeDirectionNone) {
            LayoutView* view = [event.sender layoutWillMove];
            if (view != nil) {
                [_handler addLayoutView:view toNode:_virtualNode direction:direction size:[self getPlacedFrame:direction].size  relativeNode:nil];
            }
            return YES;
        }
        else {
            return NO;
        }
    }
}

@end
