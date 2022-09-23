SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSSRSRB_ARAPReconciliation]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_ARAPReconciliation]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_ARAPReconciliation
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_ARAPReconciliation]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/
 
Select TempPay.*,
       [Bill To] = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Bill To ID]),
       [Shipper] = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Shipper ID]),
       [Consignee] = (select cmp_name from company WITH (NOLOCK) where cmp_id = [Consignee ID])
From
(
SELECT pyd_number as 'PayDetail Number', 
       pyh_number as 'PayHeader Number',
       lgh_number as 'LegHeader Number', 
       asgn_number as 'Assignment Number', 
       asgn_type as 'Resource Type', 
       IsNull(asgn_id,'') as 'Resource ID',
       CASE asgn_type
      	 WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile WITH (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      	 WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      	 WHEN 'CAR'  THEN IsNull((Select car_name from carrier WITH (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
         WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
       END AS 'Resource Name',       
       'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile WITH (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile WITH (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile WITH (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile WITH (NOLOCK) where asgn_type = 'DRV' and mpp_id = asgn_id ),'NA'), 
       'TrcType1' = IsNull((Select trc_type1 from tractorprofile WITH (NOLOCK) where asgn_type= 'TRC' and trc_number= asgn_id ),'NA'), 
       'TrcType2' = IsNull((Select trc_type2 from tractorprofile WITH (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id ),'NA'), 
       'TrcType3' = IsNull((Select trc_type3 from tractorprofile WITH (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id ),'NA'), 
       'TrcType4' = IsNull((Select trc_type4 from tractorprofile WITH (NOLOCK) where asgn_type = 'TRC' and trc_number = asgn_id),'NA'), 
       'TrlType1' = IsNull((Select  min(trl_type1) from trailerprofile WITH (NOLOCK) where asgn_type = 'TRL' and trl_id= asgn_id ),'NA'), 
       'TrlType2' = IsNull((Select  min(trl_type2) from trailerprofile WITH (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
       'TrlType3' = IsNull((Select  min(trl_type3) from trailerprofile WITH (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
       'TrlType4' = IsNull((Select  min(trl_type4) from trailerprofile WITH (NOLOCK) where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
       'CarType1' = IsNull((Select car_type1 from carrier WITH (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType2' = IsNull((Select car_type2 from carrier WITH (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType3' = IsNull((Select car_type3 from carrier WITH (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA') ,
       'CarType4' = IsNull((Select car_type4 from carrier WITH (NOLOCK) where asgn_type = 'CAR' and car_id = asgn_id ),'NA'),  
       ivd_number as 'Invoice Detail Number', 
       Case When (pyd_payto Is Null Or pyd_payto = 'UNKNOWN' Or pyd_payto = '') Then IsNull(asgn_id,'') 
			Else IsNull(pyd_payto,'')
			End as 'Pay To',
       Case When pyd_payto Is Not Null And pyd_payto <> 'UNKNOWN' And pyd_payto <> '' Then IsNull((select pto_lastfirst from payto WITH (NOLOCK) where pto_id = pyd_payto),'')
			Else CASE asgn_type
      	 			WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile WITH (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      				WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      				WHEN 'CAR'  THEN IsNull((Select car_name from carrier WITH (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
					WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
					End
			END As 'Pay To Name',
       pyt_itemcode as 'Pay Type', 
       'Pay Type Description' = (select pyt_description from paytype WITH (NOLOCK) where paytype.pyt_itemcode = paydetail.pyt_itemcode),
       paydetail.mov_number as 'Move Number', 
       pyd_description as 'Description', 
       pyr_ratecode as 'Pay Rate Code', 
       pyd_quantity as 'Quantity', 
       pyd_rateunit as 'Rate Unit', 
       pyd_unit as 'Unit', 
       pyd_rate as 'Rate', 
       IsNull(pyd_amount,0) as 'Amount', 
       pyd_pretax as 'PreTax', 
       pyd_glnum as 'GLCode', 
       pyd_currency as 'Currency Type', 
       pyd_currencydate as 'Currency Date', 
       (Cast(Floor(Cast([pyd_currencydate] as float))as smalldatetime)) as [Currency Date Only], 
       Cast(DatePart(yyyy,[pyd_currencydate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyd_currencydate]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyd_currencydate]) as varchar(2)) as [Currency Day],
       Cast(DatePart(mm,[pyd_currencydate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyd_currencydate]) as varchar(4)) as [Currency Month],
       DatePart(mm,[pyd_currencydate]) as [Currency Month Only],
       DatePart(yyyy,[pyd_currencydate]) as [Currency Year], 
       pyd_status as 'Pay Status', 
       pyd_refnumtype as 'Ref Num Type', 
       pyd_refnum as 'Ref Num', 
       pyh_payperiod as 'Pay Period Date', 
       (Cast(Floor(Cast([pyh_payperiod] as float))as smalldatetime)) as [Pay Period Date Only], 
       Cast(DatePart(yyyy,[pyh_payperiod]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyh_payperiod]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyh_payperiod]) as varchar(2)) as [Pay Period Day],
       Cast(DatePart(mm,[pyh_payperiod]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyh_payperiod]) as varchar(4)) as [Pay Period Month],
       DatePart(mm,[pyh_payperiod]) as [Pay Period Month Only],
       DatePart(yyyy,[pyh_payperiod]) as [Pay Period Year],
       pyd_workperiod as 'Work Period Date', 
       (Cast(Floor(Cast(pyd_workperiod as float))as smalldatetime)) AS 'Work Period Date Only',
       lgh_startpoint as 'Trip Start Point', 
       (select IsNull(cty_zip,'') from city WITH (NOLOCK) where cty_code = lgh_startcity) as 'Trip Start Zip Code',
       (select IsNull(cty_name,'') + ',' + IsNull(cty_state,'') from city WITH (NOLOCK) where  lgh_startcity = cty_code) as 'Trip Start City-State', 
       lgh_endpoint as 'Trip End Point', 
       (select IsNull(cty_zip,'') from city WITH (NOLOCK) where cty_code = lgh_endcity) as 'Trip End Zip Code',
       (select IsNull(cty_name,'') + ',' + IsNull(cty_state,'') from city WITH (NOLOCK) where  lgh_endcity = cty_code) as 'Trip End City-State', 
       ivd_payrevenue as 'InvoiceDetail Pay Revenue', 
       pyd_revenueratio as 'Revenue Ratio', 
       pyd_lessrevenue as 'Less Revenue', 
       pyd_payrevenue as 'PayDetail Pay Revenue', 
       pyd_transdate as 'Transaction Date', 
       (Cast(Floor(Cast(pyd_transdate as float))as smalldatetime)) as 'Transaction Date Only', 
       Cast(DatePart(yyyy,[pyd_transdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyd_transdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyd_transdate]) as varchar(2)) as [Transaction Day],
       Cast(DatePart(mm,[pyd_transdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyd_transdate]) as varchar(4)) as [Transaction Month],
       DatePart(mm,[pyd_transdate]) as [Transaction Month Only],
       DatePart(yyyy,[pyd_transdate]) as [Transaction Year],
       pyd_minus as 'Minus', 
       pyd_sequence as 'PayDetail Sequence', 
       std_number as 'StandingDeduction Number', 
       pyd_loadstate as 'Load State', 
       pyd_xrefnumber as 'Transfer Number', 
       paydetail.ord_hdrnumber as 'Order Number', 
       pyt_fee1 as 'Fee1', 
       pyt_fee2 as 'Fee2', 
       IsNull(pyd_grossamount,0) as 'Gross Amount', 
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
       (select Max(ivh_invoicestatus) from invoiceheader WITH (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [InvoiceStatus],
       (select Max(ivh_billto) from invoiceheader WITH (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill To ID],
       ord_refnum as 'ReferenceNumber',
       ord_reftype  as 'ReferenceType',
       ord_status  as 'OrderStatus',
       (select Max(ivh_billdate) from invoiceheader WITH (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill Date],
       ord_startdate  as 'Ship Date', 
       (Cast(Floor(Cast(ord_startdate as float))as smalldatetime)) AS 'Ship Date Only',
       ord_completiondate as 'Delivery Date',
       (Cast(Floor(Cast(ord_completiondate as float))as smalldatetime)) AS 'Delivery Date Only',
       ord_revtype1 as 'RevType1',
       ord_revtype2 as 'RevType2',
       ord_revtype3 as 'RevType3',
       ord_revtype4 as 'RevType4',
       ord_shipper as [Shipper ID],
       ord_consignee as [Consignee ID],
       Case When (
				  select count(*) 
				  from paydetail b WITH (NOLOCK) 
				  where paydetail.ord_hdrnumber = b.ord_hdrnumber
				  ) = 0 Then cast((select sum(ivh_totalcharge) from invoiceheader where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as float)
			Else cast((select sum(ivh_totalcharge) from invoiceheader where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as float)/ cast((select count(*) from paydetail b WITH (NOLOCK) where paydetail.ord_hdrnumber = b.ord_hdrnumber) as float)
			End as [Total Charge],
       'PayHeader Pay Status' = IsNull((select pyh_paystatus from payheader where paydetail.pyh_number = payheader.pyh_pyhnumber),'')
FROM [paydetail] WITH (NOLOCK) 
Left Join orderheader WITH (NOLOCK) 
	On orderheader.ord_hdrnumber = paydetail.ord_hdrnumber
			 
) as TempPay

GO
GRANT SELECT ON  [dbo].[vSSRSRB_ARAPReconciliation] TO [public]
GO
