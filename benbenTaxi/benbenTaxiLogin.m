//
//  benbenTaxiLogin.m
//  
//
//  Created by 晨松 on 13-6-20.
//
//

#import "benbenTaxiLogin.h"
#import "JSONKit.h"

@interface benbenTaxiLogin ()

@end

@implementation benbenTaxiLogin

bool isAutoLogin = false;
int loginExpireTime = 30 * 86400;

-(void) loadUserCookie
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"has_login"];
    //如果用户注册成功且登录过，则直接登录
    if ([prefs boolForKey:@"has_login"] == YES) {
        //判断下是否登录过，如果登录过，则将自动跳过
        NSLog(@"load%@", @" here");
        isAutoLogin = true;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //这里需要拿到本地的cookie文件，如果cookie没有失效，则将cookie信息load进来。
    //设置自动登录为true
    [self loadUserCookie];
}

- (void)viewDidAppear:(BOOL)animated {
    if(isAutoLogin) {
        [self.view setHidden:YES];
        [self performSegueWithIdentifier:@"loginTrigger" sender:self];
        
    }
}

- (IBAction)usernameReceived:(id)sender {

}
- (IBAction)passwordReceived:(id)sender {
    
}

- (IBAction)loginPressed:(id)sender {
    NSString *phoneNumber = self.username.text;
    NSString *passwordTest = self.password.text;
    
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/sessions/passenger_signin"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    //设置用户名和密码
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : phoneNumber forKey:@"mobile"];
    [userInfoJobj setObject : passwordTest forKey:@"password"];
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
    NSString *errorMsg = [loginResult objectForKey:@"errors"];
    if (nil != errorMsg) {
        NSLog(@"login failed");
    } else {
        NSString *cookieInfo = [loginResult JSONString];
        NSLog(@"cookie is %@", cookieInfo);
        //从返回的结果里面拿到cookie id，然后保存在userDefaults中
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"has_login"];
        NSLog(@"phone is %@", phoneNumber);
        [userDefaults setValue: phoneNumber forKey:@"phone"];
        [userDefaults setValue: cookieInfo forKey:@"cookie"];
    }
}

- (IBAction)newAcountPressed:(id)sender {
    NSLog(@"text 1 %@", self.password.text);
    NSLog(@"text 1 %@", self.username.text);
    
    NSString *phoneNumber = @"13439338326";
    NSString *passwordTest = @"12345678";
    
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/users/create_passenger"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];  
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    //设置用户名和密码
    NSMutableDictionary *postInfoJobj = [NSMutableDictionary dictionary];
    NSMutableDictionary *userInfoJobj = [NSMutableDictionary dictionary];
    [userInfoJobj setObject : phoneNumber forKey:@"mobile"];
    [userInfoJobj setObject : passwordTest forKey:@"password"];
    [userInfoJobj setObject : passwordTest forKey:@"password_confirmation"];
    
    [postInfoJobj setObject : userInfoJobj forKey:@"user"];
    NSString *strPostInfo = [postInfoJobj JSONString];
    
    NSLog(@"post info is %@", strPostInfo);
    
    NSData *data = [strPostInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *loginResult = [received objectFromJSONData];
    NSString *errorMsg = [loginResult objectForKey:@"errors"];
    if (nil != errorMsg) {
        NSLog(@"login failed");
    } else {
        NSString *cookieInfo = [loginResult JSONString];
        NSLog(@"cookie is %@", cookieInfo);
    }
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);
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
