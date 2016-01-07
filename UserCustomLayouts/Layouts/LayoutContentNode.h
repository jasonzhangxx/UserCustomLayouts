//
//  LayoutContentNode.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import "LayoutNode.h"

@class LayoutView;

@interface LayoutContentNode : LayoutNode

@property (nonatomic, readonly) LayoutView* view;

-(instancetype)initWithHandler:(LayoutHandler*)handler view:(LayoutView*)view;

@end
