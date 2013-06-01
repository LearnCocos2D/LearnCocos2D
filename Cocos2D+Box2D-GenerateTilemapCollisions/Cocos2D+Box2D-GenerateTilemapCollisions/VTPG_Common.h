#pragma once
// Copyright (c) 2008-2010, Vincent Gable.
// http://vincentgable.com
// https://github.com/VTPG/CommonCode
// based off http://www.dribin.org/dave/blog/archives/2008/09/22/convert_to_nsstring/


// SI: updated to be compatible with Mac OS, and to compile with both C and C++ code


/** @file VTPG_Common.h */

#import <Availability.h>

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

// based off of http://www.dribin.org/dave/blog/archives/2008/09/22/convert_to_nsstring/
static NSString* VTPG_DDToStringFromTypeAndValue(const char* typeCode, void* value);


static inline BOOL TypeCodeIsCharArray(const char* typeCode)
{
	int lastCharOffset = (int)strlen(typeCode) - 1;
	int secondToLastCharOffset = lastCharOffset - 1;

	BOOL isCharArray = typeCode[0] == '[' &&
		typeCode[secondToLastCharOffset] == 'c' && typeCode[lastCharOffset] == ']';
	for (int i = 1; i < secondToLastCharOffset; i++)
	{
		isCharArray = isCharArray && isdigit(typeCode[i]);
	}
	return isCharArray;
}

// since BOOL is #defined as a signed char, we treat the value as
// a BOOL if it is exactly YES or NO, and a char otherwise.
static inline NSString* VTPGStringFromBoolOrCharValue(BOOL boolOrCharvalue)
{
	if (boolOrCharvalue == YES)
	{
		return @"YES";
	}
	if (boolOrCharvalue == NO)
	{
		return @"NO";
	}
	return [NSString stringWithFormat:@"'%c'", boolOrCharvalue];
}

static inline NSString* VTPGStringFromFourCharCodeOrUnsignedInt32(FourCharCode fourcc)
{
	return [NSString stringWithFormat:@"%u ('%c%c%c%c')",
			(unsigned int)fourcc,
			(unsigned int)((fourcc >> 24) & 0xFF),
			(unsigned int)((fourcc >> 16) & 0xFF),
			(unsigned int)((fourcc >> 8) & 0xFF),
			(unsigned int)(fourcc & 0xFF)];
}

static inline NSString* StringFromNSDecimalWithCurrentLocal(NSDecimal dcm)
{
	return NSDecimalString(&dcm, [NSLocale currentLocale]);
}

static inline NSString* VTPG_DDToStringFromTypeAndValue(const char* typeCode, void* value)
{
#define IF_TYPE_MATCHES_INTERPRET_WITH(typeToMatch, func) \
	if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
		return (func)(*(typeToMatch*)value)

#if     TARGET_OS_IPHONE
	IF_TYPE_MATCHES_INTERPRET_WITH(CGPoint, NSStringFromCGPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGSize, NSStringFromCGSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(CGRect, NSStringFromCGRect);
#else
	IF_TYPE_MATCHES_INTERPRET_WITH(NSPoint, NSStringFromPoint);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSSize, NSStringFromSize);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRect, NSStringFromRect);
#endif
	IF_TYPE_MATCHES_INTERPRET_WITH(NSRange, NSStringFromRange);
	IF_TYPE_MATCHES_INTERPRET_WITH(Class, NSStringFromClass);
	IF_TYPE_MATCHES_INTERPRET_WITH(SEL, NSStringFromSelector);
	IF_TYPE_MATCHES_INTERPRET_WITH(BOOL, VTPGStringFromBoolOrCharValue);
	IF_TYPE_MATCHES_INTERPRET_WITH(bool, VTPGStringFromBoolOrCharValue);
	IF_TYPE_MATCHES_INTERPRET_WITH(NSDecimal, StringFromNSDecimalWithCurrentLocal);

#define IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(typeToMatch, formatString) \
	if (strcmp(typeCode, @encode(typeToMatch)) == 0) \
		return [NSString stringWithFormat:(formatString), (*(typeToMatch*)value)]


	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFStringRef, @"%@"); // CFStringRef is toll-free bridged to NSString*
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(CFArrayRef, @"%@");  // CFArrayRef is toll-free bridged to NSArray*
	IF_TYPE_MATCHES_INTERPRET_WITH(FourCharCode, VTPGStringFromFourCharCodeOrUnsignedInt32);
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long long, @"%lld");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned long long, @"%llu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(float, @"%f");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(double, @"%f");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(__unsafe_unretained id, @"%@");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(short, @"%hi");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned short, @"%hu");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(char, @"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned char, @"%u");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(int, @"%i");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(unsigned, @"%u");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long, @"%li");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(long double, @"%Lf"); // WARNING on older versions of OS X, @encode(long double) == @encode(double)

	// C-strings
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(char*, @"%s");
	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(const char*, @"%s");
	if (TypeCodeIsCharArray(typeCode))
	{
		return [NSString stringWithFormat:@"%s", (char*)value];
	}

	IF_TYPE_MATCHES_INTERPRET_WITH_FORMAT(void*, @"(void*)%p");

	// This is a hack to print out CLLocationCoordinate2D, without needing to #import <CoreLocation/CoreLocation.h>
	// A CLLocationCoordinate2D is a struct made up of 2 doubles.
	// We detect it by hard-coding the result of @encode(CLLocationCoordinate2D).
	// We get at the fields by treating it like an array of doubles, which it is identical to in memory.
	if (strcmp(typeCode, "{?=dd}") == 0) // @encode(CLLocationCoordinate2D)
	{
		return [NSString stringWithFormat:@"{latitude=%g,longitude=%g}", ((double*)value)[0], ((double*)value)[1]];
	}

	// we don't know how to convert this typecode into an NSString
	return nil;
} /* VTPG_DDToStringFromTypeAndValue */

// WARNING: if NO_LOG_MACROS is #define-ed, than THE ARGUMENT WILL NOT BE EVALUATED
#ifndef NO_LOG_MACROS

/** logs any variable, struct, array, etc. to the console without having to use formatted strings */
#define LOG_EXPR(_X_) \
	do { \
		__typeof__(_X_) _Y_ = (_X_); \
		const char* _TYPE_CODE_ = @encode(__typeof__(_X_)); \
		NSString* _STR_ = VTPG_DDToStringFromTypeAndValue(_TYPE_CODE_, &_Y_); \
		if (_STR_) { \
			NSLog(@"%s = %@", #_X_, _STR_); } \
		else { \
			NSLog(@"Unknown _TYPE_CODE_: %s for expression %s in function %s, file %s, line %d", _TYPE_CODE_, #_X_, __func__, __FILE__, __LINE__); } \
	} while (0)

#define LOG_NS(...)    NSLog(__VA_ARGS__)
#define LOG_FUNCTION() NSLog(@"%s", __func__)

#else /* NO_LOG_MACROS */

#define LOG_EXPR(_X_)
#define LOG_NS(...)
#define LOG_FUNCTION()
#endif /* NO_LOG_MACROS */


// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing)
{
	return thing == nil ||
		   ([thing respondsToSelector:@selector(length)] && [(NSData*)thing length] == 0) ||
		   ([thing respondsToSelector:@selector(count)]  && [(NSArray*)thing count] == 0);
}
