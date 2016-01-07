//
//  LayoutView.h
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/19/15.
//
//

#import <Cocoa/Cocoa.h>
#import "LayoutHandler.h"

@class LayoutDragEvent;

extern const float LayoutPlacedInitializeProportion;

@interface LayoutView : NSView <LayoutDragSenderDelegate, LayoutDragResponserDelegate>
{
    NSUInteger _id;
    
    BOOL _resizing;
    NSPoint _mouseDownRelativeLocation;
    LayoutRelativeDirection _resizeDirection;
}

@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, assign) LayoutHandler* handler;

-(instancetype)initWithHandler:(LayoutHandler*)handler;

-(NSSize)layoutMinSize;

@end
