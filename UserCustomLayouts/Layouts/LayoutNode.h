//
//  LayoutNode.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/15/15.
//
//

#import <Foundation/Foundation.h>
#import "LayoutHandler.h"

typedef enum : NSUInteger {
    LayoutAlignmentVertical = 0b0001,    //1 竖直
    LayoutAlignmentHorizontal = 0b0010,  //2 水平
    LayoutAlignmentUnknow = 0b0011,      //3 未确定
    LayoutAlignmentLeafOnly = 0b0000,    //4 不能有子节点
} LayoutAlignment;

extern const NSSize LayoutMinSize;
extern const CGFloat LayoutSpaceBetween;

@interface LayoutNode : NSObject
{
    NSUInteger _id;
    LayoutHandler* _handler;
    LayoutRootNode* _root;
    NSMutableArray<LayoutNode*>* _subNodes;
    LayoutAlignment _align;
    NSRect _frame;
}

@property (nonatomic, readonly) NSUInteger layoutId;
@property (nonatomic, readonly) LayoutHandler* handler;
@property (nonatomic, assign) LayoutRootNode* root;
@property (nonatomic, assign) LayoutNode* parentNode;
-(NSArray<LayoutNode*>*)subNodes;
@property (nonatomic, readonly) LayoutAlignment align;
@property (nonatomic, assign) NSRect frame;

-(NSSize)minSize;
-(id<LayoutDragResponserDelegate>)responser;

-(instancetype)initWithHandler:(LayoutHandler*)handler;
-(void)relayout;

-(void)addSubNode:(LayoutNode*)node direction:(LayoutRelativeDirection)direction size:(NSSize)size;
-(void)addSubNode:(LayoutNode*)node direction:(LayoutRelativeDirection)direction size:(NSSize)size relativeNode:(LayoutNode*)relativeNode;
-(void)replaceNode:(LayoutNode*)node withNode:(LayoutNode*)newNode;
-(void)removeSubNode:(LayoutNode*)node;
-(void)removeFromParent;

-(void)resizeSubNode:(LayoutNode*)node variation:(CGFloat)variation direction:(LayoutRelativeDirection)direction;//positive variation means zoom in

@end
