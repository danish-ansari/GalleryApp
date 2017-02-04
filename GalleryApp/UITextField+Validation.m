//
//  UITextField+Validation.m
//  GalleryApp
//
//  Created by Raees Shaikh on 04/02/17.
//  Copyright © 2017 Danish. All rights reserved.
//

#import "UITextField+Validation.h"

@implementation UITextField (Validation)

-(BOOL) isEmpty{
    if ([self.text isEqualToString:@""]) {
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL) isValidEmail{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self.text];
}


@end
