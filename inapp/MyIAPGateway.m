//
//  MyIAPGateway.m
//  Coil Breach
//
//  Created by George Vardikos on 13/02/16.
//  Copyright © 2016 foosol llc. All rights reserved.
//

#import "MyIAPGateway.h"
#import "Constant.h"

@implementation MyIAPGateway

+ (id)sharedInstance {
    static MyIAPGateway *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet *products = [NSSet setWithObject: kProductIdentifiers];
        __instance = [[MyIAPGateway alloc] initWithProductIds: products];
    });
    return __instance;
}

@end


