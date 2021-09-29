# erp数据对接

# T+接口

http://tplusdev.chanjet.com/library/56f0976ae881e0686a4c5eb0

# 接口测试java代码

```java
public class OpenAPI {
	public static final String URL = "http://23c90j4151.wicp.vip:15269/TPlus/api/v2/";
	public static final String AppKey = "b88bee6d-4b9d-46b9-89e3-b63e73af290f";
	public static final String AppSecret = "biqrnr";
	public static final String OrgId = "";// 云服务id
	public static final String PemFile = "E:\\VsProject\\TplusOpenAPI_TestTool\\服务控制器\\cjet_pri.pkcs8";// key私匙文件地址

	public static final String USER = "05";// 账套用户名
	public static final String PWD = "18618286421";// =============   账套密码
	public static final String ZT = "1";// 账套
	public static String Access_Token_str = "";// 持久化登录成功后获取的token

	public static void main(String[] args) throws Exception {
		// 登录
		Login(USER, PWD, ZT);
		
		// 业务 "ReportTableColNames": "VoucherDate,VoucherCode,CustomerCode,CustomerName",
		String _args = "{" + "request: {" + "\"ReportName\": \"SA_SaleDeliveryDetailRpt\"," + "\"PageIndex\": " + (1) + ","
				+ "\"PageSize\": 100," 
				+ "SearchItems:" + "[{" + "ColumnName: \"VoucherDate\","
				+ "BeginDefault: \"2021-02-20\"," + "BeginDefaultText: \"2021-03-01\"," 
				+ "EndDefault: \"2021-03-06\","	+ "EndDefaultText: \"2021-03-06\"" + "}," 
				+ "{" + "ColumnName: \"voucherState\","
				+ "BeginDefault: \"189\"," + "BeginDefaultText: \"189\"," 
				+ "EndDefault: \"189\","	+ "EndDefaultText: \"189\"" + "}]," 
				//+ "BeginDefault: \"2021-02-01\"," + "BeginDefaultText: \"2021-02-01\"," 
				//+ "EndDefault: \"2021-03-26\","	+ "EndDefaultText: \"2021-03-26\"" + "}]," 
				+ "\"TaskSessionID\": null," 
				//+ "\"ReportTableColNames\": \"id,auditdate,cID,VoucherDate,VoucherCode\"," 
				+ "\"SolutionID\": null" + " }"
				+ "}";		
		Business(_args, "reportQuery/GetReportData");
	}
	public static ObjectMapper mapper = new ObjectMapper();

	static {
	    mapper.enable(SerializationFeature.INDENT_OUTPUT);
	
	    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
	}

	public static String Login(String username, String password, String accNum) throws Exception {
		OpenAPI api = new OpenAPI();
		SignatureManage manage = new SignatureManage();
		String authStr = manage.CreateAuthorizationHeader(AppKey, AppSecret, OrgId, PemFile, null);
		String accInfo = "{\"userName\":\"" + username + "\",\"password\":\"" + manage.getMD5(password)
				+ "\",\"accNum\":\"" + accNum + "\"}";
		String token = api.getToken(authStr, accInfo);
		// 从登录成功返回的字符串中解析出Token并持久化，以便后面业务请求调用
		Access_Token_str = getJson(token, "access_token");
		System.out.println("Access_Token:"+Access_Token_str);
		return token;
	}

	@SuppressWarnings("unchecked")
	public static String Business(String params, String parameter) throws Exception {
		OpenAPI api = new OpenAPI();
		SignatureManage manage = new SignatureManage();
		String authStr1 = manage.CreateAuthorizationHeader(AppKey, AppSecret, OrgId, PemFile, Access_Token_str);
		String retValue = api.getData(parameter, authStr1, params);
		Map<String, Object> map = mapper.readValue(retValue, Map.class);
		System.out.println(mapper.writeValueAsString(map));
		return retValue;
	}

	@SuppressWarnings("unchecked")
	public static String getJson(String jsonStr, String key) throws Exception {
		Map<String, Object> map = mapper.readValue(jsonStr, Map.class);
		//JsonObject json = new JsonParser().parse(jsonStr).getAsJsonObject();
		return map.get(key).toString();
	}

	// 业务的请求
	public String getData(String methodName, String authStr, String paras) throws Exception {
		String result="";
		try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
		    HttpPost httpPost = new HttpPost(URL + methodName);
		    httpPost.addHeader("Content-Type", "application/x-www-form-urlencoded");
		    httpPost.addHeader("Authorization", authStr);
		    
		    List<NameValuePair> nvps = new ArrayList<NameValuePair>();
		    nvps.add(new BasicNameValuePair("_args", paras));
		    httpPost.setEntity(new UrlEncodedFormEntity(nvps));

		    try (CloseableHttpResponse response2 = httpclient.execute(httpPost)) {
		        HttpEntity entity2 = response2.getEntity();
		        result = IOUtils.toString(entity2.getContent(), "UTF-8");
		        // do something useful with the response body
		        // and ensure it is fully consumed
		        EntityUtils.consume(entity2);
		    }
		}
		
		return result;
	}

	// 登录的请求
	private String getToken(String authStr, String accInfo) throws Exception {
		String result="";
		try (CloseableHttpClient httpclient = HttpClients.createDefault()) {
		    HttpPost httpPost = new HttpPost(URL + "collaborationapp/GetRealNameTPlusToken?IsFree=1");
		    httpPost.addHeader("Content-Type", "application/x-www-form-urlencoded");
		    httpPost.addHeader("Authorization", authStr);
		    
		    List<NameValuePair> nvps = new ArrayList<NameValuePair>();
		    nvps.add(new BasicNameValuePair("_args", accInfo));
		    httpPost.setEntity(new UrlEncodedFormEntity(nvps));

		    try (CloseableHttpResponse response2 = httpclient.execute(httpPost)) {
		        HttpEntity entity2 = response2.getEntity();
		        result = IOUtils.toString(entity2.getContent(), "UTF-8");
		        EntityUtils.consume(entity2);
		    }
		}
		
		return result;
	}

}
```



# ERP对接对象和规则

| 类别 | 对接对象                                      | 规则                                      | 设计建议（同步频率和数据的时间跨度可在系统运行之后调整）     |
| ---- | --------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------ |
| 销售 | 销售订单明细表 SA_SaleOrderDetailRpt          | 过滤条件：单据状态（SaleOrderState=生效） | 每5分钟同步一次当天数据<br />每60分钟同步一次最近10天的数据  |
|      | 销货单明细表  SA_SaleDeliveryDetailRpt        | 过滤条件：单据状态（voucherState=生效）   | 每10分钟同步一次当天数据<br />每60分钟同步一次最近10天的数据 |
|      |                                               |                                           |                                                              |
| 库存 | 采购入库单明细表 ST_PurchaseReceiveDetailRpt  | 整表同步                                  | 每10分钟同步一次最新数据                                     |
|      | 销售出库单明细表 ST_SaleDispatchDetailRpt     | 整表同步                                  | 每10分钟同步一次最新数据                                     |
|      | 产成品入库单明细表 ST_ProductReceiveDetailRpt | 整表同步                                  | 每10分钟同步一次最新数据                                     |
|      | 材料出库单明细表 ST_MaterialDispatchDetailRpt | 整表同步                                  | 每10分钟同步一次最新数据                                     |
|      |                                               |                                           |                                                              |

- 同步时只做插入同步。后续数据在erp中修改和删除后，同步服务不处理
- 同步频率和数据的时间跨度可根据实际业务需要调整
- 主键需要在同步数据的时候，自动生成，规则为：单据编号_序号。序号从1开始
            例如单据编号为：MD-2021-02-0003
            则自动生成的id为： 
                                           MD-2021-02-0003_1
                                           MD-2021-02-0003_2



# V3平台接收数据的表结构

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
   `c1` varchar(100) DEFAULT '',
   `c2` varchar(100) DEFAULT '',
   `c3` varchar(100) DEFAULT '',
   `c4` text,
   `c5` text,
   `c6` text,
   `c7` varchar(100) DEFAULT '未推送',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=9306 DEFAULT CHARSET=utf8



CREATE TABLE `saledispatchdetail` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `VoucherDate` datetime DEFAULT NULL COMMENT '单据日期',
   `VoucherCode` varchar(100) DEFAULT NULL COMMENT '单据编号',
   `BusinessType` varchar(100) DEFAULT NULL COMMENT '业务类型',
   `WarehouseCode` varchar(100) DEFAULT NULL COMMENT '仓库编码',
   `Warehouse` varchar(100) DEFAULT NULL COMMENT '仓库',
   `DispatchStyle` varchar(100) DEFAULT NULL COMMENT '出库类别',
   `CustomerCode` varchar(100) DEFAULT NULL COMMENT '客户编码',
   `Customer` varchar(100) DEFAULT NULL COMMENT '客户',
   `DepartmentCode` varchar(100) DEFAULT NULL COMMENT '部门编码',
   `Department` varchar(100) DEFAULT NULL COMMENT '部门',
   `ClerkCode` varchar(100) DEFAULT NULL COMMENT '经手人编码',
   `Clerk` varchar(100) DEFAULT NULL COMMENT '经手人',
   `Maker` varchar(100) DEFAULT NULL COMMENT '制单人',
   `InventoryCode` varchar(100) DEFAULT NULL COMMENT '存货编码',
   `Inventory` varchar(100) DEFAULT NULL COMMENT '存货',
   `Specification` varchar(100) DEFAULT NULL COMMENT '规格型号',
   `Unit` varchar(100) DEFAULT NULL COMMENT '计量单位',
   `DeliveryQuantity` decimal(18,4) DEFAULT NULL COMMENT '应发数量',
   `Quantity` decimal(18,4) DEFAULT NULL COMMENT '数量',
   `Price` decimal(18,4) DEFAULT NULL COMMENT '成本价',
   `Amount` decimal(18,4) DEFAULT NULL COMMENT '成本金额',
   `DispatchAdjust` decimal(18,4) DEFAULT NULL COMMENT '出库调整',
   `SaleOrderCode` varchar(100) DEFAULT NULL COMMENT '销售订单号',
   `ReceiveVoucherCode` varchar(100) DEFAULT NULL COMMENT '入库单号',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=9272 DEFAULT CHARSET=utf8 COMMENT='销售出库单明细'



CREATE TABLE `saledeliverydetail` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `voucherdate` datetime DEFAULT NULL COMMENT '单据日期',
   `saleDeliveryCode` varchar(100) DEFAULT NULL COMMENT '单据编号',
   `partnerName` varchar(100) DEFAULT NULL COMMENT '客户',
   `personName` varchar(100) DEFAULT NULL COMMENT '业务员',
   `ConsignorCode` varchar(100) DEFAULT NULL COMMENT '发货人编码',
   `ConsignorName` varchar(100) DEFAULT NULL COMMENT '发货人',
   `maker` varchar(100) DEFAULT NULL COMMENT '制单人',
   `voucherState` varchar(100) DEFAULT NULL COMMENT '单据状态',
   `saleOutName` varchar(100) DEFAULT NULL COMMENT '整单出库状态',
   `specification` varchar(100) DEFAULT NULL COMMENT '规格型号',
   `quantity` decimal(18,4) DEFAULT NULL COMMENT '数量',
   `LatestSaleOrigTaxPrice` decimal(18,4) DEFAULT NULL COMMENT '最新含税售价',
   `origPrice` decimal(18,4) DEFAULT NULL COMMENT '报价',
   `discountRate` decimal(18,4) DEFAULT NULL COMMENT '折扣%',
   `origDiscountPrice` decimal(18,4) DEFAULT NULL COMMENT '单价',
   `origTaxPrice` decimal(18,4) DEFAULT NULL COMMENT '含税单价',
   `origDiscountAmount` decimal(18,4) DEFAULT NULL COMMENT '金额',
   `origTax` decimal(18,4) DEFAULT NULL COMMENT '税额',
   `origTaxAmount` decimal(18,4) DEFAULT NULL COMMENT '含税金额',
   `origDiscount` decimal(18,4) DEFAULT NULL COMMENT '折扣金额',
   `deliveryDate` datetime DEFAULT NULL COMMENT '交货日期',
   `saleOutQuantity` decimal(18,4) DEFAULT NULL COMMENT '累计出库数量',
   `saleOutAmount` decimal(18,4) DEFAULT NULL COMMENT '累计出库金额',
   `SDDetailorigSettleAmount` decimal(18,4) DEFAULT NULL COMMENT '累计结款金额',
   `saleOrderCode` varchar(100) DEFAULT NULL COMMENT '销售订单号',
   `Auditor` varchar(100) DEFAULT NULL COMMENT '审核人',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=9774 DEFAULT CHARSET=utf8 COMMENT='销货单明细'


CREATE TABLE `purchasereceivedetail` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `VoucherDate` datetime DEFAULT NULL COMMENT '单据日期',
   `VoucherCode` varchar(100) DEFAULT NULL COMMENT '单据编号',
   `BusinessType` varchar(100) DEFAULT NULL COMMENT '业务类型',
   `WarehouseCode` varchar(100) DEFAULT NULL COMMENT '仓库编码',
   `Warehouse` varchar(100) DEFAULT NULL COMMENT '仓库',
   `ReceiveStyle` varchar(100) DEFAULT NULL COMMENT '入库类别',
   `VendorCode` varchar(100) DEFAULT NULL COMMENT '供应商编码',
   `Vendor` varchar(255) DEFAULT NULL COMMENT '供应商',
   `DepartmentCode` varchar(100) DEFAULT NULL COMMENT '部门编码',
   `Department` varchar(100) DEFAULT NULL COMMENT '部门',
   `ClerkCode` varchar(100) DEFAULT NULL COMMENT '经手人编码',
   `Clerk` varchar(100) DEFAULT NULL COMMENT '经手人',
   `Memo` varchar(255) DEFAULT NULL COMMENT '备注',
   `Maker` varchar(100) DEFAULT NULL COMMENT '制单人',
   `InventoryCode` varchar(100) DEFAULT NULL COMMENT '存货编码',
   `Inventory` varchar(100) DEFAULT NULL COMMENT '存货',
   `Specification` varchar(100) DEFAULT NULL COMMENT '规格型号',
   `Unit` varchar(100) DEFAULT NULL COMMENT '计量单位',
   `Quantity` decimal(18,4) DEFAULT NULL COMMENT '实收数量',
   `origPrice` decimal(18,4) DEFAULT NULL COMMENT '单价',
   `origAmount` decimal(18,4) DEFAULT NULL COMMENT '金额',
   `ReceiveAdjust` decimal(18,4) DEFAULT NULL COMMENT '入库调整',
   `Feeadjust` decimal(18,4) DEFAULT NULL COMMENT '费用调整',
   `Totalamount` decimal(18,4) DEFAULT NULL COMMENT '总成本',
   `Feeamount` decimal(18,4) DEFAULT NULL COMMENT '费用金额',
   PRIMARY KEY (`id`)
 ) ENGINE=InnoDB AUTO_INCREMENT=9317 DEFAULT CHARSET=utf8

CREATE TABLE `materialdispatchdetailrpt` (
   `VoucherCode` varchar(200) DEFAULT NULL,
   `BusinessType` varchar(100) DEFAULT NULL,
   `VoucherDate` date DEFAULT NULL,
   `WarehouseCode` varchar(100) DEFAULT NULL,
   `Warehouse` varchar(100) DEFAULT NULL,
   `DispatchStyle` varchar(100) DEFAULT NULL,
   `DepartmentCode` varchar(100) DEFAULT NULL,
   `Department` varchar(100) DEFAULT NULL,
   `ClerkCode` varchar(100) DEFAULT NULL,
   `Clerk` varchar(100) DEFAULT NULL,
   `Maker` varchar(100) DEFAULT NULL,
   `Auditor` varchar(100) DEFAULT NULL,
   `InventoryCode` varchar(100) DEFAULT NULL,
   `Inventory` varchar(100) DEFAULT NULL,
   `Specification` varchar(100) DEFAULT NULL,
   `Unit` varchar(100) DEFAULT NULL,
   `Quantity` double DEFAULT NULL,
   `Price` double DEFAULT NULL,
   `Amount` double DEFAULT NULL,
   `GroupLevel` varchar(50) DEFAULT NULL,
   `rowType` varchar(50) DEFAULT NULL,
   `reportRowType` varchar(50) DEFAULT NULL,
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `DispatchAdjust` double DEFAULT NULL,
   UNIQUE KEY `id` (`id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8

CREATE TABLE `productreceivedetailrpt` (
   `VoucherCode` varchar(200) DEFAULT NULL,
   `BusinessType` varchar(100) DEFAULT NULL,
   `VoucherDate` date DEFAULT NULL,
   `WarehouseCode` varchar(100) DEFAULT NULL,
   `Warehouse` varchar(100) DEFAULT NULL,
   `ReceiveStyle` varchar(100) DEFAULT NULL,
   `DepartmentCode` varchar(100) DEFAULT NULL,
   `Department` varchar(100) DEFAULT NULL,
   `ClerkCode` varchar(100) DEFAULT NULL,
   `Clerk` varchar(100) DEFAULT NULL,
   `Memo` varchar(200) DEFAULT NULL,
   `Maker` varchar(100) DEFAULT NULL,
   `Auditor` varchar(100) DEFAULT NULL,
   `InventoryCode` varchar(100) DEFAULT NULL,
   `Inventory` varchar(100) DEFAULT NULL,
   `Specification` varchar(100) DEFAULT NULL,
   `Unit` varchar(100) DEFAULT NULL,
   `ReceiveQuantity` double DEFAULT NULL,
   `Price` double DEFAULT NULL,
   `Amount` double DEFAULT NULL,
   `GroupLevel` varchar(50) DEFAULT NULL,
   `rowType` varchar(50) DEFAULT NULL,
   `reportRowType` varchar(50) DEFAULT NULL,
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   UNIQUE KEY `id` (`id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8
```



# 接口数据实例

​		参见：《[接口数据.xlsx](http://112.126.101.177:9000/jiangxiyuanyang/%E6%8E%A5%E5%8F%A3%E6%95%B0%E6%8D%AE.xlsx)》