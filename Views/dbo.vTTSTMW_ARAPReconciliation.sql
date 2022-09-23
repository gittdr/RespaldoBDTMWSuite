SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE                                View [dbo].[vTTSTMW_ARAPReconciliation]

As

--1. Joined to trl_id instead of trl_number 
     --also added min to avoid subquery error
     --Ver 5.1 LBK
--2. Added Currency UDF functionality for both Amount and Gross Amount
     --Ver 5.4 LBK

Select TempPay.*,
       [Bill To] = (select cmp_name from company (NOLOCK) where cmp_id = [Bill To ID]),
       [Shipper] = (select cmp_name from company (NOLOCK) where cmp_id = [Shipper ID]),
       [Consignee] = (select cmp_name from company (NOLOCK) where cmp_id = [Consignee ID])

From

(
	
SELECT pyd_number as 'PayDetail Number', 
       pyh_number as 'PayHeader Number',
       lgh_number as 'LegHeader Number', 
       asgn_number as 'Assignment Number', 
       asgn_type as 'Resource Type', 
       IsNull(asgn_id,'') as 'Resource ID',
       
       CASE asgn_type
      	 WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      	 WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      	 WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
         WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
       END AS 'Resource Name',       

       'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
 
       'TrcType1' = IsNull((Select trc_type1 from tractorprofile (NOLOCK) where asgn_type= 'TRC' and trc_number= asgn_id ),'NA'), 
       'TrcType2' = IsNull((Select trc_type2 from tractorprofile (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id ),'NA'), 
       'TrcType3' = IsNull((Select trc_type3 from tractorprofile (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id ),'NA'), 
       'TrcType4' = IsNull((Select trc_type4 from tractorprofile (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id),'NA'), 
 
       'TrlType1' = IsNull((Select  min(trl_type1) from trailerprofile (NOLOCK) where asgn_type = 'TRL' and trl_id= asgn_id ),'NA'), 
       'TrlType2' = IsNull((Select  min(trl_type2) from trailerprofile (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
       'TrlType3' = IsNull((Select  min(trl_type3) from trailerprofile (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
       'TrlType4' = IsNull((Select  min(trl_type4) from trailerprofile (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
 
       'CarType1' = IsNull((Select car_type1 from carrier (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType2' = IsNull((Select car_type2 from carrier (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType3' = IsNull((Select car_type3 from carrier (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType4' = IsNull((Select car_type4 from carrier (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA'),  
       
       ivd_number as 'Invoice Detail Number', 
       
       Case When (pyd_payto Is Null Or pyd_payto = 'UNKNOWN' Or pyd_payto = '') Then      
	    IsNull(asgn_id,'') 
       Else
	    IsNull(pyd_payto,'')
       End as 'Pay To',

       Case When pyd_payto Is Not Null And pyd_payto <> 'UNKNOWN' And pyd_payto <> '' Then
		IsNull((select pto_lastfirst from payto (NOLOCK) where pto_id = pyd_payto),'')
       Else
	   CASE asgn_type
      	 	WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      	        WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      	        WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
                WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
           End
       END As 'Pay To Name',

       pyt_itemcode as 'Pay Type', 
       'Pay Type Description' = (select pyt_description from paytype (NOLOCK) where paytype.pyt_itemcode = paydetail.pyt_itemcode),
       paydetail.mov_number as 'Move Number', 
       pyd_description as 'Description', 
       pyr_ratecode as 'Pay Rate Code', 
       pyd_quantity as 'Quantity', 
       pyd_rateunit as 'Rate Unit', 
       pyd_unit as 'Unit', 
       pyd_rate as 'Rate', 
       
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       IsNull(pyd_amount,0) as 'Amount', 
       --<TTS!*!TMW><End><SQLVersion=7>
       
       --<TTS!*!TMW><Begin><SQLVersion=2000+>	
       IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Amount', 
       --<TTS!*!TMW><End><SQLVersion=2000+>       

       pyd_pretax as 'PreTax', 
       pyd_glnum as 'GLCode', 
       pyd_currency as 'Currency Type', 
       --**Currency Date**
       pyd_currencydate as 'Currency Date', 
       --Day
       (Cast(Floor(Cast([pyd_currencydate] as float))as smalldatetime)) as [Currency Date Only], 
       Cast(DatePart(yyyy,[pyd_currencydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyd_currencydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyd_currencydate]) as varchar(2)) as [Currency Day],
       --Month
       Cast(DatePart(mm,[pyd_currencydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyd_currencydate]) as varchar(4)) as [Currency Month],
       DatePart(mm,[pyd_currencydate]) as [Currency Month Only],
       --Year
       DatePart(yyyy,[pyd_currencydate]) as [Currency Year], 
       pyd_status as 'Pay Status', 
       pyd_refnumtype as 'Ref Num Type', 
       pyd_refnum as 'Ref Num', 
       --**Pay Period Date**
       pyh_payperiod as 'Pay Period Date', 
       --Day
       (Cast(Floor(Cast([pyh_payperiod] as float))as smalldatetime)) as [Pay Period Date Only], 
       Cast(DatePart(yyyy,[pyh_payperiod]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyh_payperiod]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyh_payperiod]) as varchar(2)) as [Pay Period Day],
       --Month
       Cast(DatePart(mm,[pyh_payperiod]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyh_payperiod]) as varchar(4)) as [Pay Period Month],
       DatePart(mm,[pyh_payperiod]) as [Pay Period Month Only],
       --Year
       DatePart(yyyy,[pyh_payperiod]) as [Pay Period Year],
       pyd_workperiod as 'Work Period Date', 
       lgh_startpoint as 'Trip Start Point', 
       (select IsNull(cty_zip,'') from city (NOLOCK) where cty_code = lgh_startcity) as 'Trip Start Zip Code',
       (select IsNull(cty_name,'') + ',' + IsNull(cty_state,'') from city (NOLOCK) where  lgh_startcity = cty_code) as 'Trip Start City-State', 
       lgh_endpoint as 'Trip End Point', 
       (select IsNull(cty_zip,'') from city (NOLOCK) where cty_code = lgh_endcity) as 'Trip End Zip Code',
       (select IsNull(cty_name,'') + ',' + IsNull(cty_state,'') from city (NOLOCK) where  lgh_endcity = cty_code) as 'Trip End City-State', 
       ivd_payrevenue as 'InvoiceDetail Pay Revenue', 
       pyd_revenueratio as 'Revenue Ratio', 
       pyd_lessrevenue as 'Less Revenue', 
       pyd_payrevenue as 'PayDetail Pay Revenue', 
       --**Transaction Date**
       pyd_transdate as 'Transaction Date', 
       --Day
       (Cast(Floor(Cast(pyd_transdate as float))as smalldatetime)) as 'Transaction Date Only', 
       Cast(DatePart(yyyy,[pyd_transdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyd_transdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyd_transdate]) as varchar(2)) as [Transaction Day],
       --Month
       Cast(DatePart(mm,[pyd_transdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyd_transdate]) as varchar(4)) as [Transaction Month],
       DatePart(mm,[pyd_transdate]) as [Transaction Month Only],
       --Year
       DatePart(yyyy,[pyd_transdate]) as [Transaction Year],
       pyd_minus as 'Minus', 
       pyd_sequence as 'PayDetail Sequence', 
       std_number as 'StandingDeduction Number', 
       pyd_loadstate as 'Load State', 
       pyd_xrefnumber as 'Transfer Number', 
       paydetail.ord_hdrnumber as 'Order Number', 
       pyt_fee1 as 'Fee1', 
       pyt_fee2 as 'Fee2', 
       
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       IsNull(pyd_grossamount,0) as 'Gross Amount', 
       --<TTS!*!TMW><End><SQLVersion=7>         

       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       IsNull(dbo.fnc_convertcharge(pyd_grossamount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Gross Amount', 
       --<TTS!*!TMW><End><SQLVersion=2000+>       

       pyd_updatedby as 'Updated By',
       pyd_exportstatus as 'Export Status',
       pyd_releasedby as 'Released By', 
       paydetail.cht_itemcode as 'Charge Type Code', 
       pyd_billedweight as 'Billed Weight', 
       paydetail.tar_tarriffnumber as 'Tarrif Number', 
       pyd_updatedon as 'Updated On', 
       pyd_offsetpay_number as 'Offsetpay Number', 
       pyd_ivh_hdrnumber as 'Invoice Header Number',
       pyd_transdate as 'Transfer Date',
       (select Max(ivh_invoicestatus) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Invoice Status],
       (select Max(ivh_billto) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill To ID],
       ord_refnum as 'ReferenceNumber',
       ord_reftype  as 'ReferenceType',
       ord_status  as 'Order Status',
       (select Max(ivh_billdate) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill Date],
       ord_startdate  as 'Ship Date', 
       ord_completiondate as 'Delivery Date',
       ord_revtype1 as 'RevType1',
       ord_revtype2 as 'RevType2',
       ord_revtype3 as 'RevType3',
       ord_revtype4 as 'RevType4',
       ord_shipper as [Shipper ID],
       ord_consignee as [Consignee ID],
  
	
       Case When (select count(*) from paydetail b (NOLOCK) where paydetail.ord_hdrnumber = b.ord_hdrnumber) = 0 Then
		cast((select sum(ivh_totalcharge) from invoiceheader where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as float)
       Else
		cast((select sum(ivh_totalcharge) from invoiceheader where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as float)/ cast((select count(*) from paydetail b (NOLOCK) where paydetail.ord_hdrnumber = b.ord_hdrnumber) as float)
       End as [Total Charge],
       'PayHeader Pay Status' = IsNull((select pyh_paystatus from payheader where paydetail.pyh_number = payheader.pyh_pyhnumber),''),
       --<TTS!*!TMW><Begin><SQLVersion=7>
--       '' as 'Pay Currency Conversion Status',
       --<TTS!*!TMW><End><SQLVersion=7>
       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       IsNull(dbo.fnc_checkforvalidcurrencyconversion(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),'No Conversion Status Returned') as 'Pay Currency Conversion Status',
       --<TTS!*!TMW><End><SQLVersion=2000+>
       --<TTS!*!TMW><Begin><FeaturePack=Other>
       '' as 'Branch',
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --CASE asgn_type
      	 	--WHEN 'DRV'  THEN (Select mpp_branch from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id) 
      	 	--WHEN 'TRC'  THEN (Select trc_branch from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number) 
      	 	--WHEN 'TRL'  THEN (Select trl_branch from trailerprofile (NOLOCK) where asgn_id = trailerprofile.trl_id) 
      	 	--WHEN 'CAR'  THEN (Select car_branch from carrier (NOLOCK) where asgn_id = carrier.car_id) 
       --End as Branch,	
       --<TTS!*!TMW><End><FeaturePack=Euro>       
      
       --<TTS!*!TMW><Begin><FeaturePack=Other>
       '' as [Auth Code],
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --pyd_authcode as [Auth Code],
       --<TTS!*!TMW><End><FeaturePack=Euro>
 
       --<TTS!*!TMW><Begin><FeaturePack=Other>
       '' as [Created From]
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --pyd_created_from as [Created From]
       --<TTS!*!TMW><End><FeaturePack=Euro>
	

FROM [paydetail](NOLOCK) Left Join orderheader (NOLOCK) On orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
			 
) as TempPay



































GO
GRANT SELECT ON  [dbo].[vTTSTMW_ARAPReconciliation] TO [public]
GO
