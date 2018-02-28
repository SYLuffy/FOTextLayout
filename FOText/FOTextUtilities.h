//
//  FOTextUtilities.h
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
/**
 Whether the font contains color bitmap glyphs.
 
 @discussion Only `AppleColorEmoji` contains color bitmap glyphs in iOS system fonts.
 @param font  A font.
 @return YES: the font contains color bitmap glyphs, NO: the font has no color bitmap glyph.
 */
static inline BOOL FOTextCTFontContainsColorBitmapGlyphs(CTFontRef font) {
    return  (CTFontGetSymbolicTraits(font) & kCTFontTraitColorGlyphs) != 0;
}

/// Convert degrees to radians.
static inline CGFloat FOTextDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
}


@interface FOTextUtilities : NSObject


/**
 Get the character set which should rotate in vertical form.
 @return The shared character set.
 */
NSCharacterSet *FOTextVerticalRotateCharacterSet();

/**
 Get the character set which should rotate and move in vertical form.
 @return The shared character set.
 */
NSCharacterSet *FOTextVerticalRotateAndMoveCharacterSet();



@end
