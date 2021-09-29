# erp数据对接 - 需求变更1

# 变更内容

用户需要额外对接销售订单（SA_SaleOrderDetailRpt）的3个属性：产品备注，产品备注2，产品备注3

# 目标表结构

较之前的表结构增加了3个字段：remark1，remark2，remark3

```sql
CREATE TABLE `saleorderdetail` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uid` bigint(20) DEFAULT '0',
  `orgid` bigint(20) DEFAULT '0',
  `wwywctime` datetime DEFAULT CURRENT_TIMESTAMP,
  `usercode` varchar(60) DEFAULT NULL,
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
  `SaleOrderState` varchar(50) DEFAULT NULL COMMENT '单据状态',
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
  `c1` varchar(100) DEFAULT NULL,
  `c2` varchar(100) DEFAULT '',
  `c3` varchar(100) DEFAULT '',
  `c4` text,
  `c5` text,
  `c6` text,
  `c7` varchar(100) DEFAULT '未推送',
  `c8` varchar(100) DEFAULT '',
  `c9` varchar(100) DEFAULT '',
  `c10` datetime DEFAULT NULL,
  `remark1` varchar(255) DEFAULT NULL,
  `remark2` varchar(255) DEFAULT NULL,
  `remark3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `订单编号` (`c1`)
) ENGINE=InnoDB AUTO_INCREMENT=12495 DEFAULT CHARSET=utf8;
```

# 后台对接服务程序的调整

由于额外对接的属性，不在T+接口的默认属性中。所以传给接口的参数需要明确给出要查询的属性。下面的参数是我测试使用的，在实际程序中，ReportTableColNames需罗列出所有要对接的属性

```java
String _args = "{" + "request: {" + "\"ReportName\": \"SA_SaleOrderDetailRpt\"," + "\"PageIndex\": " + (1) + ","
		+ "\"PageSize\": 100," 
		+ "SearchItems:" + "[{" + "ColumnName: \"VoucherDate\","
		+ "BeginDefault: \"2021-01-01\"," + "BeginDefaultText: \"2021-01-01\"," 
		+ "EndDefault: \"2021-01-30\","	+ "EndDefaultText: \"2021-01-30\"" + "}" 
		+ "]," 
		+ "\"TaskSessionID\": null," 
		+ "\"ReportTableColNames\": \"VoucherDate,SaleOrderCode"
		+ ",SaleOrderpubuserdefnvc1,SaleOrderpubuserdefnvc2,SaleOrderpubuserdefnvc3\"," 
		+ "\"SolutionID\": null" + " }"
		+ "}";
```

测试返回的结果片段如下：

```json
{
      "voucherdate" : "2021-01-18",
      "SaleOrderCode" : "SO-0000004321",
      "SaleOrderpubuserdefnvc1" : "材料：立柱1.4.托板.挂板.侧板.门板1.0.下架2.8.其余全0.8.路轨预埋已生产.不要再生产路轨.以上合为一个团体.移动列一边开门.固定列封假门背板.前后侧板三节式.中间深咖色.侧板2500高.电",
      "SaleOrderpubuserdefnvc2" : "动公司配.采用讯森电动.电动标准配置.每组配2层（15mm厚）樟木板.樟木板公司配.书车轮子自配.采用园子的.要商标.不要电话.纸箱包装.",
      "SaleOrderpubuserdefnvc3" : "",
      "GroupLevel" : "0",
      "rowType" : "D",
      "reportRowType" : null
    }
    

    
"ColumnSource" : {
    "Rows" : [ {
      "FieldName" : "voucherdate",
      "Title" : "单据日期",
      "ParentFieldName" : null
    }, {
      "FieldName" : "SaleOrderCode",
      "Title" : "单据编号",
      "ParentFieldName" : null
    }, {
      "FieldName" : "SaleOrderpubuserdefnvc1",
      "Title" : "产品备注",
      "ParentFieldName" : null
    }, {
      "FieldName" : "SaleOrderpubuserdefnvc2",
      "Title" : "产品备注2",
      "ParentFieldName" : null
    }, {
      "FieldName" : "SaleOrderpubuserdefnvc3",
      "Title" : "产品备注3",
      "ParentFieldName" : null
    } ]
  }
```

因此erp数据对接的字段对应关系为：

SaleOrderpubuserdefnvc1   ->   remark1

SaleOrderpubuserdefnvc2   ->   remark2

SaleOrderpubuserdefnvc3   ->   remark3