//
//  LayoutRootNode.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutNode.h"

@class RootLayoutView;

@interface LayoutRootNode : LayoutNode
{
    RootLayoutView* _rootView;
}

@property(nonatomic, assign) BOOL autoRemovedWhenEmpty;
@property(nonatomic, readonly) NSView* containerView;
-(NSWindow*)containerWindow;
@property(nonatomic, readonly) LayoutNode* virtualNode;

-(instancetype)initWithHandler:(LayoutHandler*)handler view:(NSView*)view;

- (void)resetResizeRects;

@end
