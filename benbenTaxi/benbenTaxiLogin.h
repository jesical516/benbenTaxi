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

- (IBAction)textFieldDoneEditing:(id)sender;

- (IBAction)backgroundTap:(id)sender;

@end
