# erp数据对接-销售订单变更提醒

# 目标需求

第一次订单对接过来之后，在ERP中修改了订单信息，再次对接过来时，需要给用户以提示



# 设计

1.  在MES应用中，高亮显示发生变更了的订单明细数据
2.  对接订单的数据库存储上，标示出发生变更了的订单明细数据



# 详细设计

## 数据库设计

表增加5个字段：

| 字段名          | 类型 | 说明                           |
| --------------- | ---- | ------------------------------ |
| isDel           | 数字 | 0=正常，1=已删除               |
| modifyOnErpDate | 日期 | 变更时间                       |
| syncStartDate   | 日期 | 对接程序使用，同步开始时间     |
| syncUpdateDate  | 日期 | 对接程序使用，处理时间         |
| md5             | 文本 | 对接程序使用，用于订单明细对比 |

-   modifyOnErpDate的使用原则

    第一次对接未审核订单时，将该字段设置为null。

    当订单发生变更，第二次对接时，将该字段设置为当前时间

-   syncStartDate，syncUpdateDate用于辅助处理假删除订单明细

-   md5通过订单明细的主体字段（不包括单据状态：SaleOrderState）生成，即：

```sql
  `voucherdate` datetime DEFAULT NULL COMMENT '单据日期',
  `SaleOrderCode` varchar(100) DEFAULT NULL COMMENT '单据编号',
  `partnerCode` varchar(100) DEFAULT NULL COMMENT '客户编码',
  `partnerName` varchar(255) DEFAULT NULL COMMENT '客户',
  `departmentCode` varchar(100) DEFAULT NULL COMMENT '部门编码',
  `departmentName` varchar(255) DEFAULT NULL COMMENT '部门',
  `personCode` varchar(100) DEFAULT NULL COMMENT '业务员编码',
  `personName` varchar(255) DEFAULT NULL COMMENT '业务员',
  `SettleCustomerCode` varchar(100) DEFAULT NULL COMMENT '结算客户编码',
  `SettleCustomer` varchar(255) DEFAULT NULL COMMENT '结算客户',
  `reciveTypeName` varchar(255) DEFAULT NULL COMMENT '收款方式',
  `deliveryModeName` varchar(255) DEFAULT NULL COMMENT '运输方式',
  `address` varchar(255) DEFAULT NULL COMMENT '送货地址',
  `contractCode` varchar(100) DEFAULT NULL COMMENT '合同号',
  -- 不包含该字段 `SaleOrderState` varchar(50) DEFAULT NULL COMMENT '单据状态',
  `warehouseCode` varchar(100) DEFAULT NULL COMMENT '仓库编码',
  `WarehouseName` varchar(255) DEFAULT NULL COMMENT '仓库名称',
  `inventoryCode` varchar(100) DEFAULT NULL COMMENT '存货编码',
  `inventoryName` varchar(255) DEFAULT NULL COMMENT '存货',
  `specification` varchar(255) DEFAULT NULL COMMENT '规格型号',
  `unit1Name` varchar(50) DEFAULT NULL COMMENT '销售单位',
  `quantity` decimal(18,4) DEFAULT NULL COMMENT '数量',
  `LatestSaleOrigTaxPrice` decimal(18,4) DEFAULT NULL COMMENT '最新含税售价',
  `origPrice` decimal(18,4) DEFAULT NULL COMMENT '报价',
  `discountRate` decimal(18,4) DEFAULT NULL COMMENT '折扣(%)',
  `origDiscountPrice` decimal(18,4) DEFAULT NULL COMMENT '单价',
  `taxRate` decimal(18,4) DEFAULT NULL COMMENT '税率',
  `origTaxPrice` decimal(18,4) DEFAULT NULL COMMENT '含税单价',
  `origDiscountAmount` decimal(18,4) DEFAULT NULL COMMENT '金额',
  `origTax` decimal(18,4) DEFAULT NULL COMMENT '税额',
  `origTaxAmount` decimal(18,4) DEFAULT NULL COMMENT '含税金额',
  `origDiscount` decimal(18,4) DEFAULT NULL COMMENT '折扣金额',
  `deliveryDate` datetime DEFAULT NULL COMMENT '交货日期',
  `isPresent` varchar(50) DEFAULT NULL COMMENT '赠品',
  `executedQuantity` decimal(18,4) DEFAULT NULL COMMENT '累计执行数量',
  `DetailMemo` varchar(255) DEFAULT NULL COMMENT '明细备注',
  
  `remark1` varchar(255) DEFAULT NULL,
  `remark2` varchar(255) DEFAULT NULL,
  `remark3` varchar(255) DEFAULT NULL,
  `SaleOrderDetailDTOpubuserdefnvc1` varchar(255) DEFAULT NULL,
```



## 数据逻辑

已审核订单不存在该问题，因此只处理未审核的订单数据。

   1.第一次对接订单数据之后：       

​		c1=明细ID，isDel=0，modifyOnErpDate=null

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***1



   2.第二次对接之后：

   2a.订单在ERP中修改后：保存新的md5，设置modifyOnErpDate：

​		c1=明细ID，isDel=0，modifyOnErpDate=当前时间

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***2

   2b. 未修改订单，只是审核通过，更新SaleOrderState：

​		c1=明细ID，isDel=0，modifyOnErpDate=null， SaleOrderState=生效

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***1

   2c. 订单被删除时，设置modifyOnErpDate和isDel标记：

​		c1=明细ID，isDel=1，modifyOnErpDate=当前时间

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***1

   2d. 订单未发生变化，只更新syncUpdateDate

​		c1=明细ID，isDel=0，modifyOnErpDate=null

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***1



   3.第三次对接之后：

   3a.订单在ERP中再次修改后：

​		c1=明细ID，isDel=0，modifyOnErpDate=当前时间

​						，syncStartDate=2021-07-20 11:00:00，syncUpdateDate=当前时间，md5=***3



-   判断是否修改

    将ERP中订单明细的md5和本地订单明细的md5对比

-   判断是否删除

    在同步数据之前，将所有未审的订单的syncStartDate和syncUpdateDate设为当前时间。

    由于所有数据都会被更新syncUpdateDate，因此在同步完成之后。若本地订单的 syncStartDate=syncUpdateDate，将该订单设为假删除

