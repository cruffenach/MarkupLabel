//
//  NSAttributedString_MarkupExtensions.m
//  CoreText
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "NSAttributedString+MarkupExtensions.h"

#import "CMarkupValueTransformer.h"
#import "UIFont+CoreTextExtensions.h"

NSString *const kMarkupBoldAttributeName = @"com.touchcode.bold";
NSString *const kMarkupItalicAttributeName = @"com.touchcode.italic";
NSString *const kMarkupSizeAdjustmentAttributeName = @"com.touchcode.sizeAdjustment";
NSString *const kMarkupFontNameAttributeName = @"com.touchcode.fontName";
NSString *const kMarkupFontSizeAttributeName = @"com.touchcode.fontSize";
NSString *const kMarkupAttachmentAttributeName = @"com.touchcode.attachment";
NSString *const kMarkupOutlineAttributeName = @"com.touchcode.outline";

@implementation NSAttributedString (NSAttributedString_MarkupExtensions)

+ (NSAttributedString *)normalizedAttributedStringForAttributedString:(NSAttributedString *)inAttributedString baseFont:(UIFont *)inBaseFont
    {
    NSMutableAttributedString *theString = [inAttributedString mutableCopy];
    
    [theString enumerateAttributesInRange:(NSRange){ .length = theString.length } options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        UIFont *theFont = inBaseFont;
        CTFontRef theCTFont = (__bridge CTFontRef)attrs[(__bridge NSString *)kCTFontAttributeName];
        if (theCTFont != NULL)
            {
            theFont = [UIFont fontWithCTFont:theCTFont];
            }

        attrs = [self normalizeAttributes:attrs baseFont:theFont];
        [theString setAttributes:attrs range:range];
        }];
    return(theString);
    }

+ (NSDictionary *)normalizeAttributes:(NSDictionary *)inAttributes baseFont:(UIFont *)inBaseFont
    {
    NSMutableDictionary *theAttributes = [inAttributes mutableCopy];
        
    // NORMALIZE ATTRIBUTES
    UIFont *theBaseFont = inBaseFont;
    NSString *theFontName = theAttributes[kMarkupFontNameAttributeName];
    if (theFontName != NULL)
        {
        theBaseFont = [UIFont fontWithName:theFontName size:inBaseFont.pointSize];
        [theAttributes removeObjectForKey:kMarkupFontNameAttributeName];
        }
    
    UIFont *theFont = theBaseFont;
    
    BOOL theBoldFlag = [theAttributes[kMarkupBoldAttributeName] boolValue];
    if (theAttributes[kMarkupBoldAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupBoldAttributeName];
        }

    BOOL theItalicFlag = [theAttributes[kMarkupItalicAttributeName] boolValue];
    if (theAttributes[kMarkupItalicAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupItalicAttributeName];
        }
    
    if (theBoldFlag == YES && theItalicFlag == YES)
        {
        theFont = theBaseFont.boldItalicFont;
        }
    else if (theBoldFlag == YES)
        {
        theFont = theBaseFont.boldFont;
        }
    else if (theItalicFlag == YES)
        {
        theFont = theBaseFont.italicFont;
        }

    if (theAttributes[kMarkupOutlineAttributeName] != NULL)
        {
        [theAttributes removeObjectForKey:kMarkupOutlineAttributeName];
		theAttributes[NSStrokeWidthAttributeName] = @(3.0);
        }

    NSNumber *theSizeValue = theAttributes[kMarkupFontSizeAttributeName];
    if (theSizeValue != NULL)
        {
        CGFloat theSize = [theSizeValue floatValue];
        theFont = [theFont fontWithSize:theSize];
        
        [theAttributes removeObjectForKey:kMarkupFontSizeAttributeName];
        }


    NSNumber *theSizeAdjustment = theAttributes[kMarkupSizeAdjustmentAttributeName];
    if (theSizeAdjustment != NULL)
        {
        CGFloat theSize = [theSizeAdjustment floatValue];
        theFont = [theFont fontWithSize:theFont.pointSize + theSize];
        
        [theAttributes removeObjectForKey:kMarkupSizeAdjustmentAttributeName];
        }

    if (theFont != NULL)
        {
        theAttributes[NSFontAttributeName] = theFont;
//        theAttributes[(__bridge NSString *)kCTFontAttributeName] = (__bridge id)theFont.CTFont;
        }
        
    return(theAttributes);
    }
    
@end
