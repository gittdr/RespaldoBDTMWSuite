SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE                   Procedure [dbo].[sp_TTSTMWResourcePayReportFromPayDetails] (@asgntype as Varchar(100),
                                    @paystatus as Varchar (100),
                                    @frmdt datetime,
				    @tdt datetime,
				    @showpaytoifexists char(1)='N' 
				    )
As
--Revision History
--1. Added show pay to if exists option Ver 5.4 LBK
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
SELECT @asgntype = ',' + LTRIM(RTRIM(ISNULL(@asgntype, ''))) + ','
SELECT @paystatus = ',' + LTRIM(RTRIM(ISNULL(@paystatus, ''))) + ','
SELECT Case When @showpaytoifexists = 'Y' Then
       	    Case When (pyh_payto Is Null Or pyh_payto = 'UNKNOWN' Or pyh_payto = '') Then      
	    	 IsNull(asgn_id,'') 
       	    Else
	    	 IsNull(pyh_payto,'')
       	    End 
       Else
	   IsNull(asgn_id,'') 
       End as 'ResourceID',
       Case When @showpaytoifexists = 'Y' Then 
      	   Case When pyh_payto Is Not Null And pyh_payto <> 'UNKNOWN' And pyh_payto <> '' Then
		IsNull((select pto_lastfirst from payto (NOLOCK) where pto_id = pyh_payto),'')
       	   Else
	   	CASE asgn_type
      	 		WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      	        	WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      	        	WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
                	WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
           	End
       	   END
       Else
		CASE asgn_type
      	 		WHEN 'DRV'  THEN IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id),Cast(asgn_id as Varchar(100))) 
      	        	WHEN 'TRC'  THEN Cast(asgn_id as Varchar(100))
      	        	WHEN 'CAR'  THEN IsNull((Select car_name from carrier (NOLOCK) where asgn_id = carrier.car_id),Cast(asgn_id as Varchar(100))) 
                	WHEN 'TRL'  THEN Cast(asgn_id as Varchar(100)) 
           	End
       End As 'ReportName',
       pyh_payperiod AS PayPeriod, 
       --<TTS!*!TMW><Begin><SQLVersion=7>
       'Compe' = (Select Sum(IsNull(pyd_amount,0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_pretax = 'Y' and pyd_minus = 1), 
       --<TTS!*!TMW><End><SQLVersion=7> 
	
       --<TTS!*!TMW><Begin><SQLVersion=2000+>       
       --'Compe' = IsNull((Select Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_pretax = 'Y' and pyd_minus = 1),0.00), 
       --<TTS!*!TMW><End><SQLVersion=2000+> 
	--<TTS!*!TMW><Begin><SQLVersion=7>
        'Reimb' = (Select Sum(IsNull(pyd_amount,0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_pretax = 'N' and pyd_minus = 1),
        --<TTS!*!TMW><End><SQLVersion=7>       
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--'Reimb' = IsNull((Select Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_pretax = 'N' and pyd_minus = 1),0.00),
	--<TTS!*!TMW><End><SQLVersion=2000+>        
	--<TTS!*!TMW><Begin><SQLVersion=7>
	'Deduct' = (Select Sum(IsNull(pyd_amount,0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_pretax = 'Y' and pyd_minus = -1),
	--<TTS!*!TMW><End><SQLVersion=7> 
        
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--'Deduct' = IsNull((Select Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number and pyd_minus = -1),0.00),
        --<TTS!*!TMW><End><SQLVersion=2000+>
		
	--<TTS!*!TMW><Begin><SQLVersion=7>
	'NetTotal' = (Select Sum(IsNull(pyd_amount,0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number),
        --<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--'NetTotal' = IsNull((Select Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)) from paydetail (NOLOCK) Where payheader.pyh_pyhnumber = paydetail.pyh_number),0.00),  
	--<TTS!*!TMW><End><SQLVersion=2000+>        
	payheader.pyh_paystatus as PayStatus, 
        payheader.asgn_type as IDType,
	--<TTS!*!TMW><Begin><FeaturePack=Other>
        ' ' as 'Branch'
        --<TTS!*!TMW><End><FeaturePack=Other>
        --<TTS!*!TMW><Begin><FeaturePack=Euro>
        --CASE asgn_type
      	 	--WHEN 'DRV'  THEN (Select mpp_branch from manpowerprofile (NOLOCK) where asgn_id = manpowerprofile.mpp_id) 
      	 	--WHEN 'TRC'  THEN (Select trc_branch from tractorprofile (NOLOCK) where asgn_id = tractorprofile.trc_number) 
      	 	--WHEN 'TRL'  THEN (Select trl_branch from trailerprofile (NOLOCK) where asgn_id = trailerprofile.trl_id) 
      	 	--WHEN 'CAR'  THEN (Select car_branch from carrier (NOLOCK) where asgn_id = carrier.car_id) 
       --End as Branch	
       --<TTS!*!TMW><End><FeaturePack=Euro> 
	
--<TTS!*!TMW><Begin><FeaturePack=Other>

--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--into #TempPayHeader
--<TTS!*!TMW><End><FeaturePack=Euro>
FROM    payheader
WHERE  
       (pyh_payperiod between @frmdt and @tdt )
       And
       (@asgntype = ',,' OR CHARINDEX(',' + RTrim(payheader.asgn_type) + ',', @asgntype) > 0) 
       And
       (@paystatus = ',,' OR CHARINDEX(',' + payheader.pyh_paystatus + ',', @paystatus) > 0) 
--<TTS!*!TMW><Begin><FeaturePack=Other>
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Select * from #TempPayHeader
--Where
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + Branch + ',', @onlyBranches) > 0) 
       --)	
--<TTS!*!TMW><End><FeaturePack=Euro>
       





GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWResourcePayReportFromPayDetails] TO [public]
GO
