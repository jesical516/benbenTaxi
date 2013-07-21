//
//  benbenTaxiLogin.h
//  
//
//  Created by 晨松 on 13-6-20.
//
//

#import <UIKit/UIKit.h>

@interface benbenTaxiLogin : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *loginDisplay;
@property (retain, nonatomic) IBOutlet UITextField *username;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UITextField *passwordConfirm;
@property (retain, nonatomic) IBOutlet UIButton *login;
@property (retain, nonatomic) IBOutlet UIButton *newAcount;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loginStatusView;

- (IBAction)textFieldDoneEditing:(id)sender;

- (IBAction)backgroundTap:(id)sender;

@end
