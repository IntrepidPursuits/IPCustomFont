#import "UITextView+IPCustomFont.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

static char kIPCustomFontFamilyKey;

@implementation UITextView (IPCustomFont)

- (void)setFontFamily:(NSString *)fontFamily
{
    objc_setAssociatedObject(self, &kIPCustomFontFamilyKey, fontFamily, OBJC_ASSOCIATION_COPY);
}

- (NSString *)fontFamily
{
    return (NSString *)objc_getAssociatedObject(self, &kIPCustomFontFamilyKey);
}

+ (void)load
{
    // Swizzle awakeFromNib
    Class c = [self class];
    SEL orig = @selector(awakeFromNib);
    SEL new = @selector(IPSwizzledAwakeFromNib);
    
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

- (void)IPSwizzledAwakeFromNib
{
    // Swizzled. Not actually infinite recursion.
    [self IPSwizzledAwakeFromNib];
    
    if (self.fontFamily) {
        UIFont *font = [UIFont fontWithName:self.fontFamily size:self.font.pointSize];
        if (font) {
            self.font = font;
        } else {
#if DEBUG
            NSLog(@"Warning: Could not instantiate UIFont with family %@ for %@", self.fontFamily, [self description]);
#endif
        }
    }
}

@end
