/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
//#import "CCDirectorExtensions.h"


/** @file ccMoreTypes.h - Adding some missing type declarations and helpers that are not in ccTypes.h */


/** Quick and dirty rectangle drawing. Should be improved to render a triangle strip instead. */
static inline void ccDrawRect(CGRect rect);
static inline void ccDrawRect(CGRect rect)
{
	CGPoint pt1 = rect.origin;
	CGPoint pt2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
	CGPoint pt3 = CGPointMake(pt2.x, rect.origin.y + rect.size.height);
	CGPoint pt4 = CGPointMake(rect.origin.x, pt3.y);
	ccDrawLine(pt1, pt2);
	ccDrawLine(pt2, pt3);
	ccDrawLine(pt3, pt4);
	ccDrawLine(pt4, pt1);
}

/** creates and returns a ccColor4F struct */
static inline ccColor4F ccc4f(const GLfloat r, const GLfloat g, const GLfloat b, const GLfloat o)
{
	ccColor4F c = {r, g, b, o};
	return c;
}

//! Cyan Color (0,255,255)
static const ccColor3B ccCYAN = {0,255,255};

/** creates and returns a ccBlendFunc struct */
static inline ccBlendFunc ccBlendFuncMake(GLenum src, GLenum dst)
{
	ccBlendFunc blendFunc = {src, dst};
	return blendFunc;
}
