# erp数据对接-销售订单明细ID

# 变更内容

用户需要对接未审的订单。允许在MES系统中提前对订单进行推送生产环节的操作，而后再回到ERP中
走审核流程。

# 目标表规则

目前是自动拼接生成明细ID，存储于saleorderdetail表的c1字段中。现在需要修改为：通过接口参数
SaleOrderDetailDTOpriuserdefnvc4 直接获取明细ID

# 后台对接服务程序的调整

由于额外对接的属性，不在T+接口的默认属性中。所以传给接口的参数需要明确给出要查询的属性。下
面的参数是我测试使用的，在实际程序中，ReportTableColNames需罗列出所有要对接的属性

```java
String _args = "{" + "request: {" + "\"ReportName\":
\"SA_SaleOrderDetailRpt\"," + "\"PageIndex\": " + (1) + ","
\+ "\"PageSize\": 100,"
\+ "SearchItems:" + "["
\+ " {" + "ColumnName: \"VoucherDate\", BeginDefault: \"2021-07-01\",
EndDefault: \"2021-07-16\"}"
//+ ",{" + "ColumnName: \"SaleOrderState\", BeginDefault: \"181\",
EndDefault: \"181\"}"
\+ "]"
\+ ",\"TaskSessionID\": null"
\+ ",\"ReportTableColNames\":
\"voucherID,VoucherDate,SaleOrderCode,SaleOrderState,SaleOrderDetailDTOpriuse
rdefnvc4"
\+ ",SaleOrderDetailDTOpubuserdefnvc1"
+
",SaleOrderpubuserdefnvc1,SaleOrderpubuserdefnvc2,SaleOrderpubuserdefnvc3\""
\+ ",\"SolutionID\": null" + " }"
\+ "}";
```

测试返回的结果片段如下：  

```json
{
"voucherdate" : "2021-07-12",
"SaleOrderCode" : "SO-0000005216",
"SaleOrderState" : "生效",
"SaleOrderDetailDTOpriuserdefnvc4" : "14645",
"GroupLevel" : "0",
"rowType" : "D",
"reportRowType" : null
}, {
"voucherdate" : "2021-07-12",
"SaleOrderCode" : "SO-0000005217",
"SaleOrderState" : "未审",
"SaleOrderDetailDTOpriuserdefnvc4" : "14646",
"GroupLevel" : "0",
"rowType" : "D",
"reportRowType" : null
} {
"FieldName" : "voucherdate",
"Title" : "单据日期",
"ParentFieldName" : null
}, {
"FieldName" : "SaleOrderCode",
"Title" : "单据编号",
"ParentFieldName" : null
}, {
"FieldName" : "SaleOrderState",
"Title" : "单据状态",
"ParentFieldName" : null
}, {
"FieldName" : "SaleOrderDetailDTOpriuserdefnvc4",
"Title" : "字符专用自定义项4",
"ParentFieldName" : null
}
```







# 对接逻辑

单据状态（SaleOrderState=生效）的数据：该数据为已审核的数据，不会被修改。对接成功后，不需要
再次更新
单据状态（SaleOrderState=未审）的数据：该数据会被修改。需要一直更新，直到状态为生效  