# erp数据对接 - 财务

# 目标需求

​		接入erp的财务数据。实现手机端，可以查看月度和年度的：应收总账、实收总账、应付总账、实付总账



# 表结构

​		数据存储设计为按月存储；年度总账需自行将12个月的数据做累加

```sql
CREATE TABLE `accountsummonthly` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `voucherdate` datetime DEFAULT NULL COMMENT '报表月份',
   `receiveAccountOrig` double DEFAULT NULL COMMENT '应收总账',
   `receiveAccountOrigSettle` double DEFAULT NULL COMMENT '实收总账',
   `paymentAccountOrig` double DEFAULT NULL COMMENT '应付总账',
   `paymentAccountOrigSettle` double DEFAULT NULL COMMENT '实付总账',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8
```



# ERP对接对象和规则

| 类别 | 对接对象                            | 规则                                                         | 设计建议<br />（同步频率和数据的时间跨度可在系统运行之后调整） |
| ---- | ----------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 财务 | 应收总账 ARAP_ReceiveAccountSumRpt  | 按月度的时间段过滤后，将GroupLevel=0 的数据分别求和<br />应收总账字段为：origAmount<br />实收总账字段为：origSettleAmount | 每60分钟同步一次最近两月数据                                 |
|      | 应付总账  ARAP_PaymentAccountSumRpt | 按月度的时间段过滤后，将GroupLevel=0 的数据分别求和<br />应付总账字段为：origAmount<br />实付总账字段为：origSettleAmount | 每60分钟同步一次最近两月数据                                 |
|      |                                     |                                                              |                                                              |

- 第一次同步数据，需同步所有数据
- 



# 接口数据实例

​		参见：《[接口数据 - 财务总账.xlsx](http://112.126.101.177:9000/jiangxiyuanyang/%E6%8E%A5%E5%8F%A3%E6%95%B0%E6%8D%AE%20-%20%E8%B4%A2%E5%8A%A1%E6%80%BB%E8%B4%A6.xlsx)》