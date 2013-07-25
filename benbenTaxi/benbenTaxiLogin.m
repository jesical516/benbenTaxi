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

@interface benbenTaxiLogin ()

@end

@implementation benbenTaxiLogin

bool isAutoLogin = false;
bool newAcountState = false;
bool loginState = false;
int loginExpireTime = 30 * 86400;

benbenTaxiLoginManager* loginManager;
LoginModel* loginModel;

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
    NSLog(@"here");
    [loginManager setLoginModel:loginModel];
    [loginModel addObserver:self forKeyPath:@"errorInfo" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    if(isAutoLogin) {
        [self.view setHidden:YES];
        [self performSegueWithIdentifier:@"loginTrigger" sender:self];
    }
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
        [self.loginStatusView startAnimating];
        [loginManager newAcountProcess : self.username.text : self.password.text ];
    } else {
        [self.loginStatusView startAnimating];
        [loginManager loginProcess : self.username.text : self.password.text ];
    }
}

- (IBAction)newAcountPressed:(id)sender {
    NSLog(@"Here %@", @"A");
    UIButton* btn = (UIButton*)sender;
    NSLog(@"%@",  btn.currentTitle);
    //如果当前标题为返回
    if( [btn.currentTitle isEqualToString:@"返回"] ) {
        [sender setTitle:@"注册" forState:UIControlStateNormal];
        [self.passwordConfirm setHidden:true];
        [self.login setTitle:@"登陆" forState:UIControlStateNormal];
        [self.username setText:@""];
        [self.password setText:@""];
        [self.passwordConfirm setText:@""];
        CGRect position = self.login.frame;
        CGRect r2 = CGRectOffset(position, 0, -50);
        [self.login setFrame:r2];
        position = btn.frame;
        r2 = CGRectOffset(position, 0, -50);
        [btn setFrame:r2];
        [self.loginStatusView stopAnimating];
        newAcountState = NO;
    } else {
        [self.username setText:@""];
        [self.password setText:@""];
        [self.passwordConfirm setText:@""];
        [sender setTitle:@"返回" forState:UIControlStateNormal];
        [_passwordConfirm setHidden:false];
        [self.login setTitle:@"注册" forState:UIControlStateNormal];
        CGRect position = self.login.frame;
        CGRect r2 = CGRectOffset(position, 0, 50);
        [self.login setFrame:r2];
        position = btn.frame;
        r2 = CGRectOffset(position, 0, 50);
        [btn setFrame:r2];
        newAcountState = YES;
    }
}

-(void) loginProcess{
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/sessions/passenger_signin"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    //设置用户名和密码
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : self.username.text forKey:@"mobile"];
    [userInfoJobj setObject : self.password.text forKey:@"password"];
    [postInfoJobj setObject : userInfoJobj forKey:@"session"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    
    NSLog(@"post info is %@", strPostInfo);
    
    NSData *data = [strPostInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);
    
    NSDictionary *loginResult = [received objectFromJSONData];
    NSDictionary *errorDict = [loginResult objectForKey:@"errors"];
    if(nil != errorDict) {
        NSArray *baseArray = [errorDict objectForKey:@"base"];
        NSLog(@"base array is %@", baseArray.JSONString);
        NSString* baseError = (NSString*)[baseArray objectAtIndex:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:baseError delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } else {
        loginState = YES;
        NSString *cookieInfo = [loginResult JSONString];
        NSLog(@"cookie is %@", cookieInfo);
        //从返回的结果里面拿到cookie id，然后保存在userDefaults中
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"has_login"];
        [userDefaults setValue: self.username.text forKey:@"phone"];
        [userDefaults setValue: cookieInfo forKey:@"cookie"];
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"here A");
    if([keyPath isEqualToString:@"errorInfo"])
    {
        [self.loginStatusView stopAnimating];
        if([loginModel getLoginStatus]) {
            newAcountState = false;
            loginState = true;
            [self performSegueWithIdentifier:@"loginTrigger" sender:self];
        } else {
            loginState = false;
            NSString* errorInfo = [loginModel getErrorInfo];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end
