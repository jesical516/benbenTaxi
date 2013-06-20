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

- (IBAction)usernameReceived:(id)sender {

}
- (IBAction)passwordReceived:(id)sender {
    
}

- (IBAction)loginPressed:(id)sender {
    NSString *phoneNumber = @"13439338326";
    NSString *passwordTest = @"12345678";
    
    NSURL *url = [NSURL URLWithString:@"http://42.121.55.211:8081/api/v1/users/create_passenger"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str = @"type=focus-c";//设置参数
    
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
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);
}

- (IBAction)newAcountPressed:(id)sender {
    
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
