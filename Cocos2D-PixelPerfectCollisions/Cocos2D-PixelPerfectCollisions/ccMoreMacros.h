/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Availability.h>

/** @file ccMoreMacros.h - Adding some missing preprocessor macros that are not in ccMacros.h
 
 Defines the following macros depending on the build architecture:
 - KK_PLATFORM_IOS
 - KK_PLATFORM_IOS_DEVICE
 - KK_PLATFORM_IOS_SIMULATOR
 - KK_PLATFORM_MAC
 .
 */

#if __IPHONE_OS_VERSION_MAX_ALLOWED
#define KK_PLATFORM_IOS 1

#if TARGET_IPHONE_SIMULATOR
#define KK_PLATFORM_IOS_SIMULATOR 1
#else
#define KK_PLATFORM_IOS_DEVICE 1
#endif // TARGET_IPHONE_SIMULATOR

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED

// Mac OS X
#if __MAC_OS_X_VERSION_MAX_ALLOWED
#define KK_PLATFORM_MAC 1
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED
