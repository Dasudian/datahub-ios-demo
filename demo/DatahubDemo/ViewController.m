/*
 *
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#import "ViewController.h"
#import "DataHubClient.h"

/* instance id, 由大数点提供 */
#define INSTANCE_ID    "dsd_9FmYSNiqpFmi69Bui0_A"
/* instance key, 由大数点提供 */
#define INSTANCE_KEY   "238f173d6cc0608a"
/* 设备的名字 */
#define CLIENT_NAME     "device"
/* 设备的id */
#define CLIENT_ID      "NO1"

@interface ViewController ()<DataHubClientDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong) UITextField * topicInput;
@property(nonatomic,strong) UITextField * messageInput;
@property(nonatomic,strong) UITextView * logTextView;

@property(nonatomic,assign) datahub_client client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self loadMainView];
    [[[NSThread alloc]initWithTarget:self selector:@selector(loadMainView:) object:nil] start];
//    [self loadMoreData];
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

    UIButton * uploadImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadImageButton.frame = CGRectMake(10, CGRectGetMaxY(messageLabel.frame) + 10 , SCREEN_WIDTH - 20, 40);
    uploadImageButton.layer.masksToBounds = YES;
    uploadImageButton.layer.cornerRadius = 5.0;
    [uploadImageButton setBackgroundColor:ButtonColor];
    [uploadImageButton addTarget:self action:@selector(handleUploadImage) forControlEvents:UIControlEventTouchUpInside];
    [uploadImageButton setTitle:@"上传图片" forState:UIControlStateNormal];
    [self.view addSubview:uploadImageButton];
    
    _logTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(uploadImageButton.frame)+10, SCREEN_WIDTH-20, SCREEN_HEIGHT-CGRectGetMaxY(messageLabel.frame)-10)];
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
    [[[NSThread alloc]initWithTarget:self selector:@selector(subscribeTopic:) object:_topicInput.text] start];
}

-(void)handleCancelSubscribeTopic
{
    if (!_topicInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"取消订阅主题不能为空 \n"];
        return;
    }
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
    

    [[[NSThread alloc]initWithTarget:self selector:@selector(publishMessage:) object:_messageInput.text] start];
//    [self publishMessage:_messageInput.text];
}

-(void)handleClearLog
{
    _logTextView.text = @"";
}

-(void)handleUploadImage
{
    UIActionSheet *sheet;
    sheet = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    sheet.tag = 255;
    [sheet showInView:self.view];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *data = UIImagePNGRepresentation(image);
    
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(uploadImage:) object:data];
    [thread start];
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - actionsheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = 0;
        if (buttonIndex == 0) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark - call lib
-(void)initClient
{
    int ret;
    datahub_options options = DATAHUB_OPTIONS_INITIALIZER;
    /* open debug option */
//    setenv("MQTT_C_CLIENT_TRACE", "ON", 1);
//    setenv("MQTT_C_CLIENT_TRACE_LEVEL", "MAXIMUM", 1);
    options.debug = DATAHUB_TRUE;
//    options.server_url = "ssl://try.iotdatahub.net:8883";
    options.server_url = "tcp://try.iotdatahub.net:1883";
    /* create a client object */
    ret = [[DataHubClient shareInstance] datahub_create:&_client instance_id:INSTANCE_ID instance_key:INSTANCE_KEY client_name:CLIENT_NAME client_id:CLIENT_ID options:&options];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:[NSString stringWithFormat:@"create client failed, %d\n", ret]];
        return;
    }else{
        [self refreshUIWithMessage:@"create client success\n"];
    }

    [DataHubClient shareInstance].delegate = self;
}

-(void)subscribeTopic:(NSString *)topic
{
    int ret;
    ret = [[DataHubClient shareInstance]datahub_subscribe:&_client topic:(char *) [topic UTF8String] timeout:(10)];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:@"subscribe topic failed\n"];
    } else {
        [self refreshUIWithMessage:@"subscribe topic success\n"];
    }
}

-(void)cancelSubscribeTopic:(NSString *)topic
{
    int ret;
    ret = [[DataHubClient shareInstance]datahub_unsubscribe:&_client topic:(char *)[topic UTF8String] timeout:(10)];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:@"unsubscribe topic failed\n"];
    } else {
        [self refreshUIWithMessage:@"unsubscribe topic success\n"];
    }
}

//-(void)publishMessage:(NSString *)message
//{
//    int ret;
//    
//    datahub_message msg = DATAHUB_MESSAGE_INITIALIZER;
//    NSData *bytes = [message dataUsingEncoding:NSUTF8StringEncoding];
//    msg.payload = (void *)[bytes bytes];
//    msg.payload_len = (int)bytes.length;
//    char * currentTopic = (char *)[_topicInput.text UTF8String];
//    
//    /* send message asynchronously */
//    ret = [[DataHubClient shareInstance]datahub_publish:&_client topic:currentTopic msg:&msg QoS:2];
//    if (ERROR_NONE != ret) {
//        NSString *str = [NSString stringWithFormat:@"async send message failed, ret = %d\n", ret];
//        [self refreshUIWithMessage:str];
//    } else {
//        [self refreshUIWithMessage:@"异步发送了消息\n"];
//    }
//}

-(void)publishMessage:(NSString *)message
{
    int ret;
    
    datahub_message msg = DATAHUB_MESSAGE_INITIALIZER;
    NSData *bytes = [message dataUsingEncoding:NSUTF8StringEncoding];
    msg.payload = (void *)[bytes bytes];
    msg.payload_len = (int)bytes.length;
    char * currentTopic = (char *)[_topicInput.text UTF8String];
    
    /* send message synchronously */
    ret = [[DataHubClient shareInstance]datahub_sendrequest:&_client topic:currentTopic msg:&msg QoS:2 timeout:10];
    if (ERROR_NONE != ret) {
        NSString *str = [NSString stringWithFormat:@"sync send message failed, ret = %d\n", ret];
       // [self performSelectorOnMainThread:@selector(updateLog:) withObject:str waitUntilDone:YES];
        [self refreshUIWithMessage:str];
    } else {
       // [self performSelectorOnMainThread:@selector(updateLog:) withObject:str waitUntilDone:YES];
        [self refreshUIWithMessage:@"同步发送了消息\n"];
    }
}

-(void)uploadImage:(NSData *)data
{
    int ret;
    
    if (!_topicInput.text.length) {
        _logTextView.text = [_logTextView.text stringByAppendingString:@"主题不能为空\n"];
        return;
    }
    datahub_message msg = DATAHUB_MESSAGE_INITIALIZER;
    msg.payload = (void *)[data bytes];
    msg.payload_len = (int)data.length;
    char * currentTopic = (char *)[_topicInput.text UTF8String];
    ret = [[DataHubClient shareInstance]datahub_upload_image:&_client topic:currentTopic msg:&msg QoS:2 timeout:10];
    if (ERROR_NONE != ret) {
        [self refreshUIWithMessage:@"upload image failed\n"];
    } else {
        [self refreshUIWithMessage:@"upload image success\n"];
    }
}

-(void)destroyClient
{
    /* free memory */
    [[DataHubClient shareInstance]datahub_destroy:&_client];
}

#pragma mark - DataHubClientDelegate
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
    // 使用下面这个API用时会使界面卡死
//    [self performSelectorOnMainThread:@selector(updateUIWithMessage:) withObject:message waitUntilDone:YES];
}

-(void)updateUIWithMessage:(NSString *)message
{
    _logTextView.text = [_logTextView.text stringByAppendingString:message];
}

@end
