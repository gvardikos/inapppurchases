//
//  IAPGateway.m
//  Coil Breach
//
//  Created by George Vardikos on 13/02/16.
//  Copyright © 2016 foosol llc. All rights reserved.
//

#import "IAPGateway.h"

//constant for NotificationCenter
NSString * const IAPGatewayProductPurchased = @"IAPGatewayProductPurchased";


@interface IAPGateway() <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, copy) NSSet *productIds;
@property (nonatomic, copy) IAPGatewayProductsBlock callback;
@end


@implementation IAPGateway

- (id)initWithProductIds:(NSSet *) productIds {
    self = [super init];
    if (self) {
        self.productIds = productIds;

        //register self as the observer (for delegate <SKPAymentTransaction>)
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void) fetchProductsWithBlock:(IAPGatewayProductsBlock) block {
    self.callback = block;
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: self.productIds];
    request.delegate = self;
    [request start];
}

/*
 * Returns a BOOL: If the purchase-product has been purchased returns 'true'
 */
- (BOOL) isProductPurchased:(SKProduct *) product {
    return [[NSUserDefaults standardUserDefaults] boolForKey:product.productIdentifier];
}

#pragma mark -
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *product in response.products) {
        NSLog(@"Found the product: %@ %@ %@", product.localizedTitle, product.localizedDescription, product.price);
    }
    self.callback(YES, response.products);
}

/*
 * Add the payment to the queue: If the app crash the purchase will continue
 */
- (void)purchaseProduct:(SKProduct *)productA {
    SKPayment *payment = [SKPayment paymentWithProduct:productA];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

/*
 * If the request fails:
 */
- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    self.callback(NO,nil);
}


- (void) requestDidFinish:(SKRequest *)request {
    //for error handling
}



#pragma mark - transaction observer
/*
 * Store in NSUserDefaults the productIdentifier for knowing later that it has been purchased.
 * Post the notification to the center to remove the adBanner
 * Should an Observer be registered to the root ViewController (where the adBanner is)
 */
- (void)markProductAsPurchased:(NSString *) productIdentifier {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPGatewayProductPurchased object:productIdentifier];
}

/*
 * Check the PaymentTransaction queue Array to track the 'state' of the transaction. If the 'state' is Purchased, Restore, Fail, etc.
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self markProductAsPurchased:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction failed %@", transaction.error.localizedDescription);
                //raise a notification
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self markProductAsPurchased:transaction.originalTransaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
