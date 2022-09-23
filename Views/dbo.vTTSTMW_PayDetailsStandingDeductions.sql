SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

















--select top 100 * from vTTSTMW_PayDetailsStandingDeductions where [standingdeduction number] = 19863

 

CREATE                                           View [dbo].[vTTSTMW_PayDetailsStandingDeductions]

 

As

 

--1. Joined to trl_id instead of trl_number 

     --also added min to avoid subquery error

     --Ver 5.1 LBK

--2. Added Currency UDF functionality for both Amount and Gross Amount

     --Ver 5.4 LBK

 

 

 

Select TempPayDetails.*,

       --**Ship Date**

       ord_startdate as 'Ship Date', 

       --Day

       (Cast(Floor(Cast([ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 

       Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_startdate]) as varchar(2)) as [Ship Day],

       --Month

       Cast(DatePart(mm,[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_startdate]) as varchar(4)) as [Ship Month],

       DatePart(mm,[ord_startdate]) as [Ship Month Only],

       --Year

       DatePart(yyyy,[ord_startdate]) as [Ship Year], 

       --**Delivery Date**

       ord_completiondate as 'Delivery Date', 

       (Cast(Floor(Cast([ord_completiondate] as float))as smalldatetime)) as [Delivery Date Only], 

       Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '-' + Cast(DatePart(dd,[ord_completiondate]) as varchar(2)) as [Delivery Day],

       --Month

       Cast(DatePart(mm,[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[ord_completiondate]) as varchar(4)) as [Delivery Month],

       DatePart(mm,[ord_completiondate]) as [Delivery Month Only],

       --Year

       DatePart(yyyy,[ord_completiondate]) as [Delivery Year]

       

 

 

From

 

(

 

 

SELECT StandingDeductionBalanceAtTime=std_startbalance - IsNull((select sum((b.pyd_amount*-1)) from paydetail b (NOLOCK) where b.std_number = paydetail.std_number and b.pyd_transdate <= paydetail.pyd_transdate),0),

            pyd_number as 'PayDetail Number', 

       pyh_number as 'PayHeader Number',

       lgh_number as 'LegHeader Number', 

       asgn_number as 'Assignment Number', 

       standingdeduction.asgn_type as 'Resource Type', 

       IsNull(standingdeduction.asgn_id,'') as 'Resource ID',

       

       CASE paydetail.asgn_type

             WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where paydetail.asgn_id = manpowerprofile.mpp_id),Cast(paydetail.asgn_id as Varchar(100))) 

             WHEN 'TRC'  THEN Cast(paydetail.asgn_id as Varchar(100))

             WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where paydetail.asgn_id = carrier.car_id),Cast(paydetail.asgn_id as Varchar(100))) 

         WHEN 'TRL'  THEN Cast(paydetail.asgn_id as Varchar(100)) 

                             Else Cast(paydetail.asgn_id as Varchar(100)) 

       END AS 'Resource Name',       

 

       'DrvType1' = IsNull((Select mpp_type1 from manpowerprofile (NOLOCK) where paydetail.asgn_type = 'DRV' and mpp_id = paydetail.asgn_id ),'NA'), 

       'DrvType2' = IsNull((Select mpp_type2 from manpowerprofile (NOLOCK) where paydetail.asgn_type = 'DRV' and mpp_id = paydetail.asgn_id ),'NA'), 

       'DrvType3' = IsNull((Select mpp_type3 from manpowerprofile (NOLOCK) where paydetail.asgn_type = 'DRV' and mpp_id = paydetail.asgn_id ),'NA'), 

       'DrvType4' = IsNull((Select mpp_type4 from manpowerprofile (NOLOCK) where paydetail.asgn_type = 'DRV' and mpp_id = paydetail.asgn_id ),'NA'), 

 

             

       'Tractor Company' = IsNull((select trc_company from tractorprofile (NOLOCK) where trc_number = paydetail.asgn_id and paydetail.asgn_type = 'TRC'),''),          

       'Tractor Division' = IsNull((select trc_division from tractorprofile (NOLOCK) where trc_number = paydetail.asgn_id and paydetail.asgn_type = 'TRC'),''),          

       'Tractor Terminal' = IsNull((select trc_terminal from tractorprofile (NOLOCK) where paydetail.asgn_id= trc_number and paydetail.asgn_type = 'TRC'),''),          

       'Tractor Fleet' = IsNull((select trc_fleet from tractorprofile (NOLOCK) where trc_number = paydetail.asgn_id and paydetail.asgn_type = 'TRC'),''),

 

       'TrcType1' = IsNull((Select trc_type1 from tractorprofile (NOLOCK) where paydetail.asgn_type= 'TRC' and trc_number= paydetail.asgn_id ),'NA'), 

       'TrcType2' = IsNull((Select trc_type2 from tractorprofile (NOLOCK) where paydetail.asgn_type = 'TRC' and trc_number = paydetail.asgn_id ),'NA'), 

       'TrcType3' = IsNull((Select trc_type3 from tractorprofile (NOLOCK) where paydetail.asgn_type = 'TRC' and trc_number = paydetail.asgn_id ),'NA'), 

       'TrcType4' = IsNull((Select trc_type4 from tractorprofile (NOLOCK) where paydetail.asgn_type = 'TRC' and trc_number = paydetail.asgn_id),'NA'), 

 

       'TrlType1' = IsNull((Select  min(trl_type1) from trailerprofile (NOLOCK) where paydetail.asgn_type = 'TRL' and trl_id= paydetail.asgn_id ),'NA'), 

       'TrlType2' = IsNull((Select  min(trl_type2) from trailerprofile (NOLOCK) where paydetail.asgn_type = 'TRL' and trl_id = paydetail.asgn_id ),'NA'), 

       'TrlType3' = IsNull((Select  min(trl_type3) from trailerprofile (NOLOCK) where paydetail.asgn_type = 'TRL' and trl_id = paydetail.asgn_id ),'NA'), 

       'TrlType4' = IsNull((Select  min(trl_type4) from trailerprofile (NOLOCK) where paydetail.asgn_type = 'TRL' and trl_id = paydetail.asgn_id ),'NA'), 

 

       'CarType1' = IsNull((Select car_type1 from carrier (NOLOCK) where paydetail.asgn_type = 'CAR' and car_id = paydetail.asgn_id ),'NA') ,

       'CarType2' = IsNull((Select car_type2 from carrier (NOLOCK) where paydetail.asgn_type = 'CAR' and car_id = paydetail.asgn_id ),'NA') ,

       'CarType3' = IsNull((Select car_type3 from carrier (NOLOCK) where paydetail.asgn_type = 'CAR' and car_id = paydetail.asgn_id ),'NA') ,

       'CarType4' = IsNull((Select car_type4 from carrier (NOLOCK) where paydetail.asgn_type = 'CAR' and car_id = paydetail.asgn_id ),'NA'),  

       

       ivd_number as 'Invoice Detail Number', 

       

       Case When (pyd_payto Is Null Or pyd_payto = 'UNKNOWN' Or pyd_payto = '') Then      

                IsNull(paydetail.asgn_id,'') 

       Else

                IsNull(pyd_payto,'')

       End as 'Pay To',

 

       Case When pyd_payto Is Not Null And pyd_payto <> 'UNKNOWN' And pyd_payto <> '' Then

                        IsNull((select pto_lastfirst from payto (NOLOCK) where pto_id = pyd_payto),'')

       Else

               CASE paydetail.asgn_type

                        WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where paydetail.asgn_id = manpowerprofile.mpp_id),Cast(paydetail.asgn_id as Varchar(100))) 

                    WHEN 'TRC'  THEN Cast(paydetail.asgn_id as Varchar(100))

                    WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where paydetail.asgn_id = carrier.car_id),Cast(paydetail.asgn_id as Varchar(100))) 

                WHEN 'TRL'  THEN Cast(paydetail.asgn_id as Varchar(100))

                                        Else Cast(paydetail.asgn_id as Varchar(100)) 

           End

       END As 'Pay To Name',

 

       

       paydetail.pyt_itemcode as 'Pay Type', 

       'Pay Type Description' = (select pyt_description from paytype (NOLOCK) where paytype.pyt_itemcode = paydetail.pyt_itemcode),

       mov_number as 'Move Number', 

       pyd_description as 'Description', 

       pyr_ratecode as 'Pay Rate Code', 

       pyd_quantity as 'Quantity', 

       pyd_rateunit as 'Rate Unit', 

       pyd_unit as 'Unit', 

       pyd_rate as 'Rate', 

       

       --<TTS!*!TMW><Begin><SQLVersion=7>
--
--
--       IsNull(pyd_amount,0) as 'Amount', 
--
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

       (select IsNull(cty_state,'') + ',' + IsNull(cty_state,'') from city (NOLOCK) where lgh_startcity = cty_code) as 'Trip Start State', 

       lgh_endpoint as 'Trip End Point', 

       (select IsNull(cty_zip,'') from city (NOLOCK) where cty_code = lgh_endcity) as 'Trip End Zip Code',

       (select IsNull(cty_name,'') + ',' + IsNull(cty_state,'') from city (NOLOCK) where  lgh_endcity = cty_code) as 'Trip End City-State', 

       (select IsNull(cty_state,'') + ',' + IsNull(cty_state,'') from city (NOLOCK) where lgh_endcity = cty_code) as 'Trip End State', 

       ivd_payrevenue as 'InvoiceDetail Pay Revenue', 

       pyd_revenueratio as 'Revenue Ratio', 

       pyd_lessrevenue as 'Less Revenue', 

       pyd_payrevenue as 'PayDetail Pay Revenue', 

       --**Transaction Date**

       ISNull(pyd_transdate,std_issuedate) as 'Transaction Date', 

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

       standingdeduction.std_number as 'StandingDeduction Number', 

       pyd_loadstate as 'Load State', 

       pyd_xrefnumber as 'Transfer Number', 

       ord_hdrnumber as 'Order Number', 

       pyt_fee1 as 'Fee1', 

       pyt_fee2 as 'Fee2', 

       

       --<TTS!*!TMW><Begin><SQLVersion=7>
--
--       IsNull(pyd_grossamount,0) as 'Gross Amount', 
--
       --<TTS!*!TMW><End><SQLVersion=7>         

 

       --<TTS!*!TMW><Begin><SQLVersion=2000+>

       IsNull(dbo.fnc_convertcharge(pyd_grossamount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Gross Amount', 

       --<TTS!*!TMW><End><SQLVersion=2000+>       

 

       pyd_updatedby as 'Updated By',

       pyd_exportstatus as 'Export Status',

       pyd_releasedby as 'Released By', 

       cht_itemcode as 'Charge Type Code', 

       pyd_billedweight as 'Billed Weight', 

       tar_tarriffnumber as 'Tarrif Number', 

       pyd_updatedon as 'Updated On', 

       pyd_offsetpay_number as 'Offsetpay Number', 

       pyd_ivh_hdrnumber as 'Invoice Header Number',

       --**Transfer Date**

       pyd_transferdate as 'Transfer Date', 

       --Day

       (Cast(Floor(Cast(pyd_transferdate as float))as smalldatetime)) as 'Transfer Date Only', 

       Cast(DatePart(yyyy,[pyd_transferdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[pyd_transferdate]) as varchar(2)) + '-' + Cast(DatePart(dd,[pyd_transferdate]) as varchar(2)) as [Transfer Day],

       --Month

       Cast(DatePart(mm,[pyd_transferdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[pyd_transferdate]) as varchar(4)) as [Transfer Month],

       DatePart(mm,[pyd_transferdate]) as [Transfer Month Only],

       --Year

       DatePart(yyyy,[pyd_transferdate]) as [Transfer Year],

       (select Max(ivh_invoicestatus) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Invoice Status],

       (select Max(ivh_billto) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill To ID],

       (select ord_refnum from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'ReferenceNumber',

       (select ord_reftype from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'ReferenceType',

       (select ord_status from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'Order Status',

       (select Max(ivh_billdate) from invoiceheader (NOLOCK) where paydetail.ord_hdrnumber = invoiceheader.ord_hdrnumber) as [Bill Date],

       (select ord_startdate from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as ord_startdate, 

       (select ord_completiondate from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as ord_completiondate,

       (select ord_revtype1 from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'RevType1',

       (select ord_revtype2 from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'RevType2',

       (select ord_revtype3 from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'RevType3',

       (select ord_revtype4 from orderheader (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber) as 'RevType4',

       [Order Origin City] = (select min(cty_name) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and cty_code = ord_origincity),

       [Order Origin State] = (select min(cty_state) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and cty_code = ord_origincity),

       [Order Dest City] = (select min(cty_name) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and cty_code = ord_destcity),

       [Order Dest State] = (select min(cty_state) from orderheader (NOLOCK),city (NOLOCK) where orderheader.ord_hdrnumber = paydetail.ord_hdrnumber and cty_code = ord_destcity),

            'PayHeader Pay Status' = IsNull((select pyh_paystatus from payheader where paydetail.pyh_number = payheader.pyh_pyhnumber),''),

       --<TTS!*!TMW><Begin><SQLVersion=7>
--
--       '' as 'Pay Currency Conversion Status',
--
       --<TTS!*!TMW><End><SQLVersion=7>

       --<TTS!*!TMW><Begin><SQLVersion=2000+>

       IsNull(dbo.fnc_checkforvalidcurrencyconversion(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),'No Conversion Status Returned') as 'Pay Currency Conversion Status',

       --<TTS!*!TMW><End><SQLVersion=2000+>

       

       --<TTS!*!TMW><Begin><FeaturePack=Other>

       '' as 'Branch',

       --<TTS!*!TMW><End><FeaturePack=Other>

       --<TTS!*!TMW><Begin><FeaturePack=Euro>

       --IsNull((select lgh_booked_revtype1 from legheader (NOLOCK) where legheader.lgh_number = paydetail.lgh_number),'') as Branch,

       --<TTS!*!TMW><End><FeaturePack=Euro>       

      

       --<TTS!*!TMW><Begin><FeaturePack=Other>

       '' as [Auth Code],

       --<TTS!*!TMW><End><FeaturePack=Other>

       --<TTS!*!TMW><Begin><FeaturePack=Euro>

       --pyd_authcode as [Auth Code],

       --<TTS!*!TMW><End><FeaturePack=Euro>

 

        --<TTS!*!TMW><Begin><FeaturePack=Other> 

        '' as [Trip Origin Country],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_country from city (NOLOCK) where cty_code = lgh_startcity) as 'Trip Origin Country',

            --<TTS!*!TMW><End><FeaturePack=Euro> 

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

            '' as [Trip Destination Country],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_country from city (NOLOCK) where cty_code = lgh_endcity) as 'Trip Destination Country',

            --<TTS!*!TMW><End><FeaturePack=Euro>          

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

        '' as [Trip Origin Zip Code],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_zip from city (NOLOCK) where cty_code = lgh_startcity) as 'Trip Origin Zip Code',

            --<TTS!*!TMW><End><FeaturePack=Euro> 

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

            --'' as [Trip Destination Zip Code],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_zip from city (NOLOCK) where cty_code = lgh_endcity) as 'Trip Destination Zip Code',

            --<TTS!*!TMW><End><FeaturePack=Euro>         

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

        '' as [Order Origin Country],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_country from city (NOLOCK),orderheader (NOLOCK) where cty_code = ord_origincity and paydetail.ord_hdrnumber = orderheader.ord_hdrnumber) as 'Order Origin Country',

            --<TTS!*!TMW><End><FeaturePack=Euro> 

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

            '' as [Order Destination Country],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_country from city (NOLOCK),orderheader (NOLOCK) where cty_code = ord_destcity and paydetail.ord_hdrnumber = orderheader.ord_hdrnumber) as 'Order Destination Country',

            --<TTS!*!TMW><End><FeaturePack=Euro>         

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

        '' as [Order Origin Zip Code],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_zip from city (NOLOCK),orderheader (NOLOCK) where cty_code = ord_origincity and paydetail.ord_hdrnumber = orderheader.ord_hdrnumber) as 'Order Origin Zip Code',

            --<TTS!*!TMW><End><FeaturePack=Euro> 

 

            --<TTS!*!TMW><Begin><FeaturePack=Other> 

            '' as [Order Destination Zip Code],

            --<TTS!*!TMW><End><FeaturePack=Other> 

            --<TTS!*!TMW><Begin><FeaturePack=Euro> 

            --(select cty_zip from city (NOLOCK),orderheader (NOLOCK) where cty_code = ord_destcity and paydetail.ord_hdrnumber = orderheader.ord_hdrnumber) as 'Order Destination Zip Code',

            --<TTS!*!TMW><End><FeaturePack=Euro>

 

            --<TTS!*!TMW><Begin><FeaturePack=Other>

        '' as [Created From],

        --<TTS!*!TMW><End><FeaturePack=Other>

        --<TTS!*!TMW><Begin><FeaturePack=Euro>

        --pyd_created_from as [Created From]

        --<TTS!*!TMW><End><FeaturePack=Euro>

            

            

            [sdm_itemcode] as [Standing Deduction Type],

            [std_description] as [Standing Deduction Description],

            [std_balance]  as [Balance] ,

            [std_startbalance] as [Start Balance] ,

            [std_endbalance] as [End Balance] ,

            [std_deductionrate] as [Deduction Rate] ,

            [std_reductionrate] as [Reduction Rate] ,

            [std_status] as [Standing Deduction Status]   ,

            [std_issuedate] as [Issue Date]  ,

            [std_closedate] as [Close Date]  ,

            

            [std_priority] as [Standing Deduction Priority],

            isnull (std_lastdeddate,std_issuedate) as [Last Deduction Date]  ,

            [std_lastreddate] as [Last Reduction Date]  ,

            [std_lastcompdate] as [Last Comp Date]  ,

            [std_lastcalcdate]  as [Last Calc Date] ,

            [std_lastdedqty]  as [Last Deduction Qty],

            [std_lastredqty] as [Last Reduction Qty],

            [std_lastcompqty] as [Last Comp Qty]  ,

            [std_lastcalcqty]  as [Last Calc Qty] ,

            [std_priordeddate] as [Prior Deduction Date]  ,

            [std_priorreddate] as [Prior Reduction Date]  ,

            [std_priorcompdate] as [Prior Comp Date],

            [std_priorcalcdate]  as [Prior Calc Date] ,

            [std_priordedqty] as [Prior Deduction Qty]  ,

            [std_priorredqty] as [Prior Reduction Qty]  ,

            [std_priorcompqty] as [Prior Comp Qty]  ,

            [std_priorcalcqty] as [Prior Calc Qty]  ,

            [std_priorbalance]  as [Prior Balance],

            [HasFinalBondYN] = IsNull((select Top 1 'Y' from standingdeduction b (NOLOCK) where b.asgn_id = standingdeduction.asgn_id and std_description Like '%final bond%'),'N')

            /*CASE 

                        WHEN asgn_type = 'DRV'  THEN IsNull((Select mpp_terminal from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),'') 

            End as [Driver Terminal],

            CASE 

                        WHEN asgn_type = 'TRC'  THEN IsNull((Select trc_terminal from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number),'') 

            End as [Tractor Terminal],

 

            CASE 

                        WHEN asgn_type = 'DRV'  THEN IsNull((Select mpp_division from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),'') 

            End as [Driver Division],

            CASE 

                        WHEN asgn_type = 'TRC'  THEN IsNull((Select trc_division from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number),'') 

            End as [Tractor Division]*/

 

FROM standingdeduction (NOLOCK) Left Join [paydetail](NOLOCK) --Inner Join stdmaster On paydetail.pyt_itemcode = stdmaster.pyt_itemcode

                                       On standingdeduction.std_number = paydetail.std_number --and paydetail.asgn_type = standingdeduction.asgn_type and paydetail.asgn_id = standingdeduction.asgn_id

 

) As TempPayDetails

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 



GO
