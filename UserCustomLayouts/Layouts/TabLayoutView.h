//
//  TabLayoutView.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/16/15.
//
//

#import "LayoutView.h"
#import "TabLayoutContentInterface.h"

@interface TabLayoutView : LayoutView
{
    NSMutableArray<NSView<TabLayoutContentInterface>*>* _contentViews;
}

@end
