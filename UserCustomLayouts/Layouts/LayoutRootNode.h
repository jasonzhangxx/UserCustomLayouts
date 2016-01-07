//
//  LayoutRootNode.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutNode.h"

@interface LayoutRootNode : LayoutNode<LayoutDragResponserDelegate>

@property(nonatomic, assign) BOOL autoRemovedWhenEmpty;
@property(nonatomic, readonly) NSView* view;
@property(nonatomic, readonly) LayoutNode* virtualNode;

-(instancetype)initWithHandler:(LayoutHandler*)handler view:(NSView*)view;

@end
