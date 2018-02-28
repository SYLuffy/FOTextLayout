//
//  FOTextView.m
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import "FOTextView.h"
#import "FOTextLayout.h"

@interface FOTextView ()

@property (nonatomic, strong) FOTextLayout *textLayout;

@end

@implementation FOTextView

- (void)drawRect:(CGRect)rect{
    [self.textLayout drawInContext:UIGraphicsGetCurrentContext() size:self.bounds.size];
}

- (void)setAttString:(NSAttributedString *)attString{
    
    _attString = attString;
    [self updateLayout];
}


- (void)updateLayout{
    
    //计算文本 在布局之后的 范围
    self.textLayout = [[FOTextLayout alloc] initWithText:self.attString vertical:self.isVertical];
    
    //每次排版之后，要重设view的大小
    self.frame = CGRectMake(0, 30, self.textLayout.textBoundingSize.width, self.textLayout.textBoundingSize.height);
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (CGSize)textBoundingSize{
    
    return self.textLayout.textBoundingSize;
}


#pragma mark -- Getter and Setter
- (void)setTextAlignment:(int)textAlignment{
    if(self.textLayout.textAlignment != textAlignment){
        self.textLayout.textAlignment = textAlignment;
        [self setNeedsDisplay];
    }
}

- (void)setIsVertical:(BOOL)isVertical{
    
    if(isVertical != _isVertical){
        _isVertical = isVertical;
        [self updateLayout];
    }
}



@end
