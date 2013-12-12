//
//  main.m
//  Cocos2D-v2.1-Performance
//
//  Created by Steffen Itterheim on 12/12/13.
//  Copyright Steffen Itterheim 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppController");
    [pool release];
    return retVal;
}
