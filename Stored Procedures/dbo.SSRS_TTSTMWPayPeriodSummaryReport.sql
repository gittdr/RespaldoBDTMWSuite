SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[SSRS_TTSTMWPayPeriodSummaryReport]
		( @sortoption varchar (200),
		  @begindate datetime,
		  @enddate   datetime,
		  @driverorcarrier varchar (255),
		  @tractor   varchar(255),
		  @payto varchar (255),
	          @asgntype varchar (255),
		  @revtype1 varchar (255),
		  @revtype2 varchar (255),
		  @revtype3 varchar (255),
		  @revtype4 varchar (255),
		  @drvtype1 varchar (255),
		  @drvtype2 varchar (255),
		  @drvtype3 varchar (255),
		  @drvtype4 varchar (255),
		  @trctype1 varchar (255),
		  @trctype2 varchar (255),
		  @trctype3 varchar (255),
		  @trctype4 varchar (255),
		  @datetype varchar(255)='PayPeriod Date'
		 )
	       
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON


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
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 
SELECT @payto = ',' + LTRIM(RTRIM(ISNULL(@payto, ''))) + ',' 
SELECT @asgntype = ',' + LTRIM(RTRIM(ISNULL(@asgntype, ''))) + ',' 
SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 
SELECT @trctype1 = ',' + LTRIM(RTRIM(ISNULL(@trctype1, ''))) + ','
SELECT @trctype2 = ',' + LTRIM(RTRIM(ISNULL(@trctype2, ''))) + ','
SELECT @trctype3 = ',' + LTRIM(RTRIM(ISNULL(@trctype3, ''))) + ',' 
SELECT @trctype4 = ',' + LTRIM(RTRIM(ISNULL(@trctype4, ''))) + ',' 
SELECT @tractor = ',' + LTRIM(RTRIM(ISNULL(@tractor, ''))) + ',' 
SELECT @driverorcarrier = ',' + LTRIM(RTRIM(ISNULL(@driverorcarrier, ''))) + ',' 
select lgh_tractor,
       lgh_driver1,
       TotLHChargeForMove = ISNULL((SELECT
					   sum(ISNULL(ivd_charge,0))			    
					FROM 
					  Invoiceheader 
					  join invoicedetail  on Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
					  join chargetype on invoicedetail.cht_itemcode=chargetype.cht_itemcode
				    WHERE 
					  Invoiceheader.mov_number = L.mov_number
					  and
					  invoiceheader.ivh_invoicestatus <> 'CAN' 
					  AND 
					  (chargetype.cht_basis='shp' OR chargetype.cht_itemcode='min'))
				,0),     	 
       AccChargeMove =  
		          ISNULL((SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
					  sum(ISNULL( ivd_charge,0))
					  --<TTS!*!TMW><End><SQLVersion=7> 
					 
				          --<TTS!*!TMW><Begin><SQLVersion=2000+>
					  --sum(ISNULL( dbo.TMWSSRS_fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default), 0 ) )
					  --<TTS!*!TMW><End><SQLVersion=2000+>				    
				    FROM 
					  Invoiceheader 
					  join invoicedetail  on Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
					  join chargetype on invoicedetail.cht_itemcode=chargetype.cht_itemcode
				    WHERE 
					  Invoiceheader.mov_number = L.mov_number
					  and
					  invoiceheader.ivh_invoicestatus <> 'CAN' 
				          AND
					    (
					  (chargetype.cht_basis='acc' and chargetype.cht_itemcode<>'min')
					  OR   
					  invoicedetail.cht_itemcode='UNK'
					  )
					  and ivd_charge is Not Null
					  )
					,0),   
	LoadedMlsMove=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 
			 WHERE L.mov_number = s1.mov_number
			 AND s1.stp_loadstatus <> 'MT' 
			 AND s1.stp_loadstatus <> 'BT'),0),
	
	MTMlsMove=ISNULL(
			(SELECT sum( ISNULL( stp_lgh_mileage, 0 ) )
			 FROM stops s1 
			 WHERE L.mov_number = s1.mov_number
			 --AND (s1.stp_loadstatus = 'MT' OR s1.stp_loadstatus = 'BT')
			and s1.STP_LOADstatus in ('MT','BT')
			)
		,0),
	TotMlsMove=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 
			 WHERE L.mov_number = s1.mov_number
			 ),0),
	LoadedMlsLegHeader=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 
			 WHERE L.lgh_number = s1.lgh_number
			 AND s1.stp_loadstatus <> 'MT' 
			 AND s1.stp_loadstatus <> 'BT'),0),
	MTMlsLegHeader=ISNULL(
			(SELECT sum( ISNULL( stp_lgh_mileage, 0 ) )
			 FROM stops s1 
			 WHERE L.lgh_number = s1.lgh_number
			-- AND (s1.stp_loadstatus = 'MT' OR s1.stp_loadstatus = 'BT')
			AND s1.stp_loadstatus in ('MT','BT')
			)
		,0),
	TotMlsLegHeader=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 
			 WHERE L.lgh_number= s1.lgh_number
			 ),0),
	L.lgh_number,
	L.mov_number,
	L.lgh_carrier
	
	
	
into   #TempPayPeriod
from   paydetail 
	join legheader L on       paydetail.lgh_number=L.lgh_number
where  pyd_pretax = 'Y'
       And
       L.lgh_outstatus='CMP'
       And
       (
	(@datetype = 'PayPeriod Date' And pyh_payperiod Between @begindate and @enddate)
	OR
	(@datetype = 'End Date' And lgh_enddate Between @begindate and @enddate)
       )
       And
       (@tractor = ',,' OR CHARINDEX(',' + L.lgh_tractor + ',', @tractor) > 0)
       And
       (@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
	And
       ((@driverorcarrier = ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driverorcarrier) > 0)
       Or
       (@driverorcarrier = ',,' OR CHARINDEX(',' + lgh_carrier + ',', @driverorcarrier) > 0))
       --<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + lgh_booked_revtype1 + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
Group By lgh_tractor,lgh_driver1,L.lgh_number,L.mov_number,lgh_carrier
           		
select  #TempPayPeriod.*,
	'DriverType1' = (select mpp_type1 from manpowerprofile  where lgh_driver1 = mpp_id),
	'DriverType2'=(select mpp_type2 from manpowerprofile  where lgh_driver1 = mpp_id),
	'DriverType3'=(select mpp_type3 from manpowerprofile  where lgh_driver1 = mpp_id),
	'DriverType4'=(select mpp_type4 from manpowerprofile  where lgh_driver1 = mpp_id),
	'TractorType1'=(select trc_type1 from tractorprofile  where lgh_tractor = trc_number),
	'TractorType2'=(select trc_type2 from tractorprofile  where lgh_tractor = trc_number),
	'TractorType3'=(select trc_type3 from tractorprofile  where lgh_tractor = trc_number),
	'TractorType4'=(select trc_type4 from tractorprofile  where lgh_tractor = trc_number),
	'ord_hdrnumber' = (select ord_hdrnumber from legheader  where legheader.lgh_number = #TempPayPeriod.lgh_number), 
	'payperiod' = (select max(pyh_payperiod) from paydetail  where #TempPayPeriod.lgh_number = paydetail.lgh_number), 
	'countofpayperiodsforlegheader' = IsNull((select count(distinct(pyh_payperiod)) from paydetail  where #TempPayPeriod.lgh_number = paydetail.lgh_number),1),
         convert(varchar(255),'') RevType1,
	 convert(varchar(255),'') RevType2,
	 convert(varchar(255),'') RevType3,
	 convert(varchar(255),'') RevType4,
	 convert(money,0.00) PercentLghMlsOfMoveMls,
	 convert(money,0.00) AllChargesMove,
	 convert(money,0.00) AllocatedLHChargeForLgh,
         convert(money,0.00) AllocatedAcclChargeForLgh,
         convert(money,0.00) AllocatedTotlChargesForLgh,
	Case when lgh_carrier='UNK' Or lgh_carrier='UNKNOWN' or lgh_carrier Is Null Then
	IsNull((Select mpp_lastfirst from manpowerprofile  where lgh_driver1 = manpowerprofile.mpp_id),lgh_driver1) 
	Else	
	
	IsNull((Select car_name from carrier  where lgh_carrier = carrier.car_id),lgh_carrier)
	End as DrvOrCarrier,
	Convert(Money,0.00) FirstPayToCompensation,
	Convert(varchar(8),'') LastPayTo,
	Convert(Money,0.00) LastPayToCompensation,
        convert(int,0) MinOrderHdrnumber
into    #TempFinalPayPeriod
from	#TempPayPeriod
--update linehaul charges for Non-Invoiced Loads
Update  #TempFinalPayPeriod
	Set TotLHChargeForMove = TotLHChargeForMove +
		
	
		(	SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
				IsNull(sum(ord_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7>  				
				
	                        --<TTS!*!TMW><Begin><SQLVersion=2000+>
				--IsNull(sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00)),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+> 				
			FROM 	orderheader 
			WHERE 
				orderheader.mov_number = #TempFinalPayPeriod.mov_number
				And
				not exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				And 
                                (ord_status = 'CMP' or ord_status = 'STD' or ord_status = 'PKD')
		)
				
--update accessorial charges for Non-Invoiced Loads
Update  #TempFinalPayPeriod
	Set AccChargeMove = AccChargeMove +
		
	
		(	SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7>
				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				--IsNull(sum(IsNull(dbo.TMWSSRS_fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00)),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+>				
			FROM 	
				orderheader 
				join invoicedetail on orderheader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				join chargetype on invoicedetail.cht_itemcode=chargetype.cht_itemcode
			WHERE 
				orderheader.mov_number =#TempFinalPayPeriod.mov_number
				And
                                (ord_status = 'CMP' or ord_status = 'STD' or ord_status = 'PKD')
                                And
                                not exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				And
				(
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				
				Or
				(
					(chargetype.cht_basis='acc' 
					and 
					chargetype.cht_itemcode<>'min')
						OR   
					invoicedetail.cht_itemcode='UNK'
				)
				)
				And ivd_charge is Not Null
				)
select #TempFinalPayPeriod.*,
       CompensationForLegHeaderPayPeriod = 
		IsNull(
			(
				Select --<TTS!*!TMW><Begin><SQLVersion=7>
					Sum(ISNULL(pyd_amount,0))
					--<TTS!*!TMW><End><SQLVersion=7> 
					
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					--Sum(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+>  
				from
					paydetail 
				where
					paydetail.lgh_number=#TempFinalPayPeriod.lgh_number
					AND
					pyd_pretax ='Y'
					And
					pyh_payperiod Between @begindate and @enddate
				        And
       					(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
		      )	
		,0),		
     CompensationForLegHeader = 
		IsNull(
			(
				Select  --<TTS!*!TMW><Begin><SQLVersion=7>
					Sum(ISNULL(pyd_amount,0))
					--<TTS!*!TMW><End><SQLVersion=7> 
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					--Sum(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+>
				from
					paydetail 
				where
					paydetail.lgh_number=#TempFinalPayPeriod.lgh_number
					AND
					pyd_pretax ='Y'
					And
       					(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
		      )	
		,0),	
NumberOfPaytos = 
	(
	select 
		count( Distinct 
				(CASE 	WHEN  pyd_payto='UNKNOWN' THEN asgn_id
					WHEN pyd_payto is NULL THEN asgn_id
					WHEN pyd_payto=''THEN asgn_id
					ELSE pyd_payto
					END
				)
			)
	from paydetail  
	WHERE 	
		paydetail.lgh_number=#TempFinalPayPeriod.lgh_number
		AND
		pyd_pretax ='Y'
		And
		pyh_payperiod Between @begindate and @enddate
		And
       		(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
	),
FirstPayTo=
		ISNull( 
			(
			Select min	(
						(CASE 	WHEN  pyd_payto='UNKNOWN' THEN asgn_id
						WHEN pyd_payto is NULL THEN asgn_id
						WHEN pyd_payto=''THEN asgn_id
						ELSE pyd_payto
						END
						) 
					) PayToID
			from
				paydetail 
			where
				paydetail.lgh_number=#TempFinalPayPeriod.lgh_number
				and
				pyd_pretax ='Y'
				And
				pyh_payperiod Between @begindate and @enddate
				And
       				(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
			)
		,0)
into #TempFinalPayPeriod2
from #TempFinalPayPeriod
where
	      (@drvtype1 = ',,' OR CHARINDEX(',' + DriverType1 + ',', @drvtype1) > 0) 
  	      And
              (@drvtype2 = ',,' OR CHARINDEX(',' + DriverType2  + ',', @drvtype2) > 0) 
              And
              (@drvtype3 = ',,' OR CHARINDEX(',' + DriverType3  + ',', @drvtype3) > 0) 
              And
              (@drvtype4 = ',,' OR CHARINDEX(',' + DriverType4  + ',', @drvtype4) > 0)
              And
              (@trctype1 = ',,' OR CHARINDEX(',' + TractorType1 + ',', @trctype1) > 0) 
              And
              (@trctype2 = ',,' OR CHARINDEX(',' + TractorType2 + ',', @trctype2) > 0) 
              And
              (@trctype3 = ',,' OR CHARINDEX(',' + TractorType3  + ',', @trctype3) > 0) 
              And
              (@trctype4 = ',,' OR CHARINDEX(',' + TractorType4  + ',', @trctype4) > 0)		
Update #TempFinalPayPeriod2
	Set LastPayTo=
		ISNull( 
			(
			Select Max	(
						(CASE 	WHEN  pyd_payto='UNKNOWN' THEN asgn_id
						WHEN pyd_payto is NULL THEN asgn_id
						WHEN pyd_payto=''THEN asgn_id
						ELSE pyd_payto
						END
						) 
					) 
			from
				paydetail 
			where
				paydetail.lgh_number=#TempFinalPayPeriod2.lgh_number
				and
				pyd_pretax ='Y'
				And
				pyh_payperiod Between @begindate and @enddate
				And
       				(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
			)
		,0)
	where NumberOfPaytos>1
Update #TempFinalPayPeriod2
	Set LastPayTo=''
	where LastPayTo=FirstPayto
Update #TempFinalPayPeriod2 
	Set FirstPayToCompensation=
		(
			Select 		--<TTS!*!TMW><Begin><SQLVersion=7> 
					Sum(ISNULL(pyd_amount,0))
					--<TTS!*!TMW><End><SQLVersion=7> 
					
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					--Sum(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+> 
				from
					paydetail 
				where
					paydetail.lgh_number=#TempFinalPayPeriod2.lgh_number
					and
					pyd_pretax ='Y'
					AND
					(
					pyd_payto=FirstPayto
					or
					Asgn_id=FirstPayto
					)
					And
					pyh_payperiod Between @begindate and @enddate
					And
       					(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
		)
	where 
		FirstPayto>''
		AND
		NumberOfPaytos>0	
	
Update #TempFinalPayPeriod2 
	Set LastPayToCompensation=
		(
			Select 		--<TTS!*!TMW><Begin><SQLVersion=7>
					Sum(ISNULL(pyd_amount,0))
					--<TTS!*!TMW><End><SQLVersion=7> 
					
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					--Sum(ISNULL(dbo.TMWSSRS_fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+> 
				from
					paydetail 
				where
					paydetail.lgh_number=#TempFinalPayPeriod2.lgh_number
					and
					pyd_pretax ='Y'
					AND
					(
					pyd_payto=LastPayTo
					or
					Asgn_id=LastPayTo
					)
					And
					pyh_payperiod Between @begindate and @enddate
					And
       					(@asgntype = ',,' OR CHARINDEX(',' + asgn_type + ',', @asgntype) > 0)
			)
	where NumberOfPaytos>1
Update  #TempFinalPayPeriod2
	Set PercentLghMlsOfMoveMls =  convert(float,TotMlsLegHeader) / convert(float,TotMlsMove)
	where TotMlsMove>0 and PercentLghMlsOfMoveMls=0
Update #TempFinalPayPeriod2
	Set PercentLghMlsOfMoveMls =  
	1 / 	(Select 
			count(l2.lgh_number) 
		From 
			#TempFinalPayPeriod2 l2
		where
			l2.lgh_number=#TempFinalPayPeriod2.lgh_number
		)
	where TotMlsMove=0 and PercentLghMlsOfMoveMls=0
Update  #TempFinalPayPeriod2
	Set AllChargesMove =    TotLHChargeForMove
				+
				AccChargeMove
				
Update  #TempFinalPayPeriod2
	Set AllocatedLHChargeForLgh =
		PercentLghMlsOfMoveMls * TotLHChargeForMove,
	
		AllocatedAcclChargeForLgh =
		PercentLghMlsOfMoveMls * AccChargeMove,
		
		AllocatedTotlChargesForLgh =
		PercentLghMlsOfMoveMls * AllChargesMove
	Update  #TempFinalPayPeriod2
	        Set RevType1 = orderheader.ord_revtype1
	From    orderheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = orderheader.ord_hdrnumber
	Where   Not Exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		And
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	     	
	
	Update  #TempFinalPayPeriod2
	        Set RevType1 = invoiceheader.ivh_revtype1
	From    invoiceheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = invoiceheader.ord_hdrnumber
	Where 
				(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	
	
	Update  #TempFinalPayPeriod2
	        Set RevType2 = orderheader.ord_revtype2
	From     orderheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = orderheader.ord_hdrnumber
	Where   Not Exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)

		And
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	     	
	
	Update  #TempFinalPayPeriod2
	        Set RevType2 = invoiceheader.ivh_revtype2
	From    invoiceheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = invoiceheader.ord_hdrnumber
	Where   
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	
	Update  #TempFinalPayPeriod2
	        Set RevType3 = orderheader.ord_revtype3
	From     orderheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = orderheader.ord_hdrnumber
	Where   Not Exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
		And
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	     	
	Update  #TempFinalPayPeriod2
	        Set RevType3 = invoiceheader.ivh_revtype3
	From     invoiceheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = invoiceheader.ord_hdrnumber
	Where   
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	
	Update  #TempFinalPayPeriod2
	        Set RevType4 = orderheader.ord_revtype4
	From    orderheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = orderheader.ord_hdrnumber
	Where   Not Exists (select * from invoiceheader  where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
			And
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	     	
	Update  #TempFinalPayPeriod2
	        Set RevType4 = invoiceheader.ivh_revtype4
	From    invoiceheader 
	join #TempFinalPayPeriod2 on #TempFinalPayPeriod2.ord_hdrnumber = invoiceheader.ord_hdrnumber
	Where  
		(#TempFinalPayPeriod2.ord_hdrnumber <> 0)	
select #TempFinalPayPeriod2.*,
       'PayToName' = IsNull((select pto_lastfirst from payto   where pto_id = FirstPayTo),FirstPayTo),       
       Case When CompensationforLegheader <> 0 Then
            AllocatedLHChargeForLgh * (CompensationforLegheaderPayPeriod/Case When CompensationForLegHeader = 0 Then CompensationforLegheaderPayPeriod Else CompensationForLegHeader End  )
       Else
	    AllocatedLHChargeForLgh/countofpayperiodsforlegheader 
       End As 'AllocLineHaulRevenuePayPeriod',
       Case When CompensationforLegheader <> 0 Then
            AllocatedTotlChargesForLgh * (CompensationforLegheaderPayPeriod/Case When CompensationForLegHeader = 0 Then CompensationforLegheaderPayPeriod Else CompensationForLegHeader End)
       Else
	    AllocatedTotlChargesForLgh/countofpayperiodsforlegheader
       End As 'AllocTotalRevenuePayPeriod',
       Case When CompensationforLegheader <> 0 Then
	    AllocatedAcclChargeForLgh * (CompensationforLegheaderPayPeriod/Case When CompensationForLegHeader = 0 Then CompensationforLegheaderPayPeriod Else CompensationForLegHeader End)
       Else
            AllocatedAcclChargeForLgh/countofpayperiodsforlegheader	  
       End As 'AllocAccessorialRevenuePayPeriod'
from #TempFinalPayPeriod2
where
	     (@revtype1 = ',,' OR CHARINDEX(',' + RevType1 + ',', @revtype1) > 0) 
              And
             (@revtype2 = ',,' OR CHARINDEX(',' + RevType2 + ',', @revtype2) > 0) 
              And
             (@revtype3 = ',,' OR CHARINDEX(',' + RevType3 + ',', @revtype3) > 0) 
              And
             (@revtype4 = ',,' OR CHARINDEX(',' + RevType4 + ',', @revtype4) > 0)
	     And
       	     (
	      (@payto = ',,' OR CHARINDEX(',' + FirstPayTo + ',', @payto) > 0) 
       	      Or
       	      (@payto = ',,' OR CHARINDEX(',' + LastPayTo + ',', @payto) > 0)
	     )



GO
