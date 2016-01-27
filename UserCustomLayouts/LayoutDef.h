//
//  LayoutDelegateDef.h
//  UserCustomLayouts
//
//  Created by Jason.Zhang on 1/27/16.
//  Copyright © 2016 Jason.Zhang. All rights reserved.
//

#ifndef LayoutDelegateDef_h
#define LayoutDelegateDef_h

@class LayoutView;
@class LayoutDragEvent;

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

#endif /* LayoutDelegateDef_h */
