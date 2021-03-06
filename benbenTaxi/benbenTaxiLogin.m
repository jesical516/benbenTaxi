//
//  benbenTaxiLogin.m
//  
//
//  Created by 晨松 on 13-6-20.
//
//

#import "benbenTaxiLogin.h"
#import "JSONKit.h"
#import "benbenTaxiLoginManager.h"
#import "LoginModel.h"
#import "PasswordInfo.h"
#import "ComfirmCodeModel.h"
#import "ComfirmCodeManager.h"

@interface benbenTaxiLogin ()

@end

@implementation benbenTaxiLogin

bool isAutoLogin = false;
bool newAcountState = false;
bool loginState = false;
int loginExpireTime = 30 * 86400;
int currentCountDown = 90;

benbenTaxiLoginManager* loginManager;
LoginModel* loginModel;

ComfirmCodeModel* comfirmCodeModel;
ComfirmCodeManager* comfirmCodeManager;
NSTimer* confirmTimer;

NSString * const KEY_USERNAME_PASSWORD = @"benben.taxi.usernamepassword";
NSString * const KEY_USERNAME = @"benben.taxi.app.username";
NSString * const KEY_PASSWORD = @"benben.taxi.app.password";

@synthesize companyLable, loginBarImage, themeLable;

-(void) loadUserCookie
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"has_login"];
    if ([prefs boolForKey:@"has_login"] == YES) {
        NSLog(@"load%@", @" here");
        isAutoLogin = true;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserCookie];
    loginManager = [[benbenTaxiLoginManager alloc]init];
    
    loginModel = [[LoginModel alloc]init];
    [loginModel setErrorInfo:@""];
    [loginModel setLoginStatus:false];
    [loginManager setLoginModel:loginModel];
    [loginModel addObserver:self forKeyPath:@"errorInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    comfirmCodeManager = [[ComfirmCodeManager alloc]init];
    comfirmCodeModel = [[ComfirmCodeModel alloc]init];
    
    [comfirmCodeManager setComfirmCodeModel : comfirmCodeModel];
    [comfirmCodeModel addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* phoneNum = [prefs valueForKey:@"phone"];
    if(![phoneNum isEqualToString:@""]) {
        NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[PasswordInfo load:KEY_USERNAME_PASSWORD];
        if(nil != usernamepasswordKVPairs) {
            self.username.text = [usernamepasswordKVPairs objectForKey:KEY_USERNAME];
            self.password.text = [usernamepasswordKVPairs objectForKey:KEY_PASSWORD];
        }
    }
    confirmTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    if(isAutoLogin) {
        [self.view setHidden:YES];
        [self performSegueWithIdentifier:@"loginTrigger" sender:self];
    }
    NSLog(@"viewDidAppear");
}

- (IBAction)usernameReceived:(id)sender {
    if( [self.username.text isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if( self.username.text.length != 11 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入有效的手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
}
- (IBAction)passwordReceived:(id)sender {
    if( [self.password.text isEqualToString:@""] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
}

- (IBAction)loginPressed:(id)sender {
    if([self.loginStatusView isAnimating]) {
        return;
    }
    
    if( [self.username.text isEqualToString:@""] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请输入手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    UIButton* btn = (UIButton*) sender;
    if ([btn.currentTitle isEqualToString:@"注册"]) {
        if( ![self.passwordConfirm.text isEqualToString:self.password.text] ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"两次输入的密码不一致，请重新输入" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        if( [self.confirmFields.text isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先输入注册码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            return;
        }
        [self.loginStatusView startAnimating];
        [loginManager newAcountProcess : self.username.text : self.password.text : self.confirmFields.text];
    } else {
        [self.loginStatusView startAnimating];
        [loginManager loginProcess : self.username.text : self.password.text ];
    }
}

- (IBAction)newAcountPressed:(id)sender {
    if([self.loginStatusView isAnimating]) {
        return;
    }
    
    UIButton* btn = (UIButton*)sender;
    NSLog(@"%@",  btn.currentTitle);
    //如果当前标题为返回
    if( [btn.currentTitle isEqualToString:@"返回"] ) {
        [sender setTitle:@"注册" forState:UIControlStateNormal];
        [self.getConfirmBtn setTitle: @"获取验证码" forState:UIControlStateNormal];
        [self.passwordConfirm setHidden:true];
        [_getConfirmBtn setHidden:true];
        [_confirmFields setHidden:true];
        [self.login setTitle:@"登录" forState:UIControlStateNormal];
        [self.username setText:@""];
        [self.password setText:@""];
        [self.passwordConfirm setText:@""];
        CGRect position = self.login.frame;
        CGRect r2 = CGRectOffset(position, 0, -100);
        [self.login setFrame:r2];
        position = btn.frame;
        r2 = CGRectOffset(position, 0, -100);
        [btn setFrame:r2];
        [self.loginStatusView stopAnimating];
        newAcountState = NO;
    } else {
        [self.username setText:@""];
        [self.password setText:@""];
        [self.passwordConfirm setText:@""];
        [sender setTitle:@"返回" forState:UIControlStateNormal];
        [_passwordConfirm setHidden:false];
        [_confirmFields setHidden:false];
        [_getConfirmBtn setHidden:false];
        [self.login setTitle:@"注册" forState:UIControlStateNormal];
        
        CGRect position = self.login.frame;
        CGRect r2 = CGRectOffset(position, 0, 100);
        [self.login setFrame:r2];
        position = btn.frame;
        r2 = CGRectOffset(position, 0, 100);
        [btn setFrame:r2];
        newAcountState = YES;
    }
}

- (void)dealloc {
    [_loginDisplay release];
    [_username release];
    [_password release];
    [_passwordConfirm release];
    [_login release];
    [_newAcount release];
    [_loginStatusView release];
    [loginModel removeObserver:self forKeyPath:@"errorInfo"];
    [companyLable release];
    [loginBarImage release];
    [themeLable release];
    [_confirmFields release];
    [_getConfirmBtn release];
    [super dealloc];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}
- (IBAction)passwordConfirmPressed:(id)sender {
    if( [self.passwordConfirm.text isEqualToString:@""] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请再次输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
}

- (IBAction)backgroundTap:(id)sender
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self.passwordConfirm resignFirstResponder];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if(newAcountState) {
        return NO;
    }
    
    if(!loginState) {
        return NO;
    }
    
    return YES;
}


- (IBAction)getComfirmPressed:(id)sender {
    if([self.loginStatusView isAnimating]) {
        return;
    }
    if( ![self.getConfirmBtn.currentTitle isEqualToString:@"获取验证码"] ) {
	return;
    }
    if([self.username.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请先输入手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    [comfirmCodeManager getConfirmCode : self.username.text];
    
    [sender setTitle:@"发送中" forState:UIControlStateNormal];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"errorInfo"])
    {
        [self.loginStatusView stopAnimating];
        if([loginModel getLoginStatus]) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setValue:[loginModel getSessionInfo] forKey:@"cookie"];
            [prefs setValue : self.username.text forKey : @"phone"];
            NSLog(@"now cookie is %@", [prefs valueForKey:@"cookie"]);
            newAcountState = false;
            loginState = true;
            [self performSegueWithIdentifier:@"loginTrigger" sender:self];
            NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
            [usernamepasswordKVPairs setObject : self.username.text forKey:KEY_USERNAME];
            [usernamepasswordKVPairs setObject : self.password.text forKey:KEY_PASSWORD];
            [PasswordInfo save:KEY_USERNAME_PASSWORD data:usernamepasswordKVPairs];
        } else {
            loginState = false;
            NSString* errorInfo = [loginModel getErrorInfo];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    } else if([keyPath isEqualToString : @"response"]) {
        currentCountDown = 90;
        [self.getConfirmBtn setTitle: @"90秒" forState:UIControlStateNormal];
        if( nil == confirmTimer ) {
            confirmTimer=[NSTimer scheduledTimerWithTimeInterval: 1
                                                              target: self
                                                            selector: @selector(handleTimer:)
                                                            userInfo: nil
                                                             repeats: YES];
        }
    }
}

-(void) handleTimer : (id) sender{
    currentCountDown--;
    NSString* currentTitle = [NSString stringWithFormat:@"%d", currentCountDown];
    
    [self.getConfirmBtn setTitle:[currentTitle stringByAppendingString:@"秒"] forState:UIControlStateNormal];
}

@end
