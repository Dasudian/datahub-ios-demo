/*
 * Licensed Materials - Property of Dasudian
 * Copyright Dasudian Technology Co., Ltd. 2017
 */

#ifndef DataHubCommon_h
#define DataHubCommon_h

#define DATAHUB_TRUE 1
#define DATAHUB_FALSE 0

#define DEFAULT_SERVER_URL      "tcp://try.iotdatahub.net:1883"
#define DEFAULT_DEBUG_OPT       DATAHUB_FALSE
#define DEFAULT_CONTEXT         NULL

/* 选项的初始化宏 */
#define DATAHUB_OPTIONS_INITIALIZER {\
DEFAULT_SERVER_URL,\
DEFAULT_DEBUG_OPT,\
DEFAULT_CONTEXT,\
}

/* 消息的初始化宏,只包含字符串结尾符'\0' */
#define DATAHUB_MESSAGE_INITIALIZER {\
1,\
""\
}

#define DATAHUB_DT_INITIALIZER {0}

/* 客户端的类型 */
typedef void* datahub_client;

/*
 * 描述: 消息的结构体类型
 */
typedef struct datahub_message_s {
    /* 消息长度，必须大于0 */
    unsigned int payload_len;
    /* 发送消息的起始地址 */
    void *payload;
} datahub_message;

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

#endif /* DSDCommonDefine_h */
