//
//  TabLayoutView.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/16/15.
//
//

#import "LayoutView.h"
#import "TabLayoutContentInterface.h"

@class TabLayoutViewTab;

@protocol TabLayoutViewTabDelegate

- (void)tabMouseDown:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent;
- (void)tabMouseDragged:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent;
- (void)tabMouseUp:(TabLayoutViewTab*)sender event:(NSEvent *)theEvent;

@end

@interface TabLayoutViewTab : NSView

@property(nonatomic, retain) NSView<TabLayoutContentInterface>* contentView;
@property(nonatomic, retain) NSString* title;
@property(nonatomic, assign) id<TabLayoutViewTabDelegate> delegate;
@property(nonatomic, assign) BOOL highlighted;
-(NSString*)tabTitle;

- (instancetype)initWithContentView:(NSView<TabLayoutContentInterface>*)view;

@end

@interface TabLayoutView : LayoutView <TabLayoutViewTabDelegate>
{
    NSMutableArray<TabLayoutViewTab*>* _tabs;
    NSView* _tabView;
    TabLayoutViewTab* _selectedTab;
    TabLayoutViewTab* _draggingTab;
}

-(NSArray<TabLayoutViewTab*>*)tabs;
@property(nonatomic, readonly) TabLayoutViewTab* draggingTab;

-(instancetype)initWithHandler:(LayoutHandler*)handler view:(NSView<TabLayoutContentInterface>*)view;

- (void)setSelectedTab:(TabLayoutViewTab*)tab;
- (void)insertContentView:(NSView<TabLayoutContentInterface>*)view index:(NSInteger)index highlighted:(BOOL)highlighted;
- (void)removeTab:(TabLayoutViewTab*)tab;
- (void)reorderTab:(TabLayoutViewTab*)tab index:(NSInteger)index highlighted:(BOOL)highlighted;

- (NSView<TabLayoutContentInterface>*)tabLayoutWillMove;

@end
