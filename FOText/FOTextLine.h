//
//  FOTextLine.h
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
typedef NS_ENUM(NSUInteger, FOTextRunGlyphDrawMode) {
    /// No rotate.
    FOTextRunGlyphDrawModeHorizontal = 0,
    
    /// Rotate vertical for single glyph.
    FOTextRunGlyphDrawModeVerticalRotate = 1,
    
    /// Rotate vertical for single glyph, and move the glyph to a better position,
    /// such as fullwidth punctuation.
    FOTextRunGlyphDrawModeVerticalRotateMove = 2,
};


/**
 A range in CTRun, used for vertical form.
 */
@interface FOTextRunGlyphRange : NSObject
@property (nonatomic) NSRange glyphRangeInRun;
@property (nonatomic) FOTextRunGlyphDrawMode drawMode;
+ (instancetype)rangeWithRange:(NSRange)range drawMode:(FOTextRunGlyphDrawMode)mode;
@end


@interface FOTextLine : NSObject

@property (nonatomic, readonly) CTLineRef ctLine;

@property (nonatomic, readonly) NSRange range;

@property (nonatomic, readonly) CGPoint position;

@property (nonatomic, readonly) BOOL vertical;

@property (nonatomic, readonly) CGRect bounds;

@property (nonatomic, readonly) CGFloat ascent;

@property (nonatomic, readonly) CGFloat descent;

@property (nonatomic, readonly) CGFloat leading;

@property (nonatomic, readonly) CGFloat trailingWhitespaceWidth;

@property (nonatomic, readonly) CGFloat lineHeight;

@property (nonatomic, readonly) CGFloat lineWidth;

- (instancetype)initWithCTLine:(CTLineRef)ctLine position:(CGPoint)position vertical:(BOOL)vertical;

@property (nonatomic, strong) NSMutableArray *verticalTextRange;


@end
