// Generated by Apple Swift version 4.0.2 (swiftlang-900.0.69.2 clang-900.0.38)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_attribute(external_source_symbol)
# define SWIFT_STRINGIFY(str) #str
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name) _Pragma(SWIFT_STRINGIFY(clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in=module_name, generated_declaration))), apply_to=any(function, enum, objc_interface, objc_category, objc_protocol))))
# define SWIFT_MODULE_NAMESPACE_POP _Pragma("clang attribute pop")
#else
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name)
# define SWIFT_MODULE_NAMESPACE_POP
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR __attribute__((enum_extensibility(open)))
# else
#  define SWIFT_ENUM_ATTR
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import UIKit;
@import CoreGraphics;
@import Foundation;
@import ObjectiveC;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

SWIFT_MODULE_NAMESPACE_PUSH("Floaty")
@class FloatyItem;
@class UIColor;
@class UIImage;
@class FloatyManager;
@protocol FloatyDelegate;
@class NSCoder;
@class UIEvent;
@class UITouch;

/// Floaty Object. It has <code>FloatyItem</code> objects.
/// Floaty support storyboard designable.
SWIFT_CLASS("_TtC6Floaty6Floaty")
@interface Floaty : UIView
/// <code>FloatyItem</code> objects.
@property (nonatomic, copy) NSArray<FloatyItem *> * _Nonnull items SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.items' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// This object’s button size.
@property (nonatomic) CGFloat size SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.size' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Padding from bottom right of UIScreen or superview.
@property (nonatomic) CGFloat paddingX SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.paddingX' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGFloat paddingY SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.paddingY' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Automatically closes child items when tapped
@property (nonatomic) BOOL autoCloseOnTap;
/// Degrees to rotate image
@property (nonatomic) CGFloat rotationDegrees;
/// Animation speed of buttons
@property (nonatomic) double animationSpeed;
/// Button color.
@property (nonatomic, strong) UIColor * _Nonnull buttonColor;
/// Button image.
@property (nonatomic, strong) UIImage * _Nullable buttonImage;
/// Plus icon color inside button.
@property (nonatomic, strong) UIColor * _Nonnull plusColor;
/// Background overlaying color.
@property (nonatomic, strong) UIColor * _Nonnull overlayColor;
/// The space between the item and item.
@property (nonatomic) CGFloat itemSpace;
/// Child item’s default size.
@property (nonatomic) CGFloat itemSize;
/// Child item’s default button color.
@property (nonatomic, strong) UIColor * _Nonnull itemButtonColor;
/// Child item’s default title label color.
@property (nonatomic, strong) UIColor * _Nonnull itemTitleColor;
/// Child item’s image color
@property (nonatomic, strong) UIColor * _Nullable itemImageColor;
/// Enable/disable shadow.
@property (nonatomic) BOOL hasShadow;
/// Child item’s default shadow color.
@property (nonatomic, strong) UIColor * _Nonnull itemShadowColor;
///
@property (nonatomic) BOOL closed SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.closed' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Whether or not floaty responds to keyboard notifications and adjusts its position accordingly
@property (nonatomic) BOOL respondsToKeyboard;
@property (nonatomic) BOOL friendlyTap SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.friendlyTap' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL sticky SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.sticky' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) FloatyManager * _Nonnull global SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.global' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");)
+ (FloatyManager * _Nonnull)global SWIFT_WARN_UNUSED_RESULT SWIFT_DEPRECATED_OBJC("Swift property 'Floaty.global' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Delegate that can be used to learn more about the behavior of the FAB widget.
@property (nonatomic, weak) IBOutlet id <FloatyDelegate> _Nullable fabDelegate;
/// Initialize with default property.
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
/// Initialize with custom size.
- (nonnull instancetype)initWithSize:(CGFloat)size OBJC_DESIGNATED_INITIALIZER SWIFT_DEPRECATED_OBJC("Swift initializer 'Floaty.init(size:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Initialize with custom frame.
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
/// Initialize from storyboard.
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
/// Set size and frame.
- (void)drawRect:(CGRect)rect;
/// Items open.
- (void)open SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.open()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Items close.
- (void)close;
/// Items open or close.
- (void)toggle SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.toggle()' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add custom item
- (void)addItemWithItem:(FloatyItem * _Nonnull)item SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(item:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with title.
- (FloatyItem * _Nonnull)addItemWithTitle:(NSString * _Nonnull)title SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(title:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with title and icon.
- (FloatyItem * _Nonnull)addItem:(NSString * _Nonnull)title icon:(UIImage * _Nullable)icon SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(_:icon:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with title and handler.
- (FloatyItem * _Nonnull)addItemWithTitle:(NSString * _Nonnull)title handler:(void (^ _Nonnull)(FloatyItem * _Nonnull))handler SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(title:handler:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with title, icon or handler.
- (FloatyItem * _Nonnull)addItem:(NSString * _Nonnull)title icon:(UIImage * _Nullable)icon handler:(void (^ _Nonnull)(FloatyItem * _Nonnull))handler SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(_:icon:handler:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with icon.
- (FloatyItem * _Nonnull)addItemWithIcon:(UIImage * _Nullable)icon SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(icon:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Add item with icon and handler.
- (FloatyItem * _Nonnull)addItemWithIcon:(UIImage * _Nullable)icon handler:(void (^ _Nonnull)(FloatyItem * _Nonnull))handler SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.addItem(icon:handler:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Remove item.
- (void)removeItemWithItem:(FloatyItem * _Nonnull)item SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.removeItem(item:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Remove item with index.
- (void)removeItemWithIndex:(NSInteger)index SWIFT_DEPRECATED_OBJC("Swift method 'Floaty.removeItem(index:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (UIView * _Nullable)hitTest:(CGPoint)point withEvent:(UIEvent * _Nullable)event SWIFT_WARN_UNUSED_RESULT;
- (void)touchesBegan:(NSSet<UITouch *> * _Nonnull)touches withEvent:(UIEvent * _Nullable)event;
- (void)touchesEnded:(NSSet<UITouch *> * _Nonnull)touches withEvent:(UIEvent * _Nullable)event;
- (void)observeValueForKeyPath:(NSString * _Nullable)keyPath ofObject:(id _Nullable)object change:(NSDictionary<NSKeyValueChangeKey, id> * _Nullable)change context:(void * _Nullable)context;
- (void)willMoveToSuperview:(UIView * _Nullable)newSuperview;
- (void)didMoveToSuperview;
@end






/// Optional delegate that can be used to be notified whenever the user
/// taps on a FAB that does not contain any sub items.
SWIFT_PROTOCOL("_TtP6Floaty14FloatyDelegate_")
@protocol FloatyDelegate
@optional
/// Indicates that the user has tapped on a FAB widget that does not
/// contain any defined sub items.
/// \param fab The FAB widget that was selected by the user.
///
- (void)emptyFloatySelected:(Floaty * _Nonnull)floaty;
- (void)floatyWillOpen:(Floaty * _Nonnull)floaty;
- (void)floatyDidOpen:(Floaty * _Nonnull)floaty;
- (void)floatyWillClose:(Floaty * _Nonnull)floaty;
- (void)floatyDidClose:(Floaty * _Nonnull)floaty;
/// This method has been deprecated. Use floatyWillOpen and floatyDidOpen instead.
- (void)floatyOpened:(Floaty * _Nonnull)floaty;
/// This method has been deprecated. Use floatyWillClose and floatyDidClose instead.
- (void)floatyClosed:(Floaty * _Nonnull)floaty;
@end

@class UILabel;
@class UIImageView;

/// Floating Action Button Object’s item.
SWIFT_CLASS("_TtC6Floaty10FloatyItem")
@interface FloatyItem : UIView
/// This object’s button size.
@property (nonatomic) CGFloat size SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.size' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Button color.
@property (nonatomic, strong) UIColor * _Nonnull buttonColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.buttonColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Title label color.
@property (nonatomic, strong) UIColor * _Nonnull titleColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.titleColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Enable/disable shadow.
@property (nonatomic) BOOL hasShadow SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.hasShadow' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Circle Shadow color.
@property (nonatomic, strong) UIColor * _Nonnull circleShadowColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.circleShadowColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Title Shadow color.
@property (nonatomic, strong) UIColor * _Nonnull titleShadowColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.titleShadowColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// If you touch up inside button, it execute handler.
@property (nonatomic, copy) void (^ _Nullable handler)(FloatyItem * _Nonnull) SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.handler' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGPoint imageOffset SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.imageOffset' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) CGSize imageSize SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.imageSize' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Reference to parent
@property (nonatomic, weak) Floaty * _Nullable actionButton SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.actionButton' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UILabel * _Nonnull titleLabel SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.titleLabel' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Item’s title.
@property (nonatomic, copy) NSString * _Nullable title SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.title' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly, strong) UIImageView * _Nonnull iconImageView SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.iconImageView' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Item’s icon.
@property (nonatomic, strong) UIImage * _Nullable icon SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.icon' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Item’s icon tint color change
@property (nonatomic, strong) UIColor * _Null_unspecified iconTintColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.iconTintColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// itemBackgroundColor change
@property (nonatomic, strong) UIColor * _Nullable itemBackgroundColor SWIFT_DEPRECATED_OBJC("Swift property 'FloatyItem.itemBackgroundColor' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
/// Initialize with default property.
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
/// Set size, frame and draw layers.
- (void)drawRect:(CGRect)rect;
- (void)touchesBegan:(NSSet<UITouch *> * _Nonnull)touches withEvent:(UIEvent * _Nullable)event;
- (void)touchesMoved:(NSSet<UITouch *> * _Nonnull)touches withEvent:(UIEvent * _Nullable)event;
- (void)touchesEnded:(NSSet<UITouch *> * _Nonnull)touches withEvent:(UIEvent * _Nullable)event;
- (nonnull instancetype)initWithFrame:(CGRect)frame SWIFT_UNAVAILABLE;
@end


/// KCFloatingActionButton dependent on UIWindow.
SWIFT_CLASS("_TtC6Floaty13FloatyManager")
@interface FloatyManager : NSObject
@property (nonatomic, readonly, strong) Floaty * _Nonnull button SWIFT_DEPRECATED_OBJC("Swift property 'FloatyManager.button' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic) BOOL rtlMode SWIFT_DEPRECATED_OBJC("Swift property 'FloatyManager.rtlMode' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)show:(BOOL)animated SWIFT_DEPRECATED_OBJC("Swift method 'FloatyManager.show(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)hide:(BOOL)animated SWIFT_DEPRECATED_OBJC("Swift method 'FloatyManager.hide(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)toggle:(BOOL)animated SWIFT_DEPRECATED_OBJC("Swift method 'FloatyManager.toggle(_:)' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
@property (nonatomic, readonly) BOOL hidden SWIFT_DEPRECATED_OBJC("Swift property 'FloatyManager.hidden' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class NSBundle;

/// KCFloatingActionButton dependent on UIWindow.
SWIFT_CLASS("_TtC6Floaty20FloatyViewController")
@interface FloatyViewController : UIViewController
@property (nonatomic, readonly, strong) Floaty * _Nonnull floaty SWIFT_DEPRECATED_OBJC("Swift property 'FloatyViewController.floaty' uses '@objc' inference deprecated in Swift 4; add '@objc' to provide an Objective-C entrypoint");
- (void)viewDidLoad;
@property (nonatomic, readonly) UIStatusBarStyle preferredStatusBarStyle;
- (nonnull instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end



SWIFT_MODULE_NAMESPACE_POP
#pragma clang diagnostic pop
