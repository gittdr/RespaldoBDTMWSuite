SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_PayDetails]

AS
/**
 *
 * NAME:
 * dbo.vSSRSRB_PayDetails
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 * 
 * REVISION HISTORY:
 * select * from vSSRSRB_PayDetails
 * 3/19/2014 MREED created 
 * 7/31/2014 MREED added info from payschedule
 * 08/27/2015 MREED - fixed [Bill to ID] beucase it would pull 0 ord_hdrnumber items.
 **/
SELECT 
	ISNULL(pyd_amount,0) AS [Amount],  
	asgn_number AS [Assignment Number],
	(select Min(ivh_billdate) from invoiceheader with(NOLOCK) where pyd.ord_hdrnumber = invoiceheader.ord_hdrnumber) AS [Bill Date],
	[Bill To ID] = (select Max(ivh_billto) from invoiceheader  with(NOLOCK) where pyd.ord_hdrnumber = invoiceheader.ord_hdrnumber and invoiceheader.ord_hdrnumber <> 0),
	pyd_billedweight AS [Billed Weight],
	[pyd_carinvdate] AS [Carrier Invoice Date], 
	[pyd_carinvnum] AS [Carrier Invoice Number],		
	ISNULL(carasgn.car_type1,'NA') AS [CarType1],
	ISNULL(carasgn.car_type2,'NA') AS [CarType2],
	ISNULL(carasgn.car_type3,'NA') AS [CarType3],
	ISNULL(carasgn.car_type4,'NA') AS [CarType4],	   
	pyd.cht_itemcode AS [Charge Type Code],
	[Created By] = 
		ISNULL((select pa1.pyd_updatedby 
				from paydetailaudit pa1  with(NOLOCK) 
				where pa1.pyd_number = pyd.pyd_number and pa1.audit_sequence = 
					(select min(pa2.audit_sequence) 
					 from paydetailaudit pa2 with(NOLOCK) 
					 where pa2.pyd_number = pyd.pyd_number)),pyd_updatedby
					 ),
    [Created Date] = 
		ISNULL((select pa1.pyd_updatedon 
				from paydetailaudit pa1  with(NOLOCK) 
				where pa1.pyd_number = pyd.pyd_number and pa1.audit_sequence = 
					(select min(pa2.audit_sequence) 
					 from paydetailaudit pa2  with(NOLOCK) 
					 where pa2.pyd_number = pyd.pyd_number)),pyd_updatedon
					 ),	
    pyd_currencydate AS [Currency Date], 
    (CAST(Floor(CAST([pyd_currencydate] AS float))as smalldatetime)) AS [Currency Date Only], 
    [Currency Day] = 
		CAST(DatePart(yyyy,[pyd_currencydate]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[pyd_currencydate]) AS VARCHAR(2)) 
			+ '-' + CAST(DatePart(dd,[pyd_currencydate]) AS VARCHAR(2)),
    [Currency Month] = CAST(DatePart(mm,[pyd_currencydate]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[pyd_currencydate]) AS VARCHAR(4)),
    DatePart(mm,[pyd_currencydate]) AS [Currency Month Only],
    pyd_currency AS [Currency Type],
    DatePart(yyyy,[pyd_currencydate]) AS [Currency Year],    
    ord_completiondate AS [Delivery Date], 
    (CAST(Floor(CAST([ord_completiondate] AS float))as smalldatetime)) AS [Delivery Date Only], 
    CAST(DatePart(yyyy,[ord_completiondate]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[ord_completiondate]) AS VARCHAR(2)) + '-' + CAST(DatePart(dd,[ord_completiondate]) AS VARCHAR(2)) AS [Delivery Day],
    CAST(DatePart(mm,[ord_completiondate]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[ord_completiondate]) AS VARCHAR(4)) AS [Delivery Month],
    DatePart(mm,[ord_completiondate]) AS [Delivery Month Only],
    DatePart(yyyy,[ord_completiondate]) AS [Delivery Year],     	 
	pyd_description AS [Description],	
	ISNULL(mppasgn.mpp_company,'') AS [Driver Company],
	ISNULL(mppasgn.mpp_division,'') AS [Driver Division],
	ISNULL(mppasgn.mpp_domicile,'') AS [Driver Domicile],
	ISNULL(mppasgn.mpp_fleet,'') AS [Driver Fleet],
	ISNULL(mppasgn.mpp_terminal,'') AS [Driver Terminal],   	
	ISNULL(mppasgn.mpp_type1,'NA') AS [DrvType1],
	ISNULL(mppasgn.mpp_type2,'NA') AS [DrvType2],
	ISNULL(mppasgn.mpp_type3,'NA') AS [DrvType3],
	ISNULL(mppasgn.mpp_type4,'NA') AS [DrvType4],	
	pyd_exportstatus AS [Export Status],
	pyd.pyt_fee1 AS [Fee1], 
    pyd.pyt_fee2 AS [Fee2], 
	pyd_glnum AS [GLCode],
	ISNULL(pyd_grossamount,0) AS [Gross Amount],  
	ivd_number AS [Invoice Detail Number],
	pyd_ivh_hdrnumber AS [Invoice Header Number],
	[InvoiceStatus] =
	ISNULL((select Max(ivh_invoicestatus) from invoiceheader  with(NOLOCK)  where pyd.ord_hdrnumber = invoiceheader.ord_hdrnumber),''),
	[Invoice Transfer Date] = (select Min(ivh_xferdate) from invoiceheader  with(NOLOCK)  where pyd.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	ivd_payrevenue AS [Invoice Detail Pay Revenue],
	pyd_lessrevenue AS [Less Revenue],   
	pyd.lgh_number AS [Leg Number],
	pyd_loadstate AS [Load State],
	pyd_minus AS [Minus],
	pyd.mov_number AS [Move Number],
	pyd_offsetpay_number AS [Offsetpay Number],
	[Order Dest City] = (select min(cty_name) from orderheader (NOLOCK),city  with(NOLOCK)  where orderheader.ord_hdrnumber = pyd.ord_hdrnumber and cty_code = ord_destcity),
    [Order Dest State] = (select min(cty_state) from orderheader (NOLOCK),city  with(NOLOCK)  where orderheader.ord_hdrnumber = pyd.ord_hdrnumber and cty_code = ord_destcity), 
	pyd.ord_hdrnumber AS [Order Header Number],
	ord.ord_number as [Order Number],
	[Order Origin City] = (select min(cty_name) from orderheader (NOLOCK),city  with(NOLOCK)  where orderheader.ord_hdrnumber = pyd.ord_hdrnumber and cty_code = ord_origincity),
    [Order Origin State] = (select min(cty_state) from orderheader (NOLOCK),city  with(NOLOCK)  where orderheader.ord_hdrnumber = pyd.ord_hdrnumber and cty_code = ord_origincity),
	ord.ord_status AS [OrderStatus],	
	CASE asgn_type
  		WHEN 'DRV'  THEN ISNULL(mpp.mpp_otherid,'') 
 	    ELSE '' 
    END AS [Other ID],
	[Pay Detail Category] = 
		CASE WHEN pyd_pretax = 'Y' and pyd_minus = 1 THEN 'Compensation' 
			 WHEN pyd_pretax = 'N' and pyd_minus = 1 THEN 'Reimbursement'
			 WHEN pyd_minus < 0 THEN 'Deduction' 
		END, 	
	pyh_payperiod AS [Pay Period Date], 
    (CAST(Floor(CAST([pyh_payperiod] AS float))as smalldatetime)) AS [Pay Period Date Only], 
    [Pay Period Day] = 
		CAST(DatePart(yyyy,[pyh_payperiod]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[pyh_payperiod]) AS VARCHAR(2)) 
			+ '-' + CAST(DatePart(dd,[pyh_payperiod]) AS VARCHAR(2)),
    [Pay Period Month] = CAST(DatePart(mm,[pyh_payperiod]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[pyh_payperiod]) AS VARCHAR(4)),
    DatePart(mm,[pyh_payperiod]) AS [Pay Period Month Only],
    DatePart(yyyy,[pyh_payperiod]) AS [Pay Period Year],		
    pyr_ratecode AS [Pay Rate Code],
    pyd_status AS [Pay Status],     
	CASE WHEN (pyd_payto Is Null Or pyd_payto = 'UNKNOWN' Or pyd_payto = '') THEN ISNULL(asgn_id,'') 
		ELSE ISNULL(pyd_payto,'')
    END AS [PayTo ID],     
    pyd.pyt_itemcode AS [Pay Type],
    pyt.pyt_description AS [Pay Type Description],
    pyd_number AS [Pay Detail Number], 
    pyd_payrevenue AS [Pay Detail Pay Revenue], 
    pyd_sequence AS [Pay Detail Sequence],    
    pyh_number AS [Pay Header Number], 
    [Pay Header Pay Status] = ISNULL((select pyh_paystatus from payheader with(NOLOCK)  where pyd.pyh_number = payheader.pyh_pyhnumber),''),
    pto_address1 AS [PayTo Address1], 
    pto_address2 AS [PayTo Address2],
    city.cty_name AS [PayTo City Name],
    pto_company AS [PayTo Company ID], 
    pto_companyname AS [PayTo Company Name],
    pto_createdate AS [PayTo Created Date], 
    pto_currency AS [PayTo Currency],
    pto_dirdeposit AS [PayTo Direct Deposit],  
    pto_division AS [PayTo Division],  
    pto_fname AS [PayTo First Name],
    pto_fleet AS [PayTo Fleet],
    pto_fleettrc AS [PayTo FleetTrc], 
    pto_lname AS [PayTo Last Name], 
    pto_lastfirst AS [PayTo LastFirst Name],  
    pto_mname AS [PayTo Middle Name],
    pto_misc1 AS [PayTo Misc1], 
	pto_misc2 AS [PayTo Misc2], 
	pto_misc3 AS [PayTo Misc3], 
	pto_misc4 AS [PayTo Misc4],	
	CASE WHEN pyd_payto Is Not Null And pyd_payto <> 'UNKNOWN' And pyd_payto <> '' 
		 THEN ISNULL(payto.pto_lastfirst,'')
		 ELSE
			CASE asgn_type
				WHEN 'DRV'  THEN ISNULL(mpp.mpp_lastfirst,CAST(asgn_id AS VARCHAR(100))) 
				WHEN 'CAR'  THEN ISNULL(car.car_name,CAST(asgn_id AS VARCHAR(100))) 
				ELSE CAST(asgn_id AS VARCHAR(100)) 
			END
    END AS [Pay To Name],    
    pto_status AS [PayTo PayTo Status], 
    pto_phone1 AS [PayTo Phone Number1], 
	pto_phone2 AS [PayTo Phone Number2], 
	pto_phone3 AS [PayTo Phone Number3],
    pto_ssn AS [PayTo Social Security Number],
    pto_socsecfedtax AS [PayTo SocSecFedTax],
    pto_startdate AS [PayTo Start Date], 
    city.cty_state AS [PayTo State], 
    pto_terminal AS [PayTo Terminal], 
    pto_terminatedate AS [PayTo Termination Date], 
    pto_type1 AS [PayTo Type1], 
	pto_type2 AS [PayTo Type2], 
	pto_type3 AS [PayTo Type3], 
	pto_type4 AS [PayTo Type4], 
    pto_updatedby AS [PayTo Updated By],
    pto_updateddate AS [PayTo Updated Date],
    pto_yrtodategross AS [PayTo Year To Date Gross],    
    pto_zip AS [PayTo Zip Code],  
    pto_altid AS [PayToAltID], 
    pyd_pretax AS [PreTax],   
    pyd_quantity AS [Quantity],
    pyd_rate AS [Rate],    
    pyd_rateunit AS [Rate Unit],
	pyd_refnum AS [Ref Num],  
    pyd_refnumtype AS [Ref Num Type],
    ord.ord_refnum AS [Reference Number],
    ord.ord_reftype AS [Reference Type],
    pyd_releasedby AS [Released By],  
    ISNULL(asgn_id,'') AS [Resource ID],	
	CASE asgn_type
  		WHEN 'DRV'  THEN ISNULL(mpp.mpp_lastfirst,CAST(asgn_id AS VARCHAR(100))) 
  		WHEN 'CAR'  THEN ISNULL(car.car_name,CAST(asgn_id AS VARCHAR(100))) 
		ELSE CAST(asgn_id AS VARCHAR(100)) 
    END AS [Resource Name], 	   
    asgn_type AS [Resource Type],
	pyd_revenueratio AS [Revenue Ratio], 
	ord.ord_revtype1 AS [RevType1],
    ord.ord_revtype2 AS [RevType2],
    ord.ord_revtype3 AS [RevType3],
    ord.ord_revtype4 AS [RevType4],
    ord_startdate AS [Ship Date], 
    (CAST(Floor(CAST([ord_startdate] AS float))as smalldatetime)) AS [Ship Date Only], 
    CAST(DatePart(yyyy,[ord_startdate]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[ord_startdate]) AS VARCHAR(2)) + '-' + CAST(DatePart(dd,[ord_startdate]) AS VARCHAR(2)) AS [Ship Day],
    CAST(DatePart(mm,[ord_startdate]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[ord_startdate]) AS VARCHAR(4)) AS [Ship Month],
    DatePart(mm,[ord_startdate]) AS [Ship Month Only],
    DatePart(yyyy,[ord_startdate]) AS [Ship Year], 
    std_number AS [StandingDeduction Number],    
    pyd.tar_tarriffnumber AS [Tarrif Number],
    [Team Leader ID] = 
		CASE WHEN asgn_type = 'TRC' 
			 THEN ISNULL(lgh.mpp_teamleader,(select mpp_teamleader from manpowerprofile,tractorprofile where mpp_id = trc_driver and asgn_id = trc_number))
	         WHEN asgn_type = 'DRV' 
	         THEN ISNULL(lgh.mpp_teamleader,(select mpp_teamleader from manpowerprofile where mpp_id =  asgn_id))
	         ELSE ISNULL(lgh.mpp_teamleader,'')
	         END,     
    ISNULL(trcasgn.trc_company,'') AS [Tractor Company],
    ISNULL(trcasgn.trc_division,'') AS [Tractor Division],
    ISNULL(trcasgn.trc_fleet,'') AS [Tractor Fleet],
    ISNULL(trcasgn.trc_terminal,'') AS [Tractor Terminal], 
    pyd_transdate AS [Transaction Date], 
    (CAST(Floor(CAST(pyd_transdate AS float))as smalldatetime)) AS [Transaction Date Only], 
    [Transaction Day] = 
		CAST(DatePart(yyyy,[pyd_transdate]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[pyd_transdate]) AS VARCHAR(2)) 
			+ '-' + CAST(DatePart(dd,[pyd_transdate]) AS VARCHAR(2)),
    [Transaction Month] = CAST(DatePart(mm,[pyd_transdate]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[pyd_transdate]) AS VARCHAR(4)),
    DatePart(mm,[pyd_transdate]) AS [Transaction Month Only],
    DatePart(yyyy,[pyd_transdate]) AS [Transaction Year],     
    pyd_transferdate AS [Transfer Date], 
    (CAST(Floor(CAST(pyd_transferdate AS float))as smalldatetime)) AS [Transfer Date Only], 
    [Transfer Day] = 
		CAST(DatePart(yyyy,[pyd_transferdate]) AS VARCHAR(4)) +  '-' + CAST(DatePart(mm,[pyd_transferdate]) AS VARCHAR(2)) 
			+ '-' + CAST(DatePart(dd,[pyd_transferdate]) AS VARCHAR(2)),
    [Transfer Month] = CAST(DatePart(mm,[pyd_transferdate]) AS VARCHAR(2)) + '/' + CAST(DatePart(yyyy,[pyd_transferdate]) AS VARCHAR(4)),
    DatePart(mm,[pyd_transferdate]) AS [Transfer Month Only],    
	pyd_xrefnumber AS [Transfer Number],
	DatePart(yyyy,[pyd_transferdate]) AS [Transfer Year],	
	ISNULL(trcasgn.trc_type1,'NA') AS [TrcType1],
	ISNULL(trcasgn.trc_type2,'NA') AS [TrcType2],  
	ISNULL(trcasgn.trc_type3,'NA') AS [TrcType3], 
	ISNULL(trcasgn.trc_type4,'NA') AS [TrcType4],
    CASE WHEN destcty.cty_name IS NULL AND destcty.cty_state IS NULL THEN NULL
		 ELSE ISNULL(destcty.cty_name,'') + ',' + ISNULL(destcty.cty_state,'') 
	END AS [Trip End City-State],	   
    lgh_endpoint AS [Trip End Point],    
    CASE WHEN destcty.cty_state IS NULL THEN NULL
		 ELSE ISNULL(destcty.cty_state,'') + ',' + ISNULL(destcty.cty_state,'') 
	END AS [Trip End State],	
	CASE WHEN destcty.cty_name IS NULL THEN destcty.cty_zip
		 ELSE ISNULL(destcty.cty_zip,'')
	END AS [Trip End Zip Code],
    CASE WHEN origcty.cty_name IS NULL AND origcty.cty_state IS NULL THEN NULL
		 ELSE ISNULL(origcty.cty_name,'') + ',' + ISNULL(origcty.cty_state,'') 
	END AS [Trip Start City-State], 		
    lgh_startpoint AS [Trip Start Point],    
     CASE WHEN origcty.cty_state IS NULL THEN NULL
		 ELSE ISNULL(origcty.cty_state,'') + ',' + ISNULL(origcty.cty_state,'') 
	END AS [Trip Start State],         
    CASE WHEN origcty.cty_name IS NULL THEN origcty.cty_zip
		 ELSE ISNULL(origcty.cty_zip,'')
	END AS [Trip Start Zip Code],
	ISNULL(lgh.lgh_tractor,'UNKNOWN')AS [Trip Tractor ID],			
	[TrlType1] = ISNULL((Select  min(trl_type1) from trailerprofile  with(NOLOCK)  where asgn_type = 'TRL' and trl_id= asgn_id ),'NA'), 
    [TrlType2] = ISNULL((Select  min(trl_type2) from trailerprofile  with(NOLOCK)  where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
    [TrlType3] = ISNULL((Select  min(trl_type3) from trailerprofile  with(NOLOCK)  where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 
    [TrlType4] = ISNULL((Select  min(trl_type4) from trailerprofile  with(NOLOCK)  where asgn_type = 'TRL' and trl_id = asgn_id ),'NA'), 	   
    pyd_unit AS [Unit],
    pyd_updatedby AS [Updated By], 
    pyd_updatedon AS [Updated On], 
    pyd_workperiod AS [Work Period Date],
    psd_chkissuedate as [Check Issue Date] 

FROM paydetail pyd with(NOLOCK) 
LEFT JOIN manpowerprofile mpp  with(NOLOCK) ON mpp.mpp_id = pyd.asgn_id
LEFT JOIN manpowerprofile mppasgn  with(NOLOCK)  ON mppasgn.mpp_id = pyd.asgn_id AND pyd.asgn_type = 'DRV'
LEFT JOIN carrier car  with(NOLOCK)  ON car.car_id = pyd.asgn_id
LEFT JOIN carrier carasgn  with(NOLOCK)  ON carasgn.car_id = pyd.asgn_id and pyd.asgn_type = 'CAR'
LEFT JOIN tractorprofile trcasgn  with(NOLOCK)  on trcasgn.trc_number = pyd.asgn_id and pyd.asgn_type = 'TRC'
LEFT JOIN paytype pyt  with(NOLOCK) ON pyt.pyt_itemcode = pyd.pyt_itemcode
LEFT JOIN city origcty  with(NOLOCK)  ON origcty.cty_code = pyd.lgh_startcity
LEFT JOIN city destcty with(NOLOCK)  ON destcty.cty_code = pyd.lgh_endcity
LEFT JOIN orderheader ord  with(NOLOCK)  ON ord.ord_hdrnumber = pyd.ord_hdrnumber
LEFT JOIN legheader lgh  with(NOLOCK)  ON lgh.lgh_number = pyd.lgh_number
LEFT JOIN payto  with(NOLOCK)  ON payto.pto_id = pyd.pyd_payto
LEFT JOIN city  with(NOLOCK)  ON city.cty_code = payto.pto_city
left join payschedulesdetail  with(NOLOCK)  on payschedulesdetail.psd_id = pyd.psd_id




GO
GRANT SELECT ON  [dbo].[vSSRSRB_PayDetails] TO [public]
GO
