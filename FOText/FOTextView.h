//
//  FOTextView.h
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOTextView : UIView

@property (nonatomic, strong) NSAttributedString *attString;

@property (nonatomic, assign) BOOL isVertical;

- (CGSize)textBoundingSize;

- (void)setTextAlignment:(int)textAlignment;

@end
