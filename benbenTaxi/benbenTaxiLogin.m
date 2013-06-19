//
//  benbenTaxiLogin.m
//  
//
//  Created by 晨松 on 13-6-20.
//
//

#import "benbenTaxiLogin.h"

@interface benbenTaxiLogin ()

@end

@implementation benbenTaxiLogin

- (IBAction)usernameReceived:(id)sender {

}
- (IBAction)passwordReceived:(id)sender {
    
}

- (IBAction)loginPressed:(id)sender {
    
}

- (IBAction)newAcountPressed:(id)sender {
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_loginDisplay release];
    [_username release];
    [_password release];
    [_password release];
    [super dealloc];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}
@end
