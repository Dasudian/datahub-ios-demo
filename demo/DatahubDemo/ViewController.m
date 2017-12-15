/*
 *
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#import "ViewController.h"
#import "DataHubClient.h"

/*  instance id, 标识客户的唯一ID，请联系大数点商务support@dasudian.com获取 */
#define INSTANCE_ID    "your_instance_id"
/*  instance key, 与客户标识相对应的安全密钥，请联系大数点商务support@dasudian.com获取 */
#define INSTANCE_KEY   "your_instance_key"

/*  大数点IoT DataHub云端地址，请联系大数点商务support@dasudian.com获取 */
#define SERVER_URL      "www.example.com"
/* 设备的名字 */
#define CLIENT_TYPE     "ios-device"
/* 设备的id */
#define CLIENT_ID      "ios-device-1"

@interface ViewController ()<DataHubClientDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/* 主题文本框 */
@property(nonatomic,strong) UITextField * topicInput;
/* 发送消息文本框 */
@property(nonatomic,strong) UITextField * messageInput;
/* 显示日志文本框 */
@property(nonatomic,strong) UITextView * logTextView;
/* 客户端 */
@property(nonatomic,assign) datahub_client client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[NSThread alloc]initWithTarget:self selector:@selector(loadMainView:) object:nil] start];
    [[[NSThread alloc]initWithTarget:self selector:@selector(loadMoreData:) object:nil] start];
}

-(void)loadMainView:(id)none
{
    UILabel * topicLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40 , 40, 40)];
    [topicLabel setFont:[UIFont systemFontOfSize:14.0]];
    [topicLabel setTextAlignment:NSTextAlignmentLeft];
    [topicLabel setTextColor:[UIColor blackColor]];
    topicLabel.text = @"主题";
    [self.view addSubview:topicLabel];
    
    _topicInput = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(topicLabel.frame)+5, CGRectGetMinY(topicLabel.frame), SCREEN_WIDTH - CGRectGetMaxX(topicLabel.frame)-125 , 40)];
    [_topicInput setFont:[UIFont systemFontOfSize:14.0]];
    [_topicInput setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_topicInput setBorderStyle:UITextBorderStyleRoundedRect];
    _topicInput.layer.masksToBounds = YES;
    _topicInput.layer.borderColor= [UIColor lightGrayColor].CGColor;
    _topicInput.layer.borderWidth = 0.1f;
    _topicInput.placeholder = @"请输入订阅的主题";
    [self.view addSubview:_topicInput];
    
    UIButton * subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    subscribeButton.frame = CGRectMake(CGRectGetMaxX(_topicInput.frame)+5,CGRectGetMinY(topicLabel.frame) , 50, 40);
    subscribeButton.layer.masksToBounds = YES;
    subscribeButton.layer.cornerRadius = 5.0;
    [subscribeButton setBackgroundColor:ButtonColor];
    [subscribeButton setTitle:@"订阅" forState:UIControlStateNormal];
    [subscribeButton addTarget:self action:@selector(handlesubscribeTopic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subscribeButton];
    
    UIButton * cancelSubscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelSubscribeButton.frame = CGRectMake(CGRectGetMaxX(subscribeButton.frame)+5,CGRectGetMinY(topicLabel.frame) , 50, 40);
    cancelSubscribeButton.layer.masksToBounds = YES;
    cancelSubscribeButton.layer.cornerRadius = 5.0;
    [cancelSubscribeButton setBackgroundColor:ButtonColor];
    [cancelSubscribeButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelSubscribeButton addTarget:self action:@selector(handleCancelSubscribeTopic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelSubscribeButton];
    
    UILabel * messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(topicLabel.frame)+10 , 40, 40)];
    [messageLabel setFont:[UIFont systemFontOfSize:14.0]];
    [messageLabel setTextAlignment:NSTextAlignmentLeft];
    [messageLabel setTextColor:[UIColor blackColor]];
    messageLabel.text = @"消息";
    [self.view addSubview:messageLabel];
    
    _messageInput = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(messageLabel.frame)+5, CGRectGetMinY(messageLabel.frame), SCREEN_WIDTH - CGRectGetMaxX(messageLabel.frame)-125 , 40)];
    [_messageInput setFont:[UIFont systemFontOfSize:14.0]];
    [_messageInput setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_messageInput setBorderStyle:UITextBorderStyleRoundedRect];
    _messageInput.layer.masksToBounds = YES;
    _messageInput.layer.borderColor= [UIColor lightGrayColor].CGColor;
    _messageInput.layer.borderWidth = 0.1f;
    _messageInput.placeholder = @"发送消息...";
    [self.view addSubview:_messageInput];
    
    UIButton * sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(CGRectGetMaxX(_messageInput.frame)+5,CGRectGetMinY(messageLabel.frame) , 50, 40);
    sendButton.layer.masksToBounds = YES;
    sendButton.layer.cornerRadius = 5.0;
    [sendButton setBackgroundColor:ButtonColor];
    [sendButton addTarget:self action:@selector(handleSendMessage) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    
    UIButton * clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake(CGRectGetMaxX(sendButton.frame)+5,CGRectGetMinY(messageLabel.frame) , 50, 40);
    clearButton.layer.masksToBounds = YES;
    clearButton.layer.cornerRadius = 5.0;
    [clearButton setBackgroundColor:ButtonColor];
    [clearButton addTarget:self action:@selector(handleClearLog) forControlEvents:UIControlEventTouchUpInside];
    [clearButton setTitle:@"清除" forState:UIControlStateNormal];
    [self.view addSubview:clearButton];

    _logTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(clearButton.frame)+10, SCREEN_WIDTH-20, SCREEN_HEIGHT-CGRectGetMaxY(messageLabel.frame)-10)];
    _logTextView.editable = NO;
    _logTextView.layer.masksToBounds = YES;
    _logTextView.layer.cornerRadius = 5.0;
    _logTextView.layer.borderColor= [UIColor lightGrayColor].CGColor;
    _logTextView.layer.borderWidth = 0.1f;
    [_logTextView setFont:[UIFont systemFontOfSize:17.0]];
    [self.view addSubview:_logTextView];
}

-(void)loadMoreData:(id)none
{
    [self initClient];
}

#pragma mark - Action
-(void)handlesubscribeTopic
{
    if (!_topicInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"订阅主题不能为空 \n"];
        return;
    }
    [_topicInput resignFirstResponder];
    [_messageInput resignFirstResponder];
    /* 订阅主题 */
    [[[NSThread alloc]initWithTarget:self selector:@selector(subscribeTopic:) object:_topicInput.text] start];
}

-(void)handleCancelSubscribeTopic
{
    if (!_topicInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"取消订阅主题不能为空 \n"];
        return;
    }
    /* 取消订阅 */
    [[[NSThread alloc]initWithTarget:self selector:@selector(cancelSubscribeTopic:) object:_topicInput.text] start];
}

-(void)handleSendMessage
{
    if (!_topicInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"主题不能为空 \n"];
        return;
    }
    if (!_messageInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"消息不能为空 \n"];
        return;
    }
    [_topicInput resignFirstResponder];
    [_messageInput resignFirstResponder];
    

    /* 发送消息 */
    [[[NSThread alloc]initWithTarget:self selector:@selector(publishMessage:) object:_messageInput.text] start];
}

-(void)handleClearLog
{
    _logTextView.text = @"";
}

#pragma mark - call lib
-(void)initClient
{
    int ret;
    /* 初始化选项 */
    datahub_options options = DATAHUB_OPTIONS_INITIALIZER;
    /* 设置服务器地址 */
    options.server_url = SERVER_URL;
    /* 创建客户端 */
    ret = [[DataHubClient shareInstance] datahub_create:&_client instance_id:INSTANCE_ID instance_key:INSTANCE_KEY client_type:CLIENT_TYPE client_id:CLIENT_ID options:&options];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:[NSString stringWithFormat:@"创建客户端失败, %d\n", ret]];
        return;
    }else{
        [self refreshUIWithMessage:@"创建客户端成功\n"];
    }

    [DataHubClient shareInstance].delegate = self;
}

-(void)subscribeTopic:(NSString *)topic
{
    int ret;
    /* 订阅主题, 最大以qos1的服务质量接收消息, 超时时间设置为10s */
    ret = [[DataHubClient shareInstance]datahub_subscribe:&_client topic:(char *) [topic UTF8String] QoS:1 timeout:(10)];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:@"订阅失败, 错误码 %d\n", ret];
    } else {
        [self refreshUIWithMessage:@"订阅主题成功\n"];
    }
}

-(void)cancelSubscribeTopic:(NSString *)topic
{
    int ret;
    /* 取消订阅主题 */
    ret = [[DataHubClient shareInstance]datahub_unsubscribe:&_client topic:(char *)[topic UTF8String] timeout:(10)];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:@"取消订阅失败, 错误码 %d\n", ret];
    } else {
        [self refreshUIWithMessage:@"取消订阅成功\n"];
    }
}

-(void)publishMessage:(NSString *)message
{
    int ret;
    
    datahub_message msg = DATAHUB_MESSAGE_INITIALIZER;
    NSData *bytes = [message dataUsingEncoding:NSUTF8StringEncoding];
    msg.payload = (void *)[bytes bytes];
    msg.payload_len = (int)bytes.length;
    char * currentTopic = (char *)[_topicInput.text UTF8String];
    
    /* 发送qos1消息, 超时时间设置为10s */
    ret = [[DataHubClient shareInstance]datahub_sendrequest:&_client topic:currentTopic msg:&msg data_type:TEXT QoS:1 timeout:10];
    if (ERROR_NONE != ret) {
        NSString *str = [NSString stringWithFormat:@"发送消息失败, 错误码为 %d\n", ret];
        [self refreshUIWithMessage:str];
    } else {
        [self refreshUIWithMessage:@"发送消息成功\n"];
    }
}

-(void)destroyClient
{
    /* 销毁客户端并断开连接 */
    [[DataHubClient shareInstance]datahub_destroy:&_client];
}

#pragma mark - DataHubClientDelegate
/* 接收到消息后的回调函数 */
-(void)messageReceived:(void *)context topic:(char *)topic_name message:(datahub_message *)msg
{
    char *buff = malloc(msg->payload_len + 1);
    if (buff == NULL) {
        return;
    }
    memcpy(buff, msg->payload, msg->payload_len);
    buff[msg->payload_len] = '\0';
    NSString *content = [[NSString alloc] initWithCString:buff encoding:NSUTF8StringEncoding];
    free(buff);
    
    [self refreshUIWithMessage:[NSString stringWithFormat:@"接收主题为 %s ;消息为%@\n", topic_name, content]];
    /* 必须释放内存 */
    [[DataHubClient shareInstance]datahub_callback_free:topic_name message:msg];
}
/* 网络连接发生变化的通知函数 */
-(void)connectionStatusChanged:(void *)context isconnected:(int)isconnected
{
    if (isconnected == DATAHUB_TRUE ) {
        [self refreshUIWithMessage:[NSString stringWithFormat:@"连接成功\n"]];
    } else {
        [self refreshUIWithMessage:[NSString stringWithFormat:@"连接断开\n"]];
    }
}

-(void)refreshUIWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIWithMessage:message];
    });
}

-(void)updateUIWithMessage:(NSString *)message
{
    _logTextView.text = [_logTextView.text stringByAppendingString:message];
}

@end
