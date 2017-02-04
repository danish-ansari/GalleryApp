//
//  LoginViewController.m
//  GalleryApp
//
//  Created by Raees Shaikh on 04/02/17.
//  Copyright © 2017 Danish. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UITextField+Validation.m"
#import <CoreData/CoreData.h>
#import "User+CoreDataProperties.h"
#import "AddImageViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong,nonatomic) id delegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _delegate = [[UIApplication sharedApplication] delegate];
    _context = [_delegate getManagedObjecContext];
}
- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Mapping the return key of kayboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if (textField == _passwordTextField) {
        [_passwordTextField resignFirstResponder];
        [self signInAction:nil];
    }
    return YES;
}

- (IBAction)signInAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if (_emailTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please enter email"];
        return;
    }
    else if(!_emailTextField.isValidEmail){
        [self showAlertWithTitle:@"Alert" andMessage:@"Please provide valid email"];
        return;
    }
    else if (_passwordTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please enter password"];
        return;
    }
    else{
        [self performLogin];
    }
}

-(void)performLogin{
    // check if user already exists
    NSFetchRequest *request = [User fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@ AND password = %@" ,_emailTextField.text,_passwordTextField.text];
    NSError *error;
    NSArray *fetchResult = [_context executeFetchRequest:request error:&error];
    if (!error && [fetchResult count]) {
        User *userObj = [fetchResult firstObject];
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:userObj];
    }
    else{
        [self showAlertWithTitle:@"Error" andMessage:@"Invalid email or bad password"];
        return;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"loginSuccessSegue"]) {
        User *userObj = sender;
        AddImageViewController *addViewController = [segue destinationViewController];
        addViewController.userObj = userObj;
    }
}

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
