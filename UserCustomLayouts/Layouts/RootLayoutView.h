//
//  RootLayoutView.h
//  UserCustomLayouts
//
//  Created by Yanjie Zhang on 16/1/21.
//  Copyright © 2016年 Jason.Zhang. All rights reserved.
//

#import "LayoutView.h"
#import "LayoutNode.h"

@class LayoutRootNode;

@interface RootLayoutResizeRect : NSObject

@property(nonatomic, assign) NSRect rect;
@property(nonatomic, assign) LayoutAlignment align;
@property(nonatomic, assign) LayoutNode* prevNode;
@property(nonatomic, assign) LayoutNode* nextNode;

+(instancetype)resizeRectWithRect:(NSRect)rect align:(LayoutAlignment)align prevNode:(LayoutNode*)prevNode nextNode:(LayoutNode*)nextNode;

@end

@interface RootLayoutView : LayoutView
{
    NSMutableArray<RootLayoutResizeRect*>* _resizeRects;
    BOOL _resizing;
    RootLayoutResizeRect *_mouseDownRect;
    NSPoint _mouseDownRelativeLocation;
}

@property(nonatomic, assign) LayoutRootNode* rootNode;

- (void)resetResizeRects;

@end
