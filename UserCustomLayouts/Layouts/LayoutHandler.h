//
//  LayoutHandler.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/15/15.
//
//

#import <Foundation/Foundation.h>
#import "LayoutDef.h"
#import "LayoutView.h"
#import "TabLayoutView.h"

@class LayoutNode;
@class LayoutRootNode;
@class LayoutContentNode;
@class LayoutDraggingPanel;

@interface LayoutDragEvent : NSObject

@property(nonatomic, assign) LayoutView* sender;
@property(nonatomic, assign) NSPoint location;//location in rootView
@property(nonatomic, assign) NSPoint locationInScreen;//location in screen
@property(nonatomic, assign) LayoutDraggingPanel* panel;

+(LayoutDragEvent*)eventWithSender:(LayoutView*)sender location:(NSPoint)location locInScreen:(NSPoint)locInScreen panel:(LayoutDraggingPanel*)panel;

@end

@interface LayoutHandler : NSObject <NSWindowDelegate>
{
    NSMutableArray<LayoutRootNode*>* _rootList;
    NSMutableDictionary<NSNumber*, LayoutContentNode*>* _viewMap;
    
    LayoutDragState _dragState;
    LayoutView* _dragSender;
    LayoutNode* _focusedNode;
    LayoutDraggingPanel* _draggingPanel;
}

- (NSArray<LayoutRootNode*>*)rootList;

-(id)initWithView:(NSView*)view;
-(LayoutRootNode*)firstResponsedRoot;

-(void)handleMouseEvent:(LayoutView*)sender type:(LayoutDragState)type location:(NSPoint) locationInWindow;

-(void)addLayoutView:(LayoutView*)layoutView to:(LayoutView*)targetView direction:(LayoutRelativeDirection)dir size:(NSSize)size;
-(void)addLayoutView:(LayoutView*)layoutView toNode:(LayoutNode*)targetNode direction:(LayoutRelativeDirection)dir size:(NSSize)size relativeNode:(LayoutNode*)relativeNode;
-(void)removeLayoutView:(LayoutView*)layoutView;
- (void)createNewLayoutWindow:(LayoutView *)layoutView location:(NSPoint)locationInScreen;

@end

NS_INLINE NSPoint NSPointFromWindowToScreen(NSWindow* window, NSPoint location) {
    return [window convertRectToScreen:NSMakeRect(location.x, location.y, 0, 0)].origin;
}

NS_INLINE NSPoint NSPointFromScreenToWindow(NSWindow* window, NSPoint location) {
    return [window convertRectFromScreen:NSMakeRect(location.x, location.y, 0, 0)].origin;
}
