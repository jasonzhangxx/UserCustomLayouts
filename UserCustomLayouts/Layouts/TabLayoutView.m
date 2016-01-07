//
//  TabLayoutView.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/16/15.
//
//

#import "TabLayoutView.h"

@implementation TabLayoutView

//debug
- (void)drawRect:(NSRect)aRect
{
    [[NSColor redColor] set];
    NSBezierPath *bp = [NSBezierPath bezierPathWithRect:[self bounds]];
    [bp stroke];
    
    NSString* str = [NSString stringWithFormat:@"TabView%lu",(unsigned long)_id];
    [str drawAtPoint:NSZeroPoint withAttributes:nil];
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self) {
        
    }
    return self;
}

- (NSSize)layoutMinSize
{
    __block NSSize size = NSZeroSize;
    [_contentViews enumerateObjectsUsingBlock:^(NSView<TabLayoutContentInterface> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSSize s = obj.layoutMinSize;
        if (s.width > size.width) {
            size.width = s.width;
        }
        if(s.height > size.height) {
            size.height = s.height;
        }
    }];
    return size;
}

@end
