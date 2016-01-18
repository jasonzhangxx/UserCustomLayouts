//
//  TabLayoutView.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/16/15.
//
//

#import "TabLayoutView.h"
#import "LayoutHandler.h"

const float TabbarHeight = 18;

@implementation TabLayoutViewTab

//debug
- (void)drawRect:(NSRect)aRect
{
    [[NSColor blackColor] set];
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:[self bounds]];
    [bp stroke];
    
    [[self tabTitle] drawAtPoint:NSZeroPoint withAttributes:nil];
}

- (instancetype)initWithContentView:(NSView<TabLayoutContentInterface> *)view
{
    self = [super init];
    if (self) {
        self.contentView = view;
    }
    return self;
}

- (void)dealloc
{
    [_contentView release];
    [super dealloc];
}

- (NSString*)tabTitle
{
    return [_contentView layoutTitle];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (_delegate != nil) {
        [_delegate tabMouseDown:self event:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_delegate != nil) {
        [_delegate tabMouseDragged:self event:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (_delegate != nil) {
        [_delegate tabMouseUp:self event:theEvent];
    }
}

@end

@implementation TabLayoutView

@synthesize draggingTab = _draggingTab;

//debug
- (void)drawRect:(NSRect)aRect
{
    [[NSColor redColor] set];
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:[self bounds]];
    [bp stroke];
    
    NSString* str = [NSString stringWithFormat:@"TabView%lu",(unsigned long)_id];
    [str drawAtPoint:NSZeroPoint withAttributes:nil];
}

- (id)initWithHandler:(LayoutHandler *)handler view:(NSView<TabLayoutContentInterface> *)view
{
    self = [super initWithHandler:handler];
    if(self) {
        _tabs = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
        
        _tabView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, TabbarHeight)] autorelease];
        [self addSubview:_tabView];
        
        [self insertContentView:view index:0 highlighted:YES];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tabs release];
    [super dealloc];
}

- (void)onViewDidResize:(NSNotification*)noti
{
    if(noti.object == self) {
        [_selectedTab.contentView setFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-_tabView.frame.size.height)];
        [_tabView setFrame:NSMakeRect(0, self.bounds.size.height-TabbarHeight, self.bounds.size.width, TabbarHeight)];
        [self formatTabs];
    }
}

- (NSSize)layoutMinSize
{
    __block NSSize size = NSZeroSize;
    [_tabs enumerateObjectsUsingBlock:^(TabLayoutViewTab * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize s = obj.contentView.layoutMinSize;
        if (s.width>size.width) {
            size.width = s.width;
        }
        if (s.height>size.height) {
            size.height = s.height;
        }
    }];
    size.height += TabbarHeight;
    return size;
}

- (NSArray*)tabs
{
    return _tabs;
}

- (void)setSelectedTab:(TabLayoutViewTab *)tab
{
    if (tab != _selectedTab) {
        _selectedTab.highlighted = NO;
        _selectedTab.contentView.hidden = YES;
        
        _selectedTab = tab;
        _selectedTab.highlighted = YES;
        _selectedTab.contentView.hidden = NO;
        [_selectedTab.contentView setFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-_tabView.frame.size.height)];
    }
}

- (void)insertContentView:(NSView<TabLayoutContentInterface> *)view index:(int)index highlighted:(BOOL)highlighted
{
    if (view == nil || index<0 || index>_tabs.count) {
        //TODO  error
        return;
    }
    TabLayoutViewTab* tab = [[[TabLayoutViewTab alloc] initWithContentView:view] autorelease];
    tab.delegate = self;
    [_tabs insertObject:tab atIndex:index];
    [_tabView addSubview:tab];
    view.hidden = YES;
    [self addSubview:view];
    [self formatTabs];
    
    if (highlighted == YES) {
        [self setSelectedTab:tab];
    }
    
    [self.window resetCursorRects];//protect cursor rects error
}

- (void)removeTab:(TabLayoutViewTab *)tab
{
    if (![_tabs containsObject:tab]) {
        //TODO not sub tab
        return;
    }
    
    [tab.contentView removeFromSuperview];
    [tab removeFromSuperview];
    [_tabs removeObject:tab];
    [self formatTabs];
    if (tab == _selectedTab && _tabs.count > 0) {
        [self setSelectedTab:_tabs[0]];
    }
}

- (void)formatTabs
{
    for (int i=0,index=0,max=(int)_tabs.count; i<max; i++) {
        if (_tabs[i] != _draggingTab) {
            [_tabs[i] setFrame:NSMakeRect(100*index++, 0, 100, TabbarHeight)];
        }
    }
}

#pragma mark - Tab Delegate
- (void)tabMouseDown:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent
{
    [self setSelectedTab:sender];
 
    [_handler handleMouseEvent:self type:LayoutDragStateBegin location:theEvent.locationInWindow];
}

- (void)tabMouseDragged:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent
{
    if (sender != _draggingTab) {
        _draggingTab = sender;
        [self formatTabs];
    }
    [_handler handleMouseEvent:self type:LayoutDragStateDraging location:theEvent.locationInWindow];
}

- (void)tabMouseUp:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent
{
    [_handler handleMouseEvent:self type:LayoutDragStateEnd location:theEvent.locationInWindow];
    _draggingTab = nil;
    [self formatTabs];
}

#pragma mark - layout sender delegate
- (void)checkRemoveIfNoChild
{
    if(_tabs.count == 0) {
        [_handler removeLayoutView:self];
    }
}

- (LayoutView*)layoutWillMove
{
    NSView<TabLayoutContentInterface>* contentView = [[_draggingTab.contentView retain] autorelease];
    
    [self removeTab:_draggingTab];
    _draggingTab = nil;
    
    TabLayoutView* view = [[[TabLayoutView alloc] initWithHandler:_handler view:contentView] autorelease];
    view.frame = self.bounds;
    
    [self checkRemoveIfNoChild];
    return view;
}

- (NSView<TabLayoutContentInterface>*)tabLayoutWillMove
{
    NSView<TabLayoutContentInterface>* contentView = [[_draggingTab.contentView retain] autorelease];
    
    [self removeTab:_draggingTab];
    _draggingTab = nil;
    
    [self checkRemoveIfNoChild];
    return contentView;
}

#pragma mark - layout drag responser
- (BOOL)checkTabbarAdded:(LayoutView*)target location:(NSPoint)location
{
    NSPoint locationInView = [self convertPoint:location fromView:self.superview];
    if (NSPointInRect(locationInView, _tabView.frame)) {
        return YES;
    }
    else {
       return NO;
    }
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    if([event.sender isKindOfClass:[self class]] == YES) {
        if ([self checkTabbarAdded:event.sender location:event.location]) {
            [event.panel placeToView:self frame:self.bounds animated:YES];
            return YES;
        }
    }
    return [super onLayoutDragMove:event];
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    if([event.sender isKindOfClass:[self class]] == YES) {
        if ([self checkTabbarAdded:event.sender location:event.location]) {
            if (event.sender == self) {
                //reorder
                
            }
            else {
                NSView<TabLayoutContentInterface>* view = [(TabLayoutView*)event.sender tabLayoutWillMove];
                if (view != nil) {
                    [self insertContentView:view index:(int)_tabs.count highlighted:YES];
                }
            }
            return YES;
        }
    }
    return [super onLayoutDragEndInside:event];
}

@end
