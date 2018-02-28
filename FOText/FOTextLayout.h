//
//  FOTextLayout.h
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSInteger,FOTextAlignment) {
    FOTextAlignmentLeft,
    FOTextAlignmentCenter,
    FOTextAlignmentRight
};

@interface FOTextLayout : NSObject

@property (nonatomic, assign) BOOL vertical;

@property (nonatomic, strong, readonly) NSAttributedString *text;

@property (nonatomic, assign, readonly) CGRect textBoundingRect;

@property (nonatomic, assign, readonly) CGSize textBoundingSize;

@property (nonatomic, assign) FOTextAlignment textAlignment;

- (instancetype)initWithText:(NSAttributedString*)text vertical:(BOOL)vertical;

- (void)drawInContext:(CGContextRef)context size:(CGSize)size;


@end
