//
//  RegistrationViewController.m
//  GalleryApp
//
//  Created by Raees Shaikh on 04/02/17.
//  Copyright © 2017 Danish. All rights reserved.
//

#import "RegistrationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "UITextField+Validation.m"
#import <CoreData/CoreData.h>
#import "User+CoreDataProperties.h"
#import "AddImageViewController.h"

@interface RegistrationViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *dobTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (nonatomic) CGFloat viewXValue, viewYValue;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property BOOL isKeyBoardDisplayed;
@property (strong,nonatomic) NSDate *birthDate;
@property (strong,nonatomic) UIImage *chosenUserImage;
@property (strong,nonatomic) id delegate;
@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userImage.layer.cornerRadius = 20;
    _userImage.clipsToBounds = YES;
    
    // get views x and y cordinates
    _viewXValue = self.view.center.x;
    _viewYValue = self.view.center.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _delegate = [[UIApplication sharedApplication] delegate];
    _context = [_delegate getManagedObjecContext];
    
    [self initializeDatePicker];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    
    if (!_isKeyBoardDisplayed) {
        self.view.center = CGPointMake(self.view.center.x,_viewYValue-160);
    }
    _isKeyBoardDisplayed = YES;
    
}

- (void)keyboardDidHide:(NSNotification *)note
{
    self.view.center = CGPointMake(_viewXValue,_viewYValue);
    _isKeyBoardDisplayed = NO;
}

//Dismiss keyboard when user taps outside the textfield

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

// To display datepicker for user to select birth date

-(void) initializeDatePicker{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [_dobTextField setInputView:datePicker];
}


// As user changes the date it updates the DOB textfield

-(void)dateChanged:(UIDatePicker *)datePicker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *date = [formatter stringFromDate:datePicker.date];
    
    _dobTextField.text = date;
    
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:datePicker.date
                                       toDate:[NSDate date]
                                       options:0];
    NSInteger age = [ageComponents year];
    _ageTextField.text = [NSString stringWithFormat:@"%ld years",(long)age];
    _birthDate = [formatter dateFromString:date];
}


// User wants to update profile image, so action sheet to select from available options

- (IBAction)imageButtonAction:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Image" message:@"Select image or Take a photo" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //Action sheet automatically get cancelled
        
    }];
    
    UIAlertAction *selectImageAction = [UIAlertAction actionWithTitle:@"Select Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    [actionSheet addAction:cancelAction];
    
    [actionSheet addAction:selectImageAction];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addAction:cameraAction];
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark UIImagePickerViewDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    _chosenUserImage = info[UIImagePickerControllerOriginalImage];
    _userImage.image = _chosenUserImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

// Perform validation and register user

- (IBAction)signUpAction:(UIButton *)sender {
    
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
    else if (_confirmPassTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please confirm your password"];
        return;
    }
    else if (![_confirmPassTextField.text isEqualToString:_passwordTextField.text]) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Passwords does not match"];
        return;
    }
    else if (_nameTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please enter name"];
        return;
    }
    else if (_dobTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please select Date of Birth"];
        return;
    }
    else if (_zipCodeTextField.isEmpty) {
        [self showAlertWithTitle:@"Alert" andMessage:@"Please enter zipcode"];
        return;
    }
    else{
        [self registerUser];
    }
    
}

-(void) registerUser{
    
    // check if user already exists
    NSFetchRequest *request = [User fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@",_emailTextField.text];
    NSError *error;
    NSArray *fetchResult = [_context executeFetchRequest:request error:&error];
    if (!error && [fetchResult count]) {
        [self showAlertWithTitle:@"Error" andMessage:@"Email already exist"];
        return;
    }
    else{
        // create a new user
        
        NSArray *splitAge = [_ageTextField.text componentsSeparatedByString:@" "];
        float age = [splitAge[0] floatValue];
        NSData *imageData = UIImagePNGRepresentation(_chosenUserImage);
        
        User *userObj = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_context];
        [userObj setEmail:_emailTextField.text];
        [userObj setPassword:_passwordTextField.text];
        [userObj setName:_nameTextField.text];
        [userObj setDateOfBirth:_birthDate];
        [userObj setAge:age];
        [userObj setZipCode:_zipCodeTextField.text];
        [userObj setImage:imageData];
        [_delegate saveContext];
        [self showAlertWithTitle:@"Success" andMessage:@"User registered"];
        [self performSegueWithIdentifier:@"registerSuccessSegue" sender:userObj];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"registerSuccessSegue"]) {
        User *userObj = sender;
        AddImageViewController *addViewController = [segue destinationViewController];
        addViewController.userObj = userObj;
    }
}

//Generic method to display alert

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

// Mapping the return key of kayboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    }
    else if (textField == _passwordTextField) {
        [_confirmPassTextField becomeFirstResponder];
    }
    else if (textField == _confirmPassTextField) {
        [_nameTextField becomeFirstResponder];
    }
    else if (textField == _nameTextField) {
        [_dobTextField becomeFirstResponder];
    }
    else if (textField == _zipCodeTextField) {
        [_zipCodeTextField resignFirstResponder];
        [self signUpAction:nil];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
