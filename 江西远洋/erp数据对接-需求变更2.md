# erp数据对接 - 需求变更2

# 变更内容

用户需要额外对接销售订单（SA_SaleOrderDetailRpt）的1个属性：产品规格

# 目标表结构

较之前的表结构增加了1个字段：   SaleOrderDetailDTOpubuserdefnvc1

```sql
CREATE TABLE `saleorderdetail` (
    ……
  `SaleOrderDetailDTOpubuserdefnvc1` varchar(255) DEFAULT NULL,
    ……
) ENGINE=InnoDB AUTO_INCREMENT=12495 DEFAULT CHARSET=utf8;
```

# 后台对接服务程序的调整

由于额外对接的属性，不在T+接口的默认属性中。所以传给接口的参数需要明确给出要查询的属性。下面的参数是我测试使用的，在实际程序中，ReportTableColNames需罗列出所有要对接的属性

```java
String _args = "{" + "request: {" + "\"ReportName\": \"SA_SaleOrderDetailRpt\"," + "\"PageIndex\": " + (1) + ","
    + "\"PageSize\": 100," 
    + "SearchItems:" + "["
    + " {" + "ColumnName: \"VoucherDate\", BeginDefault: \"2021-05-25\", EndDefault: \"2021-05-26\"}" 
    //+ ",{" + "ColumnName: \"SaleOrderState\", BeginDefault: \"181\", EndDefault: \"181\"}" 
    + "]" 
    + ",\"TaskSessionID\": null" 
    + ",\"ReportTableColNames\": \"VoucherDate,SaleOrderCode,specification,SaleOrderState"
    + ",SaleOrderDetailDTOpubuserdefnvc1"
    + ",SaleOrderpubuserdefnvc1,SaleOrderpubuserdefnvc2,SaleOrderpubuserdefnvc3\"" 
    + ",\"SolutionID\": null" + " }"
    + "}";
```

测试返回的结果片段如下：

```json
{
      "voucherdate" : "2021-05-25",
      "SaleOrderCode" : "SO-0000004927",
      "SaleOrderpubuserdefnvc1" : "材料：外1.内托0.7加筋.天地栓.园手柄.2个一字锁.铁轮100mm高.文件柜结构.3托4空（可调高低）.",
      "SaleOrderpubuserdefnvc2" : "",
      "SaleOrderpubuserdefnvc3" : "",
      "SaleOrderState" : "生效",
      "specification" : "",
      "SaleOrderDetailDTOpubuserdefnvc1" : "900*400*1850",
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
    }, {
      "FieldName" : "SaleOrderState",
      "Title" : "单据状态",
      "ParentFieldName" : null
    }, {
      "FieldName" : "specification",
      "Title" : "规格型号",
      "ParentFieldName" : null
    }, {
      "FieldName" : "SaleOrderDetailDTOpubuserdefnvc1",
      "Title" : "产品规格",
      "ParentFieldName" : null
    } ]
}
```

因此erp数据对接的字段对应关系为：

SaleOrderDetailDTOpubuserdefnvc1->   SaleOrderDetailDTOpubuserdefnvc1
