//
//  IAPGateway.h
//  Coil Breach
//
//  Created by George Vardikos on 13/02/16.
//  Copyright © 2016 foosol llc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

//constant for NotificationCenter
UIKIT_EXTERN NSString * const IAPGatewayProductPurchased;

typedef void (^IAPGatewayProductsBlock)(BOOL success, NSArray *products);

@interface IAPGateway : NSObject

- (id)initWithProductIds:(NSSet *) productIds;
- (void)fetchProductsWithBlock:(IAPGatewayProductsBlock) block;
- (BOOL)isProductPurchased:(SKProduct *)product;
- (void)purchaseProduct:(SKProduct *)product;

@end
