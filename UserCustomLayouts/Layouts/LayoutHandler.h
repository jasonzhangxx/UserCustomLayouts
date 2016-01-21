//
//  LayoutHandler.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/15/15.
//
//

#import <Foundation/Foundation.h>
#import "LayoutDraggingPanel.h"

@class LayoutNode;
@class LayoutRootNode;
@class LayoutContentNode;
@class LayoutView;

typedef enum : NSUInteger {
    LayoutDragStateBegin = 0,
    LayoutDragStateDraging = 1,
    LayoutDragStateEnd = 2,
    LayoutDragStateCancel = 3,
    LayoutDragStateUnkown = -1,
} LayoutDragState;

typedef enum : NSUInteger {
    LayoutRelativeDirectionNone = -1,
    LayoutRelativeDirectionBottom = 0b0001,     //1
    LayoutRelativeDirectionLeft = 0b0010,   //2
    LayoutRelativeDirectionTop = 0b0101,  //5
    LayoutRelativeDirectionRight = 0b0110,    //6
} LayoutRelativeDirection;

@interface LayoutDragEvent : NSObject

@property(nonatomic, assign) LayoutView* sender;
@property(nonatomic, assign) NSPoint location;//location in rootView
@property(nonatomic, assign) NSPoint locationInScreen;//location in screen
@property(nonatomic, assign) LayoutDraggingPanel* panel;

+(LayoutDragEvent*)eventWithSender:(LayoutView*)sender location:(NSPoint)location locInScreen:(NSPoint)locInScreen panel:(LayoutDraggingPanel*)panel;

@end

@protocol LayoutDragSenderDelegate

- (LayoutView*)layoutWillMove;

@optional
- (void)layoutDragDidBegin;
- (void)layoutDragDidDragging;
- (void)layoutDragDidEnd;
- (void)layoutDragDidCancel;

@end

@protocol LayoutDragResponserDelegate

- (void)onLayoutDragIn;
- (void)onLayoutDragOut;
- (BOOL)onLayoutDragMove:(LayoutDragEvent*)event;
- (BOOL)onLayoutDragEndInside:(LayoutDragEvent*)event;

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
