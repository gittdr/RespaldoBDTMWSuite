SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO








CREATE                   PROCEDURE [dbo].[sp_TTSTMW_OutstandingPayDetails]
			(	@paytypelist varchar(200),	-- no spaces between parameters.
				@Fromdate datetime,
				@Todate datetime,
				@currency_flag char(20),
                		@targeted_currency char(20)
			)		
AS
--Author: Brent Keeton
--********************************************************************
--Purpose: Show outstanding pay details that
--haven't transferred to the Accounting Package
--********************************************************************
--Revision History: 
--1. Added UDF Currency Converting Functionality
--   Ver 5.4 LBK
--2. Changed report to look off pyd_amount instead of pyd_grossamount
--   Ver 5.4 LBK
Declare @OnlyBranches as varchar(255)
--<TTS!*!TMW><Begin><FeaturePack=Other>
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Set @OnlyBranches = ',' + ISNULL( (Select usr_booking_terminal from ttsusers where usr_userid= user),'UNK') + ','
--If (Select count(*) from ttsusers where usr_userid= user and (usr_supervisor='Y' or usr_sysadmin='Y')) > 0 or user = 'dbo' 
--
--BEGIN
--
--Set @onlyBranches = 'ALL'
--
--END
--<TTS!*!TMW><End><FeaturePack=Euro>
select 	@paytypelist = ',' + ltrim(rtrim(@paytypelist)) + ','
SELECT   left(pyd_transdate, 11) as 'TransDate',
	 
	 --<TTS!*!TMW><Begin><SQLVersion=7>
	 IsNull(pyd_amount,0) as Amount, 
	 --<TTS!*!TMW><End><SQLVersion=7> 
         
	  --<TTS!*!TMW><Begin><SQLVersion=2000+>
	  --IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Amount', 
          --<TTS!*!TMW><End><SQLVersion=2000+> 	
	 asgn_id as ID, 
	 asgn_type as Type, 
	 pyt_itemcode as 'AdvCode', 
         left(pyd_description,20) as Description,
	 ord_hdrnumber as 'OrderNo',
         pyd_status as status, 
         left(pyh_payperiod, 11) as 'payperiod',
	 pyd_currency as 'NewCurrency',
	 --<TTS!*!TMW><Begin><FeaturePack=Other>
        ' ' as 'Branch'
        --<TTS!*!TMW><End><FeaturePack=Other>
        --<TTS!*!TMW><Begin><FeaturePack=Euro>
        --CASE paydetail.asgn_type
      	 	--WHEN 'DRV'  THEN (Select mpp_branch from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id) 
      	 	--WHEN 'TRC'  THEN (Select trc_branch from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number) 
      	 	--WHEN 'TRL'  THEN (Select trl_branch from trailerprofile (NOLOCK) where asgn_id = trailerprofile.trl_id) 
      	 	--WHEN 'CAR'  THEN (Select car_branch from carrier (NOLOCK) where asgn_id = carrier.car_id) 
       --End as Branch	
       --<TTS!*!TMW><End><FeaturePack=Euro>   
--<TTS!*!TMW><Begin><FeaturePack=Other>

--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--into #TempPayDetails
--<TTS!*!TMW><End><FeaturePack=Euro>
FROM	 paydetail
WHERE    paydetail.pyh_number = 0 
         and 
         charindex((',' + rtrim(pyt_itemcode) + ','), @paytypelist, 1) > 0 
         and
	 pyd_transdate between @FromDate and @ToDate
	
UNION
SELECT 	left(pyd_transdate, 11) as 'TransDate',
        
	--<TTS!*!TMW><Begin><SQLVersion=7>
	IsNull(pyd_amount,0) as Amount,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,paydetail.pyh_payperiod),0.00) as 'Amount', 
	--<TTS!*!TMW><End><SQLVersion=2000+>        
	paydetail.asgn_id as ID, 
        paydetail.asgn_type as Type, 
        pyt_itemcode as 'AdvCode', 
        left(pyd_description,20) as Description,
	ord_hdrnumber as 'OrderNo', 
        pyd_status as status, 
        left(paydetail.pyh_payperiod, 11) as 'payperiod',
	pyd_currency as 'NewCurrency',
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       ' ' as 'Branch'
      --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --CASE paydetail.asgn_type
      	 	--WHEN 'DRV'  THEN (Select mpp_branch from manpowerprofile (NOLOCK) where paydetail.asgn_id = manpowerprofile.mpp_id) 
      	 	--WHEN 'TRC'  THEN (Select trc_branch from tractorprofile (NOLOCK) where paydetail.asgn_id = tractorprofile.trc_number) 
      	 	--WHEN 'TRL'  THEN (Select trl_branch from trailerprofile (NOLOCK) where paydetail.asgn_id = trailerprofile.trl_id) 
      	 	--WHEN 'CAR'  THEN (Select car_branch from carrier (NOLOCK) where paydetail.asgn_id = carrier.car_id) 
       --End as Branch	
       --<TTS!*!TMW><End><FeaturePack=Euro>   
	
FROM	paydetail, payheader
WHERE   payheader.pyh_pyhnumber = paydetail.pyh_number 
        and
	payheader.pyh_paystatus <> 'XFR' 
        and
	(@paytypelist = ',,' OR CHARINDEX(',' + pyt_itemcode + ',', @paytypelist) > 0) 
        and  
        pyd_transdate between @FromDate and @ToDate
	
--<TTS!*!TMW><Begin><FeaturePack=Other>
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Select * from #TempPayDetails
--Where
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + Branch + ',', @onlyBranches) > 0) 
       --)	
--<TTS!*!TMW><End><FeaturePack=Euro>








GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_OutstandingPayDetails] TO [public]
GO
