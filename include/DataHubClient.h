/*
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#import <Foundation/Foundation.h>
#import "DataHubCommon.h"

@protocol DataHubClientDelegate <NSObject>

@optional
/*
 * 描述： 接收到消息后的回调函数
 * 参数：
 *      context: 传递给选项'context'的内容
 *      topic: 本次消息所属的主题
 *      msg: 存放消息的结构体
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


@interface DataHubClient : NSObject

//delegate
@property(nonatomic,assign) id<DataHubClientDelegate> delegate;

typedef struct datahub_options_s {
    /*
     * 描述: 设置使用哪种协议(ssl, 普通的tcp)连接服务器, 以及设置服务器的地址和端口号.
     * 值:
     *     "协议：//服务器地址：端口号". 协议支持普通的tcp协议和加密的ssl协议; 服务器地址和端口号
     *      由大数点提供. 默认值为DEFAULT_SERVER_URL
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

//share instance
+(instancetype) shareInstance;

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
 *    options: MQTT的选项。具体包含的选项可以查看datahub_options结构体.如果不想设置选项，
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

/*
 * 描述: 发送消息(异步)
 *  注意：异步操作不阻塞线程，但不能保证消息发送成功，适用于对时间敏感，对消息成功与否
 *   不敏感的应用
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化.注意：消息
 *         的长度必须小于512K，否则会发生错误
 *          注意: 不能为空
 *    QoS: 消息的服务质量
 *          0   消息可能到达，也可能不到达
 *          1   消息一定会到达，但可能会重复，当然，前提是返回ERROR_NONE
 *          2   消息一定会到达，且只到达一次，当然，前提是返回ERROR_NONE
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      其他错误码请查看开发文档API.md
 *
 */
-(int)datahub_publish:(datahub_client *)client
                topic:(char *)topic
                  msg:(datahub_message *)msg
                    QoS:(int)QoS;
/*
 * 描述: 发送消息(同步)
 *  注意：程序会阻塞
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化.注意：消息
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
 *          较大的阻塞等待时间.
 *      其他错误码请查看开发文档API.md
 *
 */
-(int)datahub_sendrequest:(datahub_client *)client
                    topic:(char *)topic
                      msg:(datahub_message *)msg
                        QoS:(int)QoS
                          timeout:(unsigned long)timeout;

/*
 * 描述：同步上传图片
 *  注意：程序会阻塞
 * 参数：
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 消息对应的topic。如果消息发送前有另一个客户端已经订阅该topic，则
 *          另一个客户端就会收到消息。
 *          注意: 不能为空
 *    msg: 发送的消息,使用前请使用DATAHUB_MESSAGE_INITIALIZER初始化.注意：消息
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
 *          较大的阻塞等待时间.
 *      其他错误码请查看开发文档API.md
 *
 */

-(int)datahub_upload_image:(datahub_client *)client
                     topic:(char *)topic
                       msg:(datahub_message *)msg
                         QoS:(int)QoS
                           timeout:(unsigned long)timeout;

/*
 * 描述: 同步订阅某一个topic
 *  注意：程序会阻塞
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 订阅的topic
 *          注意: 不能为空
 *    timeout: 函数阻塞的最大时间。
 *          注意：这是函数阻塞的最大时间
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是可能订阅成功，也
 *          可能订阅失败。如果想确保订阅一定成功，请根据设置较大的阻塞等
 *          待时间.
 *      其他错误码请查看开发文档API.md
 */
-(int)datahub_subscribe:(datahub_client *)client
                  topic:(char *)topic
                    timeout:(unsigned long)timeout;
/*
 * 描述: 同步取消订阅某一个topic
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 *    topic: 取消订阅的topic
 *          注意: 不能为空
 *    timeout: 函数阻塞的最大时间。
 *          注意：这是函数阻塞的最大时间
 * 返回值:
 *      ERROR_NONE 表示成功，其他表示错误。
 *      ERROR_TIMEOUT 表示阻塞等待时间的最大值已到，但是可能取消成功，也
 *          可能取消失败。如果想确保取消一定成功，请根据设置较大的阻塞等
 *          待时间.
 *      其他错误码请查看开发文档API.md
 */
-(int)datahub_unsubscribe:(datahub_client *)client
                    topic:(char *)topic
                      timeout:(unsigned long)timeout;

/*
 * 描述: 销毁客户端并断开连接
 * 参数:
 *    client: 由函数datahub_create()成功返回的客户端实例
 *          注意: 不能为空
 * 返回值:
 *    无返回值
 */
-(void)datahub_destroy:(datahub_client *)client;

/*
 * 描述：释放回调函数(接收)返回消息所占用的内存
 * 参数：
 *  msg: 回调函数(接收)返回的消息
 * 返回值:
 */
-(void)datahub_message_free:(datahub_message *)msg;

@end



