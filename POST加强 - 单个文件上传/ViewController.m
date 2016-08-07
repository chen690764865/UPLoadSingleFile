//
//  ViewController.m
//  POST加强 - 单个文件上传
//
//  Created by chenchen on 16/8/7.
//  Copyright © 2016年 chenchen. All rights reserved.
// 一直有一事不明.看古装剧的时候,两句交战,有一方人马在一旁放箭,可为什么他们放的箭只射到敌军,却射不到自己人.还有为什么将军往往一箭射不死,而小兵却是一箭射死一个.

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //获取图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"001.jpg" ofType:nil];
    
    //上传文件
    [self uploadFileWithServerName:@"userfile" filePath:filePath];
}

-(void)uploadFileWithServerName:(NSString *)serverName filePath:(NSString *)filePath {
    
    //1.URL地址
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/myWeb/php/upload/upload.php"];
    
    //2.请求
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    
    //设置请求方式
    requestM.HTTPMethod = @"POST";
    
    //设置请求头
    [requestM setValue:@"multipart/form-data; boundary=chenchen" forHTTPHeaderField:@"Content-Type"];
    
    //设置请求体 需要的是NSData类型的数据
    requestM.HTTPBody = [self httpBodyWithServerName:serverName filePath:filePath];
    
    //3.发送请求
    [NSURLConnection sendAsynchronousRequest:requestM queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        //判断请求失败
        if (connectionError!=nil || data.length==0) {
            NSLog(@"请求出错 %@",connectionError);
            return ;
        }
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"请求成功! %@",result);
        
    }];
    
}

/**
 *  拼接网络请求体
 *
 *  @return 返回拼接好的网络请求体 NSData类型的数据
 */
-(NSData *)httpBodyWithServerName:(NSString *)serverName filePath:(NSString *)filePath {
    
    //初始化可变二进制数据,拼接好的字符串转换为二进制数据,并把图片的二进制数据也拼接到这个可变二进制数据里面
    NSMutableData *dataM = [NSMutableData data];
    
    //初始化可变字符串来拼接请求体前面的字符串
    NSMutableString *stringM = [NSMutableString string];
    //1.文件的分隔符 以"--"开头 + 分隔符,分隔符前面的"----"可以省略
    [stringM appendString:@"--chenchen\r\n"];
    //2.Content-Disposition 处置的内容
    [stringM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",serverName,[filePath lastPathComponent]];
    //3.Content-Type 告诉服务器要上传的文件的类型,如果不想告诉服务器的话可以设置为 application/octet-stream
    [stringM appendString:@"Content-Type: image/jpeg\r\n"];
    //4.单纯的回车换行
    [stringM appendString:@"\r\n"];
    //5.把上面拼接好的可变字符串转换为data二进制数据拼接到可变dataM中
    NSData *data = [stringM dataUsingEncoding:NSUTF8StringEncoding];
    [dataM appendData:data];
    //6.拼接图片的二进制数据
    [dataM appendData:[NSData dataWithContentsOfFile:filePath]];
    
    //7.结束的分隔符,以"--"开头,以"--"结尾,一个都不能少
    [dataM appendData:[@"\r\n--chenchen--" dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"上传成功");
    //8.返回不可变的data数据
    return [dataM copy];
}

@end
