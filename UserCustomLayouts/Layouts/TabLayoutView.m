//
//  TabLayoutView.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/16/15.
//
//

#import "TabLayoutView.h"
#import "LayoutHandler.h"

const float TabbarNormalWidth = 100;
const float TabbarHeight = 18;

@implementation TabLayoutViewTab

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
    [_tempTitle release];
    [super dealloc];
}

- (NSString*)tabTitle
{
    if(_tempTitle != nil) {
        return _tempTitle;
    }
    else {
        return [_contentView layoutTitle];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    [self setNeedsDisplay:YES];
}

- (void)setTempTitle:(NSString *)tempTitle
{
    [_tempTitle release];
    _tempTitle = [tempTitle copy];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (_highlighted) {
        NSBezierPath* path = [NSBezierPath bezierPathWithRect:self.bounds];
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:.9 green:.9 blue:.9 alpha:1] endingColor:[NSColor colorWithCalibratedRed:.84 green:.84 blue:.84 alpha:1]];
        [gradient drawInBezierPath:path angle:-90];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [self.tabTitle drawInRect:NSMakeRect(4, 2, self.bounds.size.width-8, 14) withAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
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

static TabLayoutView* s_placedDisplayView = nil;
static TabLayoutViewTab* s_placedDisplayTab = nil;
+ (void)initialize
{
    if (self == [TabLayoutView class]) {
        s_placedDisplayView = [[TabLayoutView alloc] initWithHandler:nil];
        [s_placedDisplayView insertContentView:(NSView<TabLayoutContentInterface>*)[[[NSView alloc] init] autorelease] index:0 highlighted:YES];
        s_placedDisplayTab = s_placedDisplayView.tabs[0];
    }
}

+ (instancetype)sharedPlacedDisplayViewWithTitle:(NSString*)title
{
    s_placedDisplayTab.tempTitle = title;
    return s_placedDisplayView;
}

- (instancetype)initWithHandler:(LayoutHandler *)handler
{
    self = [super initWithHandler:handler];
    if(self) {
        _insertedTabIndex = -1;
        _tabs = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onViewDidResize:) name:NSViewFrameDidChangeNotification object:nil];
        
        _tabView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, TabbarHeight)] autorelease];
        [self addSubview:_tabView];
        _contentView = [[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
        [self addSubview:_contentView];
        
        [self setWantsLayer:YES];
        [self.layer setBackgroundColor:[[NSColor colorWithRed:.76 green:.76 blue:.76 alpha:1] CGColor]];
        [self.layer setBorderWidth:1];
        [self.layer setBorderColor:[[NSColor colorWithRed:0 green:0 blue:0 alpha:.7] CGColor]];
    }
    return self;
}

- (instancetype)initWithHandler:(LayoutHandler *)handler view:(NSView<TabLayoutContentInterface> *)view
{
    self = [self initWithHandler:handler];
    if(self) {
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
        [_contentView setFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-TabbarHeight)];
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

- (BOOL)checkDragSenderIsSelf:(LayoutDragEvent *)event
{
    return event.sender == self && _tabs.count <= 1;
}

-(NSView*)getPlacedDisplayView
{
    return [TabLayoutView sharedPlacedDisplayViewWithTitle:_draggingTab.tabTitle];
}

- (NSArray*)tabs
{
    return _tabs;
}

- (void)setSelectedTab:(TabLayoutViewTab *)tab
{
    if (tab != _selectedTab) {
        _selectedTab.highlighted = NO;
        [_selectedTab.contentView removeFromSuperview];
        
        _selectedTab = tab;
        _selectedTab.highlighted = YES;
        [_contentView addSubview:_selectedTab.contentView];
        [_selectedTab.contentView setFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height-_tabView.frame.size.height)];
    }
}

- (void)setDraggingTab:(TabLayoutViewTab *)draggingTab
{
    if (draggingTab != _draggingTab) {
        _draggingTab = draggingTab;
        [self formatTabs];
    }
}

- (void)setTempInsertedTabIndex:(NSInteger)index
{
    if (index != _insertedTabIndex) {
        _insertedTabIndex = index;
        [self formatTabs];
    }
}

- (void)insertContentView:(NSView<TabLayoutContentInterface> *)view index:(NSInteger)index highlighted:(BOOL)highlighted
{
    if (view == nil || index<0 || index>_tabs.count) {
        //TODO  error
        return;
    }
    TabLayoutViewTab* tab = [[[TabLayoutViewTab alloc] initWithContentView:view] autorelease];
    tab.delegate = self;
    [_tabs insertObject:tab atIndex:index];
    [_tabView addSubview:tab];
    
    if (highlighted == YES) {
        [self setSelectedTab:tab];
    }
    [self formatTabs];
    [self.window resetCursorRects];//protect cursor rects error
}

- (void)removeTab:(TabLayoutViewTab *)tab
{
    if (![_tabs containsObject:tab]) {
        //TODO not sub tab
        return;
    }
    
    [tab retain];
    [tab removeFromSuperview];
    [_tabs removeObject:tab];
    if (tab == _selectedTab && _tabs.count > 0) {
        [self setSelectedTab:_tabs[0]];
    }
    [self formatTabs];
    [tab release];
}

- (void)reorderTab:(TabLayoutViewTab *)tab index:(NSInteger)index highlighted:(BOOL)highlighted
{
    NSInteger oldIdx = [_tabs indexOfObject:tab];
    [_tabs insertObject:tab atIndex:index];
    if (oldIdx < index) {
        [_tabs removeObjectAtIndex:oldIdx];
    }
    else {
        [_tabs removeObjectAtIndex:oldIdx+1];
    }
    
    if (highlighted == YES) {
        [self setSelectedTab:tab];
    }
}

- (void)formatTabs
{
    NSSize tabSize = [self getTabSize];
    for (int i=0; i<_tabs.count; i++) {
        NSInteger displayIdx = [self getTabDisplayIndex:_tabs[i]];
        if(displayIdx != NSNotFound) {
            [_tabs[i] setFrame:NSMakeRect(tabSize.width*displayIdx, 0, tabSize.width, tabSize.height)];
        }
        else {
            [_tabs[i] setFrame:NSZeroRect];
        }
    }
}

- (NSSize)getTabSize
{
    NSInteger count = _tabs.count;
    if (_draggingTab != nil) {
        count--;
    }
    return  NSMakeSize(MIN(TabbarNormalWidth, _frame.size.width/(float)count), TabbarHeight);
}

- (NSInteger)getTabDisplayIndex:(TabLayoutViewTab*)tab
{
    if (tab == _draggingTab) {
        return NSNotFound;
    }
    NSInteger displayIndex = [_tabs indexOfObject:tab];
    if (displayIndex == NSNotFound) {
        return displayIndex;
    }
    else {
        if(_draggingTab != nil) {//draggingTab correct
            NSInteger draggingIdx = [_tabs indexOfObject:_draggingTab];
            if (displayIndex > draggingIdx) {
                displayIndex += -1;
            }
        }
        if (_insertedTabIndex != -1) {//insertedTab correct
            if (displayIndex >= _insertedTabIndex) {
                displayIndex += 1;
            }
        }
        return displayIndex;
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
        [self setDraggingTab:sender];
    }
    [_handler handleMouseEvent:self type:LayoutDragStateDraging location:theEvent.locationInWindow];
}

- (void)tabMouseUp:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent
{
    [_handler handleMouseEvent:self type:LayoutDragStateEnd location:theEvent.locationInWindow];
    [self setDraggingTab:nil];
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
    [self setDraggingTab:nil];
    
    TabLayoutView* view = [[[TabLayoutView alloc] initWithHandler:_handler view:contentView] autorelease];
    view.frame = self.bounds;
    
    [self checkRemoveIfNoChild];
    [self.window resetCursorRects];//protect cursor rects error
    return view;
}

- (NSView<TabLayoutContentInterface>*)tabLayoutWillMove
{
    NSView<TabLayoutContentInterface>* contentView = [[_draggingTab.contentView retain] autorelease];
    
    [self removeTab:_draggingTab];
    [self setDraggingTab:nil];
    
    [self checkRemoveIfNoChild];
    [self.window resetCursorRects];//protect cursor rects error
    return contentView;
}

- (void)layoutDragDidCancel
{
    [self setDraggingTab:nil];
}

#pragma mark - layout drag responser
- (NSInteger)checkTabbarAdded:(LayoutView*)target location:(NSPoint)location
{
    NSPoint locationInView = [self convertPoint:location fromView:self.superview];
    if (NSPointInRect(locationInView, _tabView.frame)) {
        NSSize tabSize = [self getTabSize];
        NSInteger insertedIndex = floor((locationInView.x/tabSize.width));
        return MIN(_tabs.count, MAX(0, insertedIndex));
    }
    else {
       return NSNotFound;
    }
}

- (void)onLayoutDragIn
{
}

- (void)onLayoutDragOut
{
    [self setTempInsertedTabIndex:-1];
}

- (BOOL)onLayoutDragMove:(LayoutDragEvent *)event
{
    if([event.sender isKindOfClass:[self class]] == YES) {
        NSInteger idx = [self checkTabbarAdded:event.sender location:event.location];
        if (idx != NSNotFound) {
            [self setTempInsertedTabIndex:idx];
            NSSize tabSize = [self getTabSize];
            NSPoint tabLocation = [self convertPoint:event.location fromView:nil];
            [event.panel placeToView:self frame:NSMakeRect(MIN(self.frame.size.width-tabSize.width,MAX(0,tabLocation.x-tabSize.width/2.0)), _tabView.frame.origin.y, tabSize.width, tabSize.height) contentView:[event.sender getPlacedDisplayView]];
            return YES;
        }
        else {
            [self setTempInsertedTabIndex:-1];
        }
    }
    
    return [super onLayoutDragMove:event];
}

- (BOOL)onLayoutDragEndInside:(LayoutDragEvent *)event
{
    [self setTempInsertedTabIndex:-1];
    if([event.sender isKindOfClass:[self class]] == YES) {
        NSInteger idx = [self checkTabbarAdded:event.sender location:event.location];
        if (idx != NSNotFound) {
            if (event.sender == self) {
                [self reorderTab:_draggingTab index:idx highlighted:YES];
            }
            else {
                NSView<TabLayoutContentInterface>* view = [(TabLayoutView*)event.sender tabLayoutWillMove];
                if (view != nil) {
                    [self insertContentView:view index:idx highlighted:YES];
                }
            }
            return YES;
        }
    }
    
    return [super onLayoutDragEndInside:event];
}

@end
