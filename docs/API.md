# Dasudian IoT DataHub iOS SDK

- [版本信息](#version)
- [介绍](#introduce)
- [创建客户端实例](#create)
- [异步发送消息](#publish)
- [同步发送消息](#send_request)
- [订阅主题](#subscribe)
- [取消订阅主题](#unsubscribe)
- [销毁客户端](#destroy)
- [上传图片](#upload_image)
- [释放回调函数(接收)返回消息所占用的内存](#free)
- [DataHubClientDelegate说明](#DataHubClientDelegate)
- [选项结构体datahub_options](#datahub_options)
- [消息结构体datahub_message](#datahub_message)
- [错误码](#error_codes)
- [相关术语](#related_glossary)
- [client_id](#client_id)
- [自动重连机制](#autoreconnect)

## <a name="version">版本信息</a>

| Date | Version | Note |
|---|---|---|
| 3/21/2017 | 2.0.0 | 根据SDK的标准修改API |
| 2/28/2017 | 1.0.1 | 修复了调用publish函数过快时，阻塞UI线程的BUG |
| 2/27/2017 | 1.0.0 | first version |

## <a name="introduce">介绍</a>

SDK基于MQTT协议，传输实时的消息到大数点IoT云服务器，大部分的API都是同步的。

你可以收集设备上的数据发送到云上。也可以订阅某个topic，来接收云服务器推送的消息。

如何使用SDK:

- 创建一个客户端实例

- 如果想接收消息，那么就订阅某个topic

- 或者发送消息到服务器

- 退出时，销毁该客户端

## <a name="create">创建客户端实例</a>

```
/*
 * 描述: 该函数创建一个客户端实例，该实例可用于连接大数点MQTT服务器
 * 参数:
 *    client: 如果函数成功调用，则会返回一个客户端实例
 *          注意: 不能为空
 *    instance_id: 用于连接大数点服务器的唯一标识，由大数点提供
 *          注意: 不能为空
 *    instance_key: 用于连接大数点服务器的密码，由大数点提供
 *          注意: 不能为空
 *    client_name: 设备的名字
 *          注意: 不能为空
 *    client_id: 设备的id
 *          注意: 不能为空；一个客户可以与服务器建立多条连接，每条连接由instance_id和
 *          client_id唯一确定
 *    options: MQTT的选项。具体包含的选项可以查看datahub_options结构体。如果不想设置选项，
 *          请传递NULL。如果你想设置某些选项，先使用DATAHUB_OPTIONS_INITIALIZER初始化
 *          注意:可以为空
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      其他错误码请查看开发文档API.md
 */
-(int)datahub_create:(datahub_client *)client
         instance_id:(char *)instance_id
        instance_key:(char *)instance_key
         client_name:(char *)client_name
           client_id:(char *)client_id
             options:(datahub_options*)options;
```

## <a name="publish">异步发送消息</a>

```
/*
 * 描述: 异步发送消息
 *  注意：异步操作不阻塞线程，但不能保证消息发送成功，适用于对时间敏感，对消息成功与否
 *   不敏感的应用
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化。注意：消息
 *         的长度必须小于512K，否则会发生错误
 *          注意: 不能为空
 *    QoS: 消息的服务质量
 *          0   消息可能到达，也可能不到达
 *          1   消息一定会到达，但可能会重复，当然，前提是返回ERROR_NONE
 *          2   消息一定会到达，且只到达一次，当然，前提是返回ERROR_NONE
 *         注意：只能为0,1,2三者中的一个，其他为非法参数
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      其他错误码请查看开发文档API.md
 *
 */
-(int)datahub_publish:(datahub_client *)client
                topic:(char *)topic
                  msg:(datahub_message *)msg
                    QoS:(int)QoS;
```

## <a name="send_request">同步发送消息</a>

建议创建一个子线程单独调用,否则可能阻塞UI线程

```
/*
 * 描述: 发送消息(同步)
 *  注意：程序会阻塞
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化。注意：消息
 *         的长度必须小于512K，否则会发生错误
 *          注意: 不能为空
 *    QoS: 消息的服务质量
 *          0   消息可能到达，也可能不到达
 *          1   消息一定会到达，但可能会重复，当然，前提是返回ERROR_NONE
 *          2   消息一定会到达，且只到达一次，当然，前提是返回ERROR_NONE
 *         注意：只能为0,1,2三者中的一个，其他为非法参数
 *    timeout: 函数阻塞的最大时间。
 *          注意：这是函数阻塞的最大时间，不是消息的超时时间
 * 返回值:
 *      ERROR_NONE 表示成功，消息一定发送出去。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是消息可能发送给服务器，也
 *          可能未发送。如果想确保消息一定发送出去，请根据消息大小和网络状况设置
 *          较大的阻塞等待时间。
 *      其他错误码请查看开发文档API.md
 *
 */
-(int)datahub_sendrequest:(datahub_client *)client
                    topic:(char *)topic
                      msg:(datahub_message *)msg
                        QoS:(int)QoS
                          timeout:(int)timeout;
```

## <a name="upload_image">上传图片</a>

同步操作，会阻塞线程

```
/*
 * 描述：同步上传图片
 *  注意：程序会阻塞
 * 参数：
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化。注意：消息
 *         的长度必须小于10M，否则会发生错误
 *          注意: 不能为空
 *    QoS: 消息的服务质量
 *          0   消息可能到达，也可能不到达
 *          1   消息一定会到达，但可能会重复，当然，前提是返回ERROR_NONE
 *          2   消息一定会到达，且只到达一次，当然，前提是返回ERROR_NONE
 *         注意：只能为0,1,2三者中的一个，其他为非法参数
 *    timeout: 函数阻塞的最大时间。
 *          注意：这是函数阻塞的最大时间，不是消息的超时时间
 * 返回值:
 *      ERROR_NONE 表示成功，消息一定发送出去。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是消息可能发送给服务器，也
 *          可能未发送。如果想确保消息一定发送出去，请根据消息大小和网络状况设置
 *          较大的阻塞等待时间。
 *      其他错误码请查看开发文档API.md
 *
 */
-(int)datahub_upload_image:(datahub_client *)client
                     topic:(char *)topic
                       msg:(datahub_message *)msg
                         QoS:(int)QoS
```

## <a name="subscribe">订阅主题</a>

同步操作，会阻塞线程

```
/*
 * 描述: 同步订阅某一个topic
 *  注意：程序会阻塞
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 订阅的topic
 *          注意: 不能为空
 *    timeout: 函数阻塞的最大时间。
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是可能订阅成功，也
 *          可能订阅失败。如果想确保订阅一定成功，请根据设置较大的阻塞等
 *          待时间。
 *      其他错误码请查看开发文档API.md
 */
-(int)datahub_subscribe:(datahub_client *)client
                  topic:(char *)topic
                    timeout:(int)timeout;
```

## <a name="unsubscribe">取消订阅主题</a>

同步操作，会阻塞线程

```
/*
 * 描述: 同步取消订阅某一个topic
 *  注意：程序会阻塞
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 取消订阅的topic
 *          注意: 不能为空
 *    timeout: 函数阻塞的最大时间。
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是可能取消成功，也
 *          可能取消失败。如果想确保取消一定成功，请根据设置较大的阻塞等
 *          待时间。
 *      其他错误码请查看开发文档API.md
 */
-(int)datahub_unsubscribe:(datahub_client *)client
                    topic:(char *)topic
                      timeout:(int)timeout;
```

## <a name="destroy">销毁客户端</a>

```
/*
 * 描述: 销毁客户端并断开连接
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 * 返回值:
 *     无
 */
-(void)datahub_destroy:(datahub_client *)client;
```

## <a name="free">释放回调函数(接收)返回消息所占用的内存</a>

```
/*
 * 描述：接收函数中，主题和消息占用的内存需要用户手动释放
 * 参数：
 *  topic: 返回的主题
 *  msg: 返回的消息
 * 返回值:
 *  无
 */
-(void)datahub_callback_free:(char *)topic
                         msg:(datahub_message *)msg
```

## <a name="DataHubClientDelegate">DataHubClientDelegate说明</a>

实现下面的代理函数，用于接收消息，监听SDK连接状态。

```
@optional
/*
 * 描述： 接收到消息后的回调函数
 * 参数：
 *      context: 传递给选项'context'的内容
 *      topic: 本次消息所属的主题,需要调用datahub_callback_free()手动释放内存
 *      msg: 存放消息的结构体,需要调用datahub_callback_free()手动释放内存
 */
-(void)messageReceived:(void *)context topic:(char *)topic message:(datahub_message *)msg;
/*
 * 描述： 当客户端的状态发生改变(连接上服务器或者从服务器断开)的时候，SDK会通知用户
 * 参数：
 *      context: 传递给选项'context'的内容
 *      isconnected: 连接状态， DATAHUB_FALSE 表示从服务器断开，DATAHUB_TRUE 表示连接上服务器
 */
-(void)connectionStatusChanged:(void *)context isconnected:(int)isconnected;
@end
```

## <a name="datahub_options">选项结构体datahub_options</a>

```
typedef struct datahub_options_s {
    /*
     * 描述: 设置使用哪种协议(ssl, 普通的tcp)连接服务器, 以及设置服务器的地址和端口号。
     * 值
     *     "协议：//服务器地址：端口号"。 协议支持普通的tcp协议和加密的ssl协议; 服务器地址和端口号
     *      由大数点提供。 默认值为DEFAULT_SERVER_URL
     */
    char *server_url;

    /*
     * 描述：开启调试选项
     * 值：
     *      DATAHUB_TRUE表示开启调试选项;DATAHUB_FALSE表示关闭调试选项,默认值为DATAHUB_FALSE
     */
    int debug;
    /*
     * 描述:
     *      传递给回调函数messageReceived()和connectionStatusChanged()的参数, 对应回调函数的第一个参数
     *      context
     */
    void *context;
} datahub_options;
```

## <a name="datahub_message">消息结构体datahub_message</a>

```
/*
 * 描述: 消息的结构体类型
 */
typedef struct datahub_message_s {
    /* 消息长度，必须大于0 */
    unsigned int payload_len;
    /* 发送消息的起始地址 */
    void *payload;
} datahub_message;
```

## <a name="error_codes">错误码</a>

```
enum datahub_error_code_s {
    /*
     * 返回码: 成功
     */
    ERROR_NONE = 0,
    /*
     * 返回码: 某些参数不合法
     */
    ERROR_ILLEGAL_PARAMETERS = -1,
    /*
     * 返回码: 客户端未连接服务器
     */
    ERROR_DISCONNECTED = -2,
    /*
     * 返回码: MQTT服务器不支持当前使用的协议版本号,请联系开发人员
     */
    ERROR_UNACCEPT_PROTOCOL_VERSION = -3,
    /*
     * 返回码: client_id不可用,可能使用了不支持的字符
     */
    ERROR_IDENTIFIER_REJECTED = -4,
    /*
     * 返回码: 服务器不可用
     */
    ERROR_SERVER_UNAVAILABLE = -5,
    /*
     * 返回码: instance_id 或者instance_key不正确,请检查或者联系客服人员
     */
    ERROR_BAD_USERNAME_OR_PASSWD = -6,
    /*
     * 返回码: 未被授权
     */
    ERROR_UNAUTHORIZED = -7,
    /*
     * 返回码: 验证服务器不可用
     */
    ERROR_AUTHORIZED_SERVER_UNAVAILABLE = -8,
    /*
     * 返回码: 操作失败
     */
    ERROR_OPERATION_FAILURE = -9,
    /*
     * 返回码: 消息过长
     */
    ERROR_MESSAGE_TOO_BIG = -10,
    /*
     * 返回码: 网络不可用
     */
    ERROR_NETWORK_UNREACHABLE = -11,
    /*
     * 返回码: 同步超时
     */
    ERROR_TIMEOUT = -12,
    /*
     * 返回码: 内存申请失败
     */
    ERROR_MEMORY_ALLOCATE = -500,
};
```

## <a name="related_glossary">相关术语</a>


### <a name="client_id">client_id</a>

客户端id，用于服务器唯一标记一个客户端，服务器通过该id向客户端推送消息;
注意：不同的客户端的id必须不同，如果有两个客户端有相同的id，服务器会关掉其中的一个客户端的连接。
可以使用设备的mac地址，或者第三方账号系统的id（比如qq号，微信号）。
如果没有自己的账号系统，则可以随机生成一个不会重复的客户端id。
或者自己指定客户端的id，只要能保证不同客户端id不同即可。

### <a name="autoreconnect">自动重连机制</a>

当连接丢失时，SDK会尝试自动重连。如果连接失败，下一次重连将会在1s，2s，4s，8s，16s，1s，2s，4s，8s，16s，1s，...后再次尝试，最大重连间隔为16秒。
