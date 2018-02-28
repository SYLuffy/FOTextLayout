//
//  FOTextLayout.m
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import "FOTextLayout.h"

#import "FOTextLine.h"

#import "FOTextUtilities.h"

/**
 Sometimes CoreText may convert CGColor to UIColor for `kCTForegroundColorAttributeName`
 attribute in iOS7. This should be a bug of CoreText, and may cause crash. Here's a workaround.
 */
static CGColorRef FOTextGetCGColor(CGColorRef color) {
    static UIColor *defaultColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultColor = [UIColor blackColor];
    });
    if (!color) return defaultColor.CGColor;
    if ([((__bridge NSObject *)color) respondsToSelector:@selector(CGColor)]) {
        return ((__bridge UIColor *)color).CGColor;
    }
    return color;
}

@interface FOTextLayout()

@property (nonatomic, strong) NSMutableArray *textLines;

@property (nonatomic, readwrite) CTFramesetterRef ctFrameSetter;

@property (nonatomic, readwrite) CTFrameRef ctFrame;

@property (nonatomic, assign) CGSize constraintSize;


@end

@implementation FOTextLayout

- (instancetype)initWithText:(NSAttributedString *)text vertical:(BOOL)vertical{
    self = [super init];
    if(self){
        _text = text.mutableCopy;
        _vertical = vertical;
        _textAlignment = FOTextAlignmentLeft;
        _constraintSize = CGSizeMake(100000, 100000);
        [self layout];
    }
    return self;
}


- (void)layout{
    if (!self.text)
        return;
    CGRect cgPathBox = CGRectMake(0, 0, _constraintSize.width, _constraintSize.height);
    CGRect pathRect = CGRectApplyAffineTransform(cgPathBox, CGAffineTransformMakeScale(1, -1));
    CGPathRef cgPath = CGPathCreateWithRect(pathRect, NULL);
    
    NSDictionary* frameAttrs = nil;
    if(self.vertical){
        frameAttrs = @{(NSString *)kCTFrameProgressionAttributeName:@(kCTFrameProgressionRightToLeft)};
    }
    CTFramesetterRef ctSetter= CTFramesetterCreateWithAttributedString((CFTypeRef)self.text);
//    if(!ctSetter){
//        goto fail;
//    }
//    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctSetter, CFRangeMake(0, 0), cgPath, (CFTypeRef)frameAttrs);
//    if(!ctFrame){
//        goto fail;
//    }
    self.textLines = [[NSMutableArray alloc] init];
    
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    
    NSUInteger lineCount = CFArrayGetCount(ctLines);
    
    CGSize textBoundingSize = CGSizeZero;
    CGRect textBoundingRect = CGRectZero;
    
    CGPoint lineOrigins[lineCount];
    
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, lineCount), lineOrigins);
    
    for (NSUInteger i = 0; i < lineCount;  i ++) {
        CTLineRef ctLine = CFArrayGetValueAtIndex(ctLines, i);
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        
        if (!ctRuns || CFArrayGetCount(ctRuns) == 0)
            continue;
        ///the coordinate of CoreText
        CGPoint lineOrigin = lineOrigins[i];
        ///the coordinate of UIKit
        CGPoint position;
        position.x = cgPathBox.origin.x + lineOrigin.x;
        position.y = cgPathBox.size.height + cgPathBox.origin.y - lineOrigin.y;
        FOTextLine* foLine = [[FOTextLine alloc] initWithCTLine:ctLine position:position vertical:self.vertical];
        [self.textLines addObject:foLine];
        if (i == 0)
            textBoundingRect = foLine.bounds;
        else
            textBoundingRect = CGRectUnion(textBoundingRect, foLine.bounds);
    }
    { // calculate bounding size
        CGRect rect = textBoundingRect;
        
        rect = CGRectStandardize(rect);
        CGSize size = rect.size;
        if (self.vertical) {
            size.width += cgPathBox.size.width - (rect.origin.x + rect.size.width);
        } else {
            size.width += rect.origin.x;
        }
        size.height += rect.origin.y;
        if (size.width < 0) size.width = 0;
        if (size.height < 0) size.height = 0;
        size.width = ceil(size.width);
        size.height = ceil(size.height);
        textBoundingSize = size;
    }
    
    if(self.vertical){
        ////// vertical text /////
        NSCharacterSet *rotateCharset = FOTextVerticalRotateCharacterSet();
        NSCharacterSet *rotateMoveCharset = FOTextVerticalRotateAndMoveCharacterSet();
        
        for (FOTextLine* line in self.textLines) {
            [self handleVerticalLines:line rotateCharset:rotateCharset rotateMoveCharset:rotateMoveCharset];
        }
    }
    
    _textBoundingRect = textBoundingRect;
    _textBoundingSize = textBoundingSize;
    
    self.ctFrameSetter = ctSetter;
    self.ctFrame = ctFrame;
    
    CFRelease(cgPath);
    CFRelease(ctSetter);
    CFRelease(ctFrame);
    
//fail:
//    if (cgPath) CFRelease(cgPath);
//    if (ctSetter) CFRelease(ctSetter);
//    if (ctFrame) CFRelease(ctFrame);
}

- (void)handleVerticalLines:(FOTextLine*)line rotateCharset:(NSCharacterSet*)rotateCharset rotateMoveCharset:(NSCharacterSet*)rotateMoveCharset{
    CFArrayRef runs = CTLineGetGlyphRuns(line.ctLine);
    if (!runs)
        return;
    NSUInteger runCount = CFArrayGetCount(runs);
    if (runCount == 0) return;
    NSMutableArray *lineRunRanges = [NSMutableArray new];
    line.verticalTextRange = lineRunRanges;
    for (NSUInteger r = 0; r < runCount; r++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, r);
        NSMutableArray *runRanges = [[NSMutableArray alloc] init];
        [lineRunRanges addObject:runRanges];
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount == 0)
            continue;
        
        CFIndex runStrIdx[glyphCount + 1];
        CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
        CFRange runStrRange = CTRunGetStringRange(run);
        runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
        CFDictionaryRef runAttrs = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
        BOOL isColorGlyph = FOTextCTFontContainsColorBitmapGlyphs(font);
        
        NSUInteger prevIdx = 0;
        FOTextRunGlyphDrawMode prevMode = FOTextRunGlyphDrawModeHorizontal;
        NSString *layoutStr = self.text.string;
        for (NSUInteger g = 0; g < glyphCount; g++) {
            BOOL glyphRotate = 0, glyphRotateMove = NO;
            CFIndex runStrLen = runStrIdx[g + 1] - runStrIdx[g];
            if (isColorGlyph) {
                glyphRotate = YES;
            } else if (runStrLen == 1) {
                unichar c = [layoutStr characterAtIndex:runStrIdx[g]];
                glyphRotate = [rotateCharset characterIsMember:c];
                if (glyphRotate) glyphRotateMove = [rotateMoveCharset characterIsMember:c];
            } else if (runStrLen > 1){
                NSString *glyphStr = [layoutStr substringWithRange:NSMakeRange(runStrIdx[g], runStrLen)];
                BOOL glyphRotate = [glyphStr rangeOfCharacterFromSet:rotateCharset].location != NSNotFound;
                if (glyphRotate) glyphRotateMove = [glyphStr rangeOfCharacterFromSet:rotateMoveCharset].location != NSNotFound;
            }
            
            FOTextRunGlyphDrawMode mode = glyphRotateMove ? FOTextRunGlyphDrawModeVerticalRotateMove : (glyphRotate ? FOTextRunGlyphDrawModeVerticalRotate : FOTextRunGlyphDrawModeHorizontal);
            if (g == 0) {
                prevMode = mode;
            } else if (mode != prevMode) {
                FOTextRunGlyphRange *aRange = [FOTextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, g - prevIdx) drawMode:prevMode];
                [runRanges addObject:aRange];
                prevIdx = g;
                prevMode = mode;
            }
        }
        if (prevIdx < glyphCount) {
            FOTextRunGlyphRange *aRange = [FOTextRunGlyphRange rangeWithRange:NSMakeRange(prevIdx, glyphCount - prevIdx) drawMode:prevMode];
            [runRanges addObject:aRange];
        }
    }

}


- (void)drawInContext:(CGContextRef)context size:(CGSize)size{
    
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1, -1);
    
    NSArray *lines = self.textLines;
    
    CGFloat verticalOffset = self.vertical ? (size.width - self.constraintSize.width) : 0;
    
    for (NSUInteger l = 0, lMax = lines.count; l < lMax; l++) {
        FOTextLine *line = lines[l];
        NSArray *lineRunRanges = line.verticalTextRange;
        CGFloat posX = line.position.x + verticalOffset;
        CGFloat posY = size.height - line.position.y;
        CFArrayRef runs = CTLineGetGlyphRuns(line.ctLine);
        for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, r);
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, posX, posY);
//            YYTextDrawRun(line, run, context, size, isVertical, lineRunRanges[r], verticalOffset);
            [self drawLine:line run:run context:context size:size range:[lineRunRanges objectAtIndex:r] verticalOffset:verticalOffset];
        }
    }
    
    CGContextRestoreGState(context);
    
}

- (void)drawLine:(FOTextLine*)line run:(CTRunRef)run context:(CGContextRef)context size:(CGSize)size range:(NSArray *)runRanges verticalOffset:(CGFloat)verticalOffset{
    
    CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
    BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
    
    CFDictionaryRef runAttrs = CTRunGetAttributes(run);
    
    CGFloat alignmentOffset = 0;
    
    if(self.textAlignment == FOTextAlignmentRight){
            alignmentOffset = self.vertical ? (size.height - line.lineHeight): (size.width - line.lineWidth);
            alignmentOffset += line.trailingWhitespaceWidth;
    } else if(self.textAlignment == FOTextAlignmentCenter){
      
            alignmentOffset = self.vertical ? (size.height - line.lineHeight + line.trailingWhitespaceWidth) * 0.5f: (size.width - line.lineWidth + line.trailingWhitespaceWidth) * 0.5f;
            //        alignmentOffset += line.trailingWhitespaceWidth;
    }
    
    NSDictionary *attrs = (id)CTRunGetAttributes(run);
    
    
    NSNumber* kernValue = attrs[NSKernAttributeName];
    
    
    if (!self.vertical) { // draw run
        
        if (!runTextMatrixIsID) {
            CGContextSaveGState(context);
            CGAffineTransform trans = CGContextGetTextMatrix(context);
            CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
        }
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, alignmentOffset, 0);
        
        CTRunDraw(run, context, CFRangeMake(0, 0));
        if (!runTextMatrixIsID) {
            CGContextRestoreGState(context);
        }
        CGContextRestoreGState(context);
    } else {
        
        // draw vertical glyph
        CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
        if (!runFont)
            return;
        NSUInteger glyphCount = CTRunGetGlyphCount(run);
        if (glyphCount <= 0)
            return;
        
        CGGlyph glyphs[glyphCount];
        CGPoint glyphPositions[glyphCount];
        CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
        CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
        
        CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
        fillColor = FOTextGetCGColor(fillColor);
        NSNumber *strokeWidth = CFDictionaryGetValue(runAttrs, kCTStrokeWidthAttributeName);
        
        CGContextSaveGState(context);
        {
            CGContextSetFillColorWithColor(context, fillColor);
            if (strokeWidth == nil || strokeWidth.floatValue == 0) {
                CGContextSetTextDrawingMode(context, kCGTextFill);
            } else {
                CGColorRef strokeColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTStrokeColorAttributeName);
                if (!strokeColor) strokeColor = fillColor;
                CGContextSetStrokeColorWithColor(context, strokeColor);
                CGContextSetLineWidth(context, CTFontGetSize(runFont) * fabs(strokeWidth.floatValue * 0.01));
                if (strokeWidth.floatValue > 0) {
                    CGContextSetTextDrawingMode(context, kCGTextStroke);
                } else {
                    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
                }
            }
            
            
            CFIndex runStrIdx[glyphCount + 1];
            CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
            CFRange runStrRange = CTRunGetStringRange(run);
            runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
            CGSize glyphAdvances[glyphCount];
            CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
            CGFloat ascent = CTFontGetAscent(runFont);
            CGFloat descent = CTFontGetDescent(runFont);
            
            CGPoint zeroPoint = CGPointZero;
            
            for (FOTextRunGlyphRange *oneRange in runRanges) {
                NSRange range = oneRange.glyphRangeInRun;
                NSUInteger rangeMax = range.location + range.length;
                FOTextRunGlyphDrawMode mode = oneRange.drawMode;
                
                for (NSUInteger g = range.location; g < rangeMax; g++) {
                    CGContextSaveGState(context); {
                        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                        
                        if (mode) { // CJK glyph, need rotated
                            // CJK glyph, need rotated
                            CGFloat ofs = (ascent - descent) * 0.5;
                            //This glyph width value, atcually is height value. so when the text is vertical style
                            //the kern acutal is change the font width it means we can't change the x coordinate when kern was changed.
                            CGFloat w = (glyphAdvances[g].width - [kernValue floatValue]) * 0.5;
                            CGFloat w1 = (glyphAdvances[g].width ) * 0.5;
                            
                            CGFloat textPositionY = glyphPositions[g].y;
                            CGFloat textPosiztionX = glyphPositions[g].x;
                            CGFloat differenceW = (w - w1) * 2;
                            if(textPosiztionX > 0 && differenceW > 0){
                                textPosiztionX -= differenceW;
                                textPosiztionX = MAX(0, textPosiztionX);
                            }
                            
                            CGFloat x = line.position.x + verticalOffset + textPositionY + (ofs - w);
                            CGFloat y = -line.position.y + size.height - textPosiztionX - (ofs + w) - alignmentOffset;
                            if (mode == FOTextRunGlyphDrawModeVerticalRotateMove) {
                                x += w;
                                y += w;
                            }
                            CGContextSetTextPosition(context, x, y);
                        } else {
                            CGContextRotateCTM(context, FOTextDegreesToRadians(-90));
                            CGContextSetTextPosition(context,
                                                     line.position.y - size.height + glyphPositions[g].x + alignmentOffset,
                                                     line.position.x + verticalOffset + glyphPositions[g].y);
                        }
                        
                        if (FOTextCTFontContainsColorBitmapGlyphs(runFont)) {
                            CTFontDrawGlyphs(runFont, glyphs + g, &zeroPoint, 1, context);
                        } else {
                            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                            CGContextSetFont(context, cgFont);
                            CGContextSetFontSize(context, CTFontGetSize(runFont));
                            CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                            CGFontRelease(cgFont);
                        }
                    } CGContextRestoreGState(context);
                }
            }
            
        }
        CGContextRestoreGState(context);
    }
}



@end


