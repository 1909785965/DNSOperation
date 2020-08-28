//
//  SROperation.m
//  DNSOperation
//
//  Created by SR Zhang on 2020/8/28.
//  Copyright © 2020 SR Zhang. All rights reserved.
//

#import "SROperation.h"

@implementation SROperation

-(void)main{
    
    if (!self.isCancelled) {
        for (int i=0; i<2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"自定义继承NSOperation子类==%@",[NSThread currentThread]);
        }
    }
}

@end
