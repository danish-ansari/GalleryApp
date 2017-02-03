//
//  LoginViewController.m
//  GalleryApp
//
//  Created by Danish Ansari on 03/02/17.
//  Copyright © 2017 Danish. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface LoginViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *dobTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (nonatomic) CGFloat viewXValue, viewYValue;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userImage.layer.cornerRadius = 20;
    _userImage.clipsToBounds = YES;
    
    // get views x and y cordinates
    _viewXValue = self.view.center.x;
    _viewYValue = self.view.center.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    _context = [delegate getManagedObjecContext];
    
    [self initializeDatePicker];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    self.view.center = CGPointMake(self.view.center.x,_viewYValue-200);

}

- (void)keyboardDidHide:(NSNotification *)note
{
    self.view.center = CGPointMake(_viewXValue,_viewYValue);
}

//Dismiss keyboard when user taps outside
 
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
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _userImage.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

// Perform validation and register user

- (IBAction)signUpAction:(UIButton *)sender {
    if ([_nameTextField.text isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" andMessage:@"Please enter name"];
        return;
    }
    else if ([_dobTextField.text isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" andMessage:@"Please select Date of Birth"];
        return;
    }
    else if ([_zipCodeTextField.text isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error" andMessage:@"Please enter zipcode"];
        return;
    }
    else{
        
    }
    
}

//Generic method to display alert

-(void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _nameTextField) {
        [_nameTextField resignFirstResponder];
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
