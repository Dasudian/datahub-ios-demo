## 介绍

该项目为大数点工业大数据分析和设备管理服务的数据采集端的Objective-C SDK的Demo程序，其中包含了SDK库文件本身和一个使用该SDK的Demo程序，演示如何在iOS设备上集成大数点IoT DataHub SDK以实现设备数据的采集。

大数点工业大数据服务让设备变得有生命，并让其整个生命周期为你管理，让她的每一次呼吸（产生数据）在大数点云端为你变现！关于如何获得大数点工业大数据分析服务，请联系大数点顾问团队sales@dasudian.com或support@dasudian.com，我们将竭诚为您展示大数点丰富多彩而致力于解决实际问题的数据分析服务。

本文档介绍了当前目录结构和每个文件的作用，如何编译和运行demo程序。如果你想知道API的细节，请阅读docs目录下的API文档或者头文件[DataHubCommon.h](./include/DataHubCommon.h)、[DataHubClient.h](./include/DataHubClient.h)

## 目录结构说明

有四大目录：demo, docs, include, lib

### demo目录

DatahubDemo.xcodeproj目录存放的是工程文件

DataHubDemo/ViewController.m集成了SDK，可以发送消息，订阅和取消订阅主题。

其他文件可以忽略

### docs目录

API.pdf 包含了SDK的所有API, 或者你也可以查看头文件[DataHubClient.h](./include/DataHubClient.h)

### include目录

头文件[DataHubCommon.h](./include/DataHubCommon.h)、[DataHubClient.h](./include/DataHubClient.h)应该被包含在工程项目中

### lib目录

该目录下有最新的SDK库

## 编译和运行demo

在Mac下使用XCode打开DatahubDemo.xcodeproj工程目录文件,直接编译运行即可

## Test environment of demo applications

demo程序的测试环境

1. 平台: OS X EI Capitan 10.11.6

2. 编译器: XCode 8.2.1(8C1002)

3. 模拟器：iPhone 5

## 线程安全

提供的API都是线程安全的
