//
//  LayoutNode.m
//  CXMakerJS
//
//  Created by Jason.Zhang on 12/15/15.
//
//

#import "LayoutNode.h"
#import "LayoutHandler.h"
#import "LayoutRootNode.h"

@implementation LayoutNode

const NSSize LayoutMinSize = {80, 80};
const CGFloat LayoutSpaceBetween = 4;

static NSUInteger layoutIdx = 0;

- (NSString*)description
{
    NSMutableString* des = [NSMutableString stringWithString:@"{"];
    [des appendFormat:@"\"id\": \"%lu\",",(unsigned long)_id];
    [des appendFormat:@"\"type\": \"%@\",",[self class]];
    [des appendFormat:@"\"root\": \"%lu\",",(unsigned long)_root.layoutId];
    [des appendFormat:@"\"frame\": \"%@\",",NSStringFromRect(_frame)];
    [des appendFormat:@"\"align\": %lu,",(unsigned long)_align];
    [des appendString:@"\"subNodes\": ["];
    [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [des appendFormat:(idx==0?@"%@":@",%@"), obj.description];
    }];
    [des appendString:@"]}"];
    return des;
}

@synthesize layoutId = _id;
@synthesize handler = _handler;
@synthesize root = _root;
@synthesize align = _align;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _id = layoutIdx++;
        _subNodes = [[NSMutableArray alloc] init];
        _align = LayoutAlignmentUnknow;
    }
    return self;
}

- (instancetype)initWithHandler:(LayoutHandler *)handler
{
    self = [self init];
    if (self) {
        _handler = handler;
    }
    return self;
}

- (void)dealloc
{
    [_subNodes release];
    [super dealloc];
}

- (NSArray<LayoutNode*>*)subNodes
{
    return (NSArray*)_subNodes;
}

- (NSSize)minSize
{
    if (_subNodes.count == 0) {
        return LayoutMinSize;
    }
    else {
        __block NSSize size = NSZeroSize;
        if (_align == LayoutAlignmentVertical) {
            [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSSize s = obj.minSize;
                if (s.width > size.width) {
                    size.width = s.width;
                }
                size.height += s.height;
            }];
            size.height += (_subNodes.count-1)*LayoutSpaceBetween;
        }
        else if (_align == LayoutAlignmentHorizontal) {
            [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSSize s = obj.minSize;
                if (s.height > size.height) {
                    size.height = s.height;
                }
                size.width += s.width;
            }];
            size.width += (_subNodes.count-1)*LayoutSpaceBetween;
        }
        else {
            size = _subNodes[0].minSize;
        }
        
        if(size.width<LayoutMinSize.width) size.width=LayoutMinSize.width;
        if(size.height<LayoutMinSize.height) size.height=LayoutMinSize.height;
        return size;
    }
}

- (id<LayoutDragResponserDelegate>)responser
{
    return nil;
}

- (void)setRoot:(LayoutRootNode *)root
{
    _root = root;
    [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.root = root;
    }];
}

- (void)setFrame:(NSRect)frame
{
    if (NSEqualRects(frame, _frame) == NO) {
        _frame = frame;
        [self relayout];
    }
}

- (void)addSubNode:(LayoutNode *)node direction:(LayoutRelativeDirection)direction size:(NSSize)size
{
    [self addSubNode:node direction:direction size:size relativeNode:nil];
}

- (void)addSubNode:(LayoutNode *)node direction:(LayoutRelativeDirection)direction size:(NSSize)size relativeNode:(LayoutNode *)relativeNode
{
    NSAssert((_align & direction) > 0, @"sub node had to in the same direction");
    
    //add node to subNodes, order by (relativeNode and direction)
    int nodeIdx;
    int stepValue;
    if (relativeNode == nil) {
        if ((direction & 0b0100) > 0) {
            nodeIdx = (int)_subNodes.count;
            stepValue = -1;
        }
        else {
            nodeIdx = 0;
            stepValue = 1;
        }
    }
    else {
        int relativeIdx = (int)[_subNodes indexOfObject:relativeNode];
        NSAssert(relativeIdx != NSNotFound, @"relative node is wrong");
        if ((direction & 0b0100) > 0) {
            nodeIdx = relativeIdx+1;
            stepValue = -1;
        }
        else {
            nodeIdx = relativeIdx;
            stepValue = 1;
        }
    }
    [_subNodes insertObject:node atIndex:nodeIdx];
    node.parentNode = self;
    node.root = self.root;
    //check align changed
    if (_align == LayoutAlignmentUnknow && _subNodes.count > 1) {
        _align = direction & 0b0011;
    }
    //update subNodes frame
    if (_subNodes.count == 1) {
        [_subNodes[0] setFrame:_frame];
    }
    else {
        if (_align == LayoutAlignmentVertical) {
            float height = size.height;
            [_subNodes[nodeIdx] setFrame:NSMakeRect(0, 0, _frame.size.width, height)];
            nodeIdx += stepValue;
            while (nodeIdx>=0 && nodeIdx<_subNodes.count && height>0) {
                LayoutNode* n = _subNodes[nodeIdx];
                NSSize mSize = n.minSize;
                if (n.frame.size.height-height>=mSize.height) {
                    [n setFrame:NSMakeRect(0, 0, n.frame.size.width, n.frame.size.height-height)];
                    height=0;
                }
                else {
                    height -= n.frame.size.height-mSize.height;
                    [n setFrame:NSMakeRect(0, 0, n.frame.size.width, mSize.height)];
                }
                nodeIdx += stepValue;
            }
        }
        else if (_align == LayoutAlignmentHorizontal) {
            float width = size.width;
            [_subNodes[nodeIdx] setFrame:NSMakeRect(0, 0, width, _frame.size.height)];
            nodeIdx += stepValue;
            while (nodeIdx>=0 && nodeIdx<_subNodes.count && width>0) {
                LayoutNode* n = _subNodes[nodeIdx];
                NSSize mSize = n.minSize;
                if (n.frame.size.width-width>=mSize.width) {
                    [n setFrame:NSMakeRect(0, 0, n.frame.size.width-width, n.frame.size.height)];
                    width=0;
                }
                else {
                    width -= n.frame.size.width-mSize.width;
                    [n setFrame:NSMakeRect(0, 0, mSize.width, n.frame.size.height)];
                }
                nodeIdx += stepValue;
            }
        }
        [self relayout];
    }
}

- (void)replaceNode:(LayoutNode *)node withNode:(LayoutNode *)newNode
{
    NSUInteger idx = [_subNodes indexOfObject:node];
    if (idx != NSNotFound) {
        [_subNodes replaceObjectAtIndex:idx withObject:newNode];
        [newNode setFrame:node.frame];
        node.parentNode = nil;
        node.root = nil;
        newNode.parentNode = self;
        newNode.root = _root;
    }
}

- (void)removeSubNode:(LayoutNode *)node
{
    node.parentNode = nil;
    node.root = nil;
    [_subNodes removeObject:node];
    if (_align != LayoutAlignmentUnknow && _subNodes.count <= 1) {
        _align = LayoutAlignmentUnknow;
    }
    [self relayout];
}

- (void)removeFromParent
{
    [self.parentNode removeSubNode:self];
}

- (void)resizeSubNodeWithIndex:(int)index expandVariation:(CGFloat)variation pace:(int)pace isHorizontal:(BOOL)isHorizontal
{
//    NSLog(@"index: %d variation: %f pace: %d",index,variation,pace);
    if (index<0 || index>=_subNodes.count) {
        //TODO error check
        return;
    }
    
    if (variation<0) {//zoom out node = zoom in next node
        [self resizeSubNodeWithIndex:index+pace expandVariation:-variation pace:-pace isHorizontal:isHorizontal];
        return;
    }
    
    CGFloat remind = variation;
    CGFloat realChanged = 0;
    if (isHorizontal == YES) {
        for (int i=index+pace; i>=0 && i<_subNodes.count; i+=pace) {
            LayoutNode* n = _subNodes[i];
            NSSize mSize = n.minSize;
            if (n.frame.size.width-mSize.width>=remind) {
                [n setFrame:NSMakeRect(0, 0, n.frame.size.width-remind, n.frame.size.height)];
                realChanged += remind;
                break;
            }
            else {
                CGFloat changed = n.frame.size.width-mSize.width;
                [n setFrame:NSMakeRect(0, 0, mSize.width, n.frame.size.height)];
                realChanged += changed;
                remind -= changed;
            }
        }
        [_subNodes[index] setFrame:NSMakeRect(0, 0, _subNodes[index].frame.size.width+realChanged, _subNodes[index].frame.size.height)];
    }
    else {//vertical
        for (int i=index+pace; i>=0 && i<_subNodes.count; i+=pace) {
            LayoutNode* n = _subNodes[i];
            NSSize mSize = n.minSize;
            if (n.frame.size.height-mSize.height>=remind) {
                [n setFrame:NSMakeRect(0, 0, n.frame.size.width, n.frame.size.height-remind)];
                realChanged += remind;
                break;
            }
            else {
                [n setFrame:NSMakeRect(0, 0, n.frame.size.width, mSize.height)];
                realChanged += (n.frame.size.height-mSize.height);
                remind -= (n.frame.size.height-mSize.height);
            }
        }
        [_subNodes[index] setFrame:NSMakeRect(0, 0, _subNodes[index].frame.size.width, _subNodes[index].frame.size.height+realChanged)];
    }
}

- (void)resizeSubNode:(LayoutNode *)node variation:(CGFloat)variation direction:(LayoutRelativeDirection)direction
{
    if (variation == 0) {
        return;
    }
    if ((direction & _align) <= 0) {
        //TODO error check
        return;
    }
    int idx = (int)[_subNodes indexOfObject:node];
    if (idx == NSNotFound) {
        //TODO error check
        return;
    }
    
    switch (direction) {
        case LayoutRelativeDirectionLeft: {
            [self resizeSubNodeWithIndex:idx expandVariation:variation pace:-1 isHorizontal:YES];
            break;
        }
        case LayoutRelativeDirectionRight: {
            [self resizeSubNodeWithIndex:idx expandVariation:variation pace:1 isHorizontal:YES];
            break;
        }
        case LayoutRelativeDirectionBottom: {
            [self resizeSubNodeWithIndex:idx expandVariation:variation pace:-1 isHorizontal:NO];
            break;
        }
        case LayoutRelativeDirectionTop: {
            [self resizeSubNodeWithIndex:idx expandVariation:variation pace:1 isHorizontal:NO];
            break;
        }
        default:
            break;
    }
    [self relayout];
}

- (void)relayout
{
    if (_root==nil) return;
    switch (_align) {
        case LayoutAlignmentUnknow:
        {
            if (_subNodes.count>0) {
                [_subNodes[0] setFrame:_frame];
            }
            break;
        }
        case LayoutAlignmentVertical:
        {
            __block CGFloat totalHeight = 0;
            [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                totalHeight += obj.frame.size.height;
            }];
            CGFloat newHeight = _frame.size.height - (_subNodes.count-1)*LayoutSpaceBetween;
            NSPoint origin = _frame.origin;
            for (int i=0; i<_subNodes.count; i++) {
                LayoutNode* obj = _subNodes[i];
                float height;
                if (i==_subNodes.count-1) {//correct deviation
                    height = _frame.origin.y+_frame.size.height-origin.y;
                }
                else {
                    height = obj.frame.size.height/totalHeight*newHeight;
                }
                NSSize minSize = obj.minSize;
                if (height < minSize.height) {
                    height = minSize.height;
                }
                NSRect rect = NSMakeRect(origin.x, origin.y, _frame.size.width, height);
                [_subNodes[i] setFrame:rect];
                origin.y += height+LayoutSpaceBetween;
            }
            break;
        }
        case LayoutAlignmentHorizontal:
        {
            __block CGFloat totalWidth = 0;
            [_subNodes enumerateObjectsUsingBlock:^(LayoutNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                totalWidth += obj.frame.size.width;
            }];
            CGFloat newWidth = _frame.size.width - (_subNodes.count-1)*LayoutSpaceBetween;
            NSPoint origin = _frame.origin;
            for (int i=0; i<_subNodes.count; i++) {
                LayoutNode* obj = _subNodes[i];
                float width;
                if (i==_subNodes.count-1) {//correct deviation
                    width = _frame.origin.x+_frame.size.width-origin.x;
                }
                else {
                    width = obj.frame.size.width/totalWidth*newWidth;
                }
                NSSize minSize = obj.minSize;
                if (width < minSize.width) {
                    width = minSize.width;
                }
                NSRect rect = NSMakeRect(origin.x, origin.y, width, _frame.size.height);
                [_subNodes[i] setFrame:rect];
                origin.x += width+LayoutSpaceBetween;
            }
            break;
        }
        default:
            break;
    }
}

@end
