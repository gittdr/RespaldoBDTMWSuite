SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[sp_TTSTMWAllocateRevVsPay_SSRS1_DED_Optimizado]
	(
		@DateType char(1),		-- B=Bill, 
						--D=Delivery (or C=Complete), 
						-- S= Ship or start
						-- X - Transfered
		@EarlyDate dateTime,
		@LateDate Datetime,
		@OnlyBillToID 		varchar(8),
		@OnlyShipperID 		varchar(8),
		@OnlyConsigneeID 	varchar(8),
		@InvoiceStatusList	varchar(128),
		
		@IncludeDeadHeadTripsYN 	char(1),
		
		@IncludeNonInvoicedLoadsYN 	Char(1),
		@DebugOnYN			Char(1),
		@ordstatuslist 			varchar (128),
		@revtype1 			varchar (120),
		@revtype2 			varchar (120),
		@revtype3 			varchar (120),
                @revtype4 			varchar (120),
		@drvtype1 			varchar (120),
		@drvtype2 			varchar (120),
		@drvtype3 			varchar (120),
		@drvtype4 			varchar (120),
		@driverid			varchar (120),
		@tractorid			varchar (120),
		@carrierid			varchar (120),
		@teamleaderid			varchar (120),
		@combinefuelacc	                char (1)='N',
		@justtaxablepay			char (1)='Y',
		@paytypestoinclude		varchar (255),
		@primarytrailerid		varchar(255)
	)
AS

SELECT @ordstatuslist = ',' + LTRIM(RTRIM(ISNULL(@ordstatuslist, ''))) + ','
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 
SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 
SELECT @driverid = ',' + LTRIM(RTRIM(ISNULL(@driverid, ''))) + ',' 
SELECT @carrierid = ',' + LTRIM(RTRIM(ISNULL(@carrierid, ''))) + ',' 
SELECT @tractorid = ',' + LTRIM(RTRIM(ISNULL(@tractorid, ''))) + ',' 
SELECT @teamleaderid = ',' + LTRIM(RTRIM(ISNULL(@teamleaderid, ''))) + ',' 
SELECT @paytypestoinclude = ',' + LTRIM(RTRIM(ISNULL(@paytypestoinclude, ''))) + ','
SELECT @primarytrailerid = ',' + LTRIM(RTRIM(ISNULL(@primarytrailerid , ''))) + ','
Declare @OnlyBranches as varchar(255)
declare @NextMov int
Declare @NextOrdernumber  varchar(10)
Declare @FudgeFactorDays int
Declare @LowDelvDate dateTime
Declare @HighDelvDate dateTime

/*-- tablas temporal para el SSRS
DECLARE @LegHeaderSummary_JR TABLE(
ord_hdrnumber int Null, 
lgh_tractor varchar(10) Null, 
lgh_primary_trailer varchar(10) Null, 
mov_number varchar(10) Null, --'Move#' ,
lgh_number varchar(10) Null, --'Leg#' ,
LoadedMlsMove float Null, --'LD Miles Move' ,
MTMlsMove float Null, --'MT Miles Move'  ,
TotMlsMove float Null, --'Tot Miles Move' ,
LoadedMlsLegHeader float Null, --'LD Miles Leg',
MTMlsLegHeader float Null, --'MT Miles Leg' ,
TotMlsLegHeader float Null, --'Tot Miles Leg',
TotLHChargeForMove float Null,  --'Tot LH Charge Move'  ,
AccChargeMove float Null,                     --'Acc Charge Move'                    ,
AllChargesMove float Null,       --'All Charges Move' ,
PercentLghMlsOfMoveMls float Null, --'% Leg Miles of Move Miles',
AllocatedLHChargeForLgh float Null, --'Allocated LH' ,
AllocatedAcclChargeForLgh float Null, --'Allocated Acc' ,
AllocatedTotlChargesForLgh float Null, --'Allocated Tot Charges',
RevPerMileAllCharges float Null, --'Rev/Mile ALL Charges' ,
RevPerMileLHCharge float Null,
AllocRevMinusPay float Null,     --'Allocated Rev - Pay' ,
AllocRevMinusPayPerTrvlMile float Null, --'Alloc Rev - Pay Per Travel Mile'
mpp_teamleader varchar(5) Null)
*/



/*
 	Create a list of moves that happened during period
 	Only pickup completed legheaders and onlyif the first stops in during the time period
*/
SET NOCOUNT ON
--=========================================================================
-- ISSUE -- DISCREPENCY CAUSED WHEN IVH_DELIVERY<> ORD_COMPLETEION DATE
-- RARE-- But does happen.
-- MAKE REPORT USE IVH_DELIVERYDATE IF PRESENT
-- CREATE HOLDING TABLE TO STORE CORRECTED DATE
-- Search for --DELVFIX - 
Create table #OrdCompDtFix
	(
	ord_hdrnumber int PRIMARY KEY,
	Mov_number int,
	ord_completiondate datetime
	)
Create Table #movlist
	(mov_number int)
Set @DateType =IsNULL(Upper(@DateType),'D')
if @DateType='C'  Set @DateType='D' 
If charindex(@DateType,'BSDX')=0 
BEGIN
	Select 'Invalid DataType'
	GOTO ENDE
END
Set @FudgeFactorDays =0
if @DateType<>'D' SET @FudgeFactorDays = 45 -- assumes it was completed within 45 days of
					   -- of date range	
Set @LowDelvDate = convert(datetime, Convert(float,@EarlyDate) -@FudgeFactorDays )
Set @HighDelvDate= convert(datetime, Convert(float,@LateDate) +@FudgeFactorDays ) 
set  @InvoiceStatusList = ',' + LTRIM(RTRIM(ISNULL(@InvoiceStatusList, ''))) + ',' 
-- 
-- BCY - should there be a status restriction on this first SELECT/INSERT
-- so you don't get CAN's and Masters?
--select @lowdelvdate
--select @highdelvdate
Insert into #OrdCompDtFix
Select 
	ord_hdrnumber, 
	Mov_number,
	ord_completiondate 
From 
	Orderheader (NOLOCK)
where
	ord_completiondate between @LowDelvDate and @HighDelvDate 

Update #OrdCompDtFix
	Set ord_completiondate =ivh_deliverydate
	from
	invoiceheader (NOLOCK)
	where invoiceheader.ord_hdrnumber = #OrdCompDtFix.ord_hdrnumber
--bcy
--select count(*)  as 'count from #ordcompdtfix' from #ordcompdtfix
--=========================================================================
Insert into #MovList
SELECT 
	DISTINCT I.mov_number
from
	Invoiceheader I (NOLOCK)
	
where
	I.ivh_deliveryDate between @LowDelvDate and @HighDelvDate 
	AND
	(
		(
			@DateType='B' 
			AND
			I.ivh_billdate between @Earlydate and @lateDate
		)
		OR
		(
			@DateType='S' 
			AND
			I.ivh_Shipdate between @Earlydate and @lateDate
		)
		OR
		(
			@DateType='X' 
			AND
			I.ivh_xferdate between @Earlydate and @lateDate
		)
		OR
		@DateType='D' 
	)
	AND 
	i.ivh_invoicestatus<>'CAN'
	and

	(@InvoiceStatusList = ',,' OR CHARINDEX(',' + i.ivh_invoicestatus + ',', @InvoiceStatusList) > 0) 
	AND
	(@OnlyBillToID='' or UPPER(i.ivh_billto)=UPPER(@OnlyBillToID) )
	AND
	(@OnlyShipperID='' or UPPER(i.ivh_shipper)=UPPER(@OnlyShipperID) )
	AND
	(@OnlyConsigneeID='' or UPPER(i.ivh_consignee)=UPPER(@OnlyConsigneeID))
	And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @revtype4) > 0)
	
--bcy
--select * from #movlist
IF @DebugOnYN='Y'			SELECT ' =Y SELECT * from #MovList'
IF @DebugOnYN			='Y'  SELECT * from #MovList
IF @IncludeNonInvoicedLoadsYN ='Y'
BEGIN
	Insert into #MovList
	SELECT 
		DISTINCT o.mov_number
	from
		Orderheader o (NOLOCK)
	where
		o.ord_CompletionDate between @LowDelvDate and @HighDelvDate 
		AND
		(
			(
				@DateType='B'  
				AND
				1=0  -- Nothing can be restricted by BillDate if there aint no invoice says Bradley 
			)
			OR
			(
				@DateType='S' 
				AND
				o.ord_Startdate between @Earlydate and @lateDate
			)
			OR
			@DateType='D' 
		)
	--bcy
		AND NOT EXISTS 
			(Select M.mov_number
			        from InvoiceHeader M (NOLOCK)
				where M.mov_number = o.mov_number)
			--select M.mov_number
			--from #MovList M
			--where M.mov_number=o.mov_number
			--)
		And
        	--bk
 		(@ordstatuslist = ',,' OR CHARINDEX(',' + ord_status + ',', @ordstatuslist) > 0) 	
		--bcy
		 --OLD --  o.ord_status='CMP'
		--o.ord_status In ('STD','CMP','PLN','DSP')
-- BCY - why only completed ??
		AND
		(@InvoiceStatusList = ',,') 
		AND
		(@OnlyBillToID='' or UPPER(o.Ord_billto)=UPPER(@OnlyBillToID) )
		AND
		(@OnlyShipperID='' or UPPER(O.Ord_shipper)=UPPER(@OnlyShipperID) )
		AND
		(@OnlyConsigneeID='' or UPPER(o.Ord_consignee)=UPPER(@OnlyConsigneeID))
		And 
		(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
        	And
		(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
		And
		(@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
		And
		(@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0)
END
IF @IncludeDeadHeadTripsYN ='Y'
BEGIN
	Insert into #MovList
	SELECT 
		DISTINCT L.mov_number
	from
		Legheader L (NOLOCK)
	where
		L.ord_hdrnumber=0
		AND
		L.lgh_enddate between @LowDelvDate and @HighDelvDate 
		AND
		
		(
			(
				(
				@DateType='B' 
				OR
				@DateType='D' 
				)
				AND
				L.lgh_enddate between @Earlydate and @lateDate
			)
			OR
			(
				@DateType='S' 
				AND
				L.lgh_startdate between @Earlydate and @lateDate
			)
		)
		and 
		NOT Exists (	Select 
					l2.ord_hdrnumber
				From 
					Legheader l2 (NOLOCK)
				where
					l2.mov_number=l.mov_number
					AND
					l2.ord_hdrnumber<>0
			)
		AND
		L.lgh_outstatus='CMP'
END
--bcy
--select count(*)  as 'count from #movlist ' from #movlist
IF @DebugOnYN='Y' select count(*) CNTMOVES from #movlist
select 
	L.ord_hdrnumber ,
	L.lgh_tractor,
	L.lgh_primary_trailer,
	(
		CASE 
		WHEN L.lgh_carrier<> 'UNKNOWN' and L.lgh_carrier IS NOT NULL 
			THEN L.LGH_CARRIER
			ELSE L.lgh_Driver1
		END
	)	DrvOrCarrier,
	l.lgh_driver1,
	l.mov_number	,
	L.lgh_number	,
	L.lgh_startdate	,
	L.lgh_Enddate	,
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
	from paydetail (NOLOCK) 
	WHERE 	
		paydetail.lgh_number=L.lgh_number
		AND
		pyd_pretax ='Y'
	),
	CompensationForLegHeader = 
		IsNull(
			(
				Select 
					--<TTS!*!TMW><Begin><SQLVersion=7>
--					Sum(ISNULL(pyd_amount,0)) 
					--<TTS!*!TMW><End><SQLVersion=7>
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+>                                 
				from
					paydetail (NOLOCK)
				where
					paydetail.lgh_number=L.lgh_number
					and
					(
					(@justtaxablepay = 'Y' and pyd_pretax ='Y') 
					Or
					(@justtaxablepay = 'N' and pyd_pretax ='N') 
					Or
					(@justtaxablepay = 'B')
					)
					and
					(@paytypestoinclude = ',,' OR CHARINDEX(',' + pyt_itemcode + ',', @paytypestoinclude) > 0) 
		      )	
		,0),	
	
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
				paydetail (NOLOCK)
			where
				paydetail.lgh_number=L.lgh_number
				and
				pyd_pretax ='Y'
			)
		,0),
	Convert(Money,0.00) FirstPayToCompensation,
	Convert(varchar(255),'') LastPayTo,
	Convert(Money,0.00) LastPayToCompensation,
		
	OrderStartDate= 
		ISNULL(
		
			(Select o2.ord_startdate 
			from orderheader o2 (NOLOCK) where L.ord_hdrnumber=o2.ord_hdrnumber)
		,lgh_startdate)	,
	OrderEndDate= 
		ISNULL(
			(Select o2.ord_CompletionDate 
			from orderheader o2 (NOLOCK) where L.ord_hdrnumber=o2.ord_hdrnumber)
		,lgh_Enddate)	,
	trl_type1,
	trl_type2,
	trl_type3,
	trl_type4,
	lgh_carrier,
	cmp_id_start,
	lgh_startcty_nmstct,
	cmp_id_end,      
	lgh_endcty_nmstct,
	mpp_teamleader,
	
	
	LoadedMlsMove=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 (NOLOCK)
			 WHERE #movlist.mov_number = s1.mov_number
			 AND s1.stp_loadstatus <> 'MT' 
			 AND s1.stp_loadstatus <> 'BT'),0),
	
	MTMlsMove=ISNULL(
			(SELECT sum( ISNULL( stp_lgh_mileage, 0 ) )
			 FROM stops s1 (NOLOCK)
			 WHERE #movlist.mov_number = s1.mov_number
			 --AND (s1.stp_loadstatus = 'MT' OR s1.stp_loadstatus = 'BT')
			and s1.STP_LOADstatus in ('MT','BT')
			)
		,0),
	TotMlsMove=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 (NOLOCK)
			 WHERE #movlist.mov_number = s1.mov_number
			 ),0),
	LoadedMlsLegHeader=ISNULL((SELECT sum( isnull( stp_lgh_mileage , 0 ) )
			 FROM stops s1 (NOLOCK)
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
	TotLHChargeForMove =   
			       --<TTS!*!TMW><Begin><SQLVersion=7>
--			       ISNULL((SELECT sum(ISNULL( ivd_charge, 0 ) )
			       --<TTS!*!TMW><End><SQLVersion=7> 
		
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				ISNULL((SELECT convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)))
				--<TTS!*!TMW><End><SQLVersion=2000+>                                
    		        FROM 
				Invoiceheader (NOLOCK INDEX=dk_move) ,
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				Invoiceheader.mov_number = #movlist.mov_number
				
				and
				
				invoiceheader.ivh_invoicestatus <> 'CAN' 
				/*
				AND
				invoiceheader.ivh_billDate between
					@EarliestBillDateToTotalRevenue
					and
					@LatestBillDateToTotalRevenue
				And
				ivh_deliverydate
					between
					@EarliestOrderCompletionDateToTotalRevenue
					and
					@LatestOrderCompletionDateToTotalRevenue
				*/
				and 
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				and
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(chargetype.cht_basis='shp' OR chargetype.cht_itemcode='min'))
		,0),
	
	'CountOfLoads' = (select count(distinct(ord_hdrnumber))
				 from stops (NOLOCK)
				 where 
				 L.lgh_number = stops.lgh_number
					
			  ),
	Convert(float,0.00) AccChargeMove,
	convert(money,0.00) AllChargesMove,
	convert(money,0.00) PercentLghMlsOfMoveMls,
	convert(money,0.00) AllocatedLHChargeForLgh,
	convert(money,0.00) AllocatedAcclChargeForLgh,
	convert(money,0.00) AllocatedTotlChargesForLgh,
	convert(money,0.00) RevPerMileAllCharges,
	convert(money,0.00) RevPerMileLHCharge,
	FirstBillTo=
      	IsNull(
		(
		Select 
			Min(ivh_billto) 
		from 
			InvoiceHeader I (NOLOCK)
		where
			I.ord_hdrnumber= L.ord_hdrnumber
			and
			L.ord_hdrnumber>0
		)
	    ,''),
	ISNULL(lgh_class1,'UNK')lgh_class1,
	ISNULL(lgh_class2,'UNK')lgh_class2,
	ISNULL(lgh_class3,'UNK')lgh_class3,
	ISNULL(lgh_class4,'UNK')lgh_class4,
	ISNULL(trc_type1,'UNK')trc_type1,
	ISNULL(trc_type2,'UNK')trc_type2,
	ISNULL(trc_type3,'UNK')trc_type3,
	ISNULL(trc_type4,'UNK')trc_type4,
	FirstBillDate=
		ISNULL(
			(Select 
				Min(ivh_billdate)
			From 
				invoiceheader (NOLOCK)
			where
				Invoiceheader.mov_number = #movlist.mov_number
				and
				L.mov_number= #movlist.mov_number
			)
		,'1/1/50'),
	LastBillDate=
		ISNULL(
			(Select 
				Max(ivh_billdate)
			From 
				invoiceheader (NOLOCK)
			where
				Invoiceheader.mov_number = #movlist.mov_number
				and
				L.mov_number= #movlist.mov_number
			)
		,'1/1/50'),
	FirstCompletionDate=
		ISNULL(
			(Select 
				Min(ivh_DeliveryDate)
			From 
				invoiceheader (NOLOCK)
			where
				Invoiceheader.mov_number = #movlist.mov_number
				and
				L.mov_number= #movlist.mov_number
			)
		,'1/1/50'),
-- NEW FIELDS
	Convert(money,0.00) TotalFuelSurchargeForMove,
	convert(money,0.00) AllocatedFuelSurchargeChargeForLgh,
	ISNULL(trc_company, 'UNK') 	trc_company,
							--SubByWeek
	ISNULL(trc_division, 'UNK') 	trc_division,	-- Sub2
	ISNULL(trc_fleet,'UNK') 	trc_fleet,		-- Sub3
	
	Convert(Varchar(8),'') 		MinCommodityCode,
	Convert(Varchar(8),'') 		MinCommodityClass,
	convert(int,0) 			MinOrderHdrnumber,	
	DatePart(wk,lgh_enddate) WeekOfTheYear,
	convert(datetime,  floor(convert(float,lgh_enddate)) )
		CompletionDateOnly,
	
	
	
	L.mpp_type1,	
	L.mpp_type2,	
	L.mpp_type3,
	L.mpp_type4,
	NumberOfSplitsOnMove= 
		(Select count(distinct l2.lgh_number) 
		From legheader l2 (NOLOCK) where L2.Mov_number=L.Mov_number
		),
	NumberOfOrdersOnLeg= 
		(Select count(distinct ord_hdrnumber) 
		From Orderheader (NOLOCK) where L.ord_hdrnumber=Orderheader.ord_hdrnumber
		),
	NumberOfInvoicesOnMove=
		(Select count(distinct ivh_invoicenumber)
		From Invoiceheader (NOLOCK) where L.Mov_number= Invoiceheader.mov_number
		),
	
		COnvert(Varchar(10),Lgh_enddate,102)	
	YYYY_MM_DD_LghEndDT,
	
		COnvert(Varchar(8),Lgh_enddate,102) 
		+ 
		Right('0'+ Convert(varChar(2),DatePart(wk,lgh_enddate)),2)
	YYYY_MM_WWLghEndDT,
	Convert(Money,0) AllocRevMinusPay,
	Convert(Money,0) AllocRevMinusPayPerTrvlMile
	--Convert(float,0.00) AccChargesForNonInvoicedLoadsMove
	
	
into #LegHeaderSummary
From
	#movlist,
	legheader L (index=uk_mov) 
where
	#movlist.mov_number=l.mov_number
	--Added Driver,Tractor,Carrier ID 12/11/2002 V 4.6
	--Moved Driver Classes to increase performance 1/08/02 V 4.7
	And
	(@driverid = ',,' OR CHARINDEX(',' + lgh_driver1  + ',', @driverid) > 0)      
     	And 
     	(@tractorid = ',,' OR CHARINDEX(',' + lgh_tractor  + ',', @tractorid) > 0)
     	And 
     	(@carrierid = ',,' OR CHARINDEX(',' + lgh_carrier  + ',', @carrierid) > 0)     
	And 
     	(@teamleaderid = ',,' OR CHARINDEX(',' + mpp_teamleader  + ',', @teamleaderid) > 0)     
	And
	(@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
     	And
     	(@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
     	And
     	(@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
     	And
     	(@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
	AND
	(@primarytrailerid = ',,' OR CHARINDEX(',' + lgh_primary_trailer  + ',', @primarytrailerid) > 0)
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
-- bcy commented out first ordered by clause for speed reasons
-- order by #movlist.mov_number, lgh_startdate
--Update the BillTo For Non Invoiced Loads
Update  #LegHeaderSummary
	Set FirstBillTo=
		IsNull((Select 
			orderheader.ord_billto
		from 
			orderheader (NOLOCK)
		where 
			not exists (select * from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
			and
			orderheader.ord_hdrnumber=#LegHeaderSummary.ord_hdrnumber
			
			
		),FirstBillTo)
--Where FirstBillTo Is Null or LTrim(RTrim(FirstBillTo)) = ''
IF @DebugOnYN='Y' select count(*) CNTLegHeaderSummary from #LegHeaderSummary
IF @DebugOnYN='Y' select mov_number, TotLHChargeForMove from #LegHeaderSummary
--====================================================================================
--7/31/01 - Part II -- Use Order revenue if not invoiced yet
--====================================================================================
-- MinOrderHdrnumber
Update  #LegHeaderSummary
	Set MinOrderHdrnumber=
		(Select 
			Min(orderheader.ord_hdrnumber) 
		from 
			orderheader (NOLOCK),
			legheader (NOLOCK)
		where 
			legheader.lgh_number=#LegHeaderSummary.lgh_number
			and
			legheader.mov_number=orderheader.mov_number
		)
-- END MinOrderHdrnumber
--Update the LHChargeOrderAmountIf Invoiceamt is 0
--Eliminated the join by the minimum order number (which was really
--getting us the the linehaul rev for the lowest order on a move
--not all revenue for the move LBK
--Now all orders on movement revenue are picked up by the report
--LBK Ver 5.4
Update #LegHeaderSummary
	Set TotLHChargeForMove =TotLHChargeForMove +
		(Select 
			--<TTS!*!TMW><Begin><SQLVersion=7>
--			IsNull(sum(ord_charge),0.00)
			--<TTS!*!TMW><End><SQLVersion=7>  
                        
			--<TTS!*!TMW><Begin><SQLVersion=2000+>
			IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
			--<TTS!*!TMW><End><SQLVersion=2000+> 		
		From orderheader (NOLOCK)
		where
			--orderheader.ord_hdrnumber=MinOrderHdrnumber
                        orderheader.mov_number=#LegHeaderSummary.mov_number
			and
			not exists (select I.ord_hdrnumber from invoiceheader I (NOLOCK) where I.ord_hdrnumber = orderheader.ord_hdrnumber) 
		)
	--From 
		--orderheader
	where 
		--orderheader.ord_hdrnumber=#LegHeaderSummary.MinOrderHdrnumber
		
		--TotLHChargeForMove=0
		--and
		MinOrderHdrnumber<>0
		
		
	--Convert(money,0.00) TotalFuelSurchargeForMove,
---Combing fuel and accessorials into 1 column
If @combinefuelacc = 'Y'
Begin
--update accessorial charges for Invoiced Loads
Update #LegHeaderSummary
	Set AccChargeMove =
		
		(
			SELECT 
				--<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7>				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+>  			
			FROM 
				Invoiceheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				Invoiceheader.mov_number =#LegHeaderSummary.mov_number
				And
				invoiceheader.ivh_invoicestatus <> 'CAN' 
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				And
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				
			
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
				and ivd_charge is Not Null
			)
--update accessorial charges for Non-Invoiced Loads
Update #LegHeaderSummary
	Set AccChargeMove = AccChargeMove +
		
	
		(	SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7> 
				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+> 
			
			FROM 	orderheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				orderheader.mov_number =#LegHeaderSummary.mov_number
				And
				not exists (select * from invoiceheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				AND
				orderheader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				And
				
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				
			
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
End
Else ---Separate fuel and accessorials into separate columns
Begin
--Update Fuel Surcharges For Invoiced Loads
/*Bkeeton 11/26/02 put IsNull on outside of sum so result is Not Null*/
Update #LegHeaderSummary
	Set TotalFuelSurchargeForMove =
		
		(
			SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7>  
				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+> 
			FROM 
				Invoiceheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				Invoiceheader.mov_number =#LegHeaderSummary.mov_number
				And
				(invoiceheader.ivh_invoicestatus <> 'CAN' or invoiceheader.ivh_invoicestatus Is Null)
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				AND 
				/*
				invoiceheader.ivh_billDate between
					@EarliestBillDateToTotalRevenue
					and
					@LatestBillDateToTotalRevenue
				and	
				ivh_deliverydate
					between
					@EarliestOrderCompletionDateToTotalRevenue
					and
					@LatestOrderCompletionDateToTotalRevenue
				and 
				*/
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
			)
--Update Fuel Surcharges for Non-Invoiced Loads
Update #LegHeaderSummary
	Set TotalFuelSurchargeForMove = TotalFuelSurchargeForMove +
			
										--@currencydate datetime='',@shipdate datetime='',@deliverydate datetime='',@billdate datetime='',@revenuedate datetime='',@transferdate datetime='',@bookdate datetime='',@printdate datetime='',@transactiondate datetime='',@workperioddate datetime='',@payperioddate datetime='')	
		(	SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7> 				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>				
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+>
			FROM 	orderheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				orderheader.mov_number =#LegHeaderSummary.mov_number
				And
				not exists (select * from invoiceheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				AND
				orderheader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				And
				/*Bkeeton 10/29/2002 Changed And To Or  */
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					Upper(chargetype.cht_itemcode) like 'FUEL%'
					OR
					CharIndex('FUEL', cht_description)>0
				)
				and ivd_charge is Not Null
		)
				
--update accessorial charges for Invoiced Loads
Update #LegHeaderSummary
	Set AccChargeMove =
		
		(
			SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7> 				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',ivd_number,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+>			
			FROM 
				Invoiceheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				Invoiceheader.mov_number =#LegHeaderSummary.mov_number
				And
				invoiceheader.ivh_invoicestatus <> 'CAN' 
				AND
				Invoiceheader.ivh_hdrnumber= invoicedetail.ivh_hdrnumber
				AND 
				/*				
				invoiceheader.ivh_billDate between
					@EarliestBillDateToTotalRevenue
					and
					@LatestBillDateToTotalRevenue
				and	
				ivh_deliverydate
					between
					@EarliestOrderCompletionDateToTotalRevenue
					and
					@LatestOrderCompletionDateToTotalRevenue
				and 
				*/
				/*Bkeeton 10/29/2002 Changed And To Or  */
				(
					Upper(invoicedetail.cht_itemcode) not like 'FUEL%'
					And
					CharIndex('FUEL', cht_description)=0
				)
				and
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					(chargetype.cht_basis='acc' 
					and 
					chargetype.cht_itemcode<>'min')
						OR   
					invoicedetail.cht_itemcode='UNK'
				)
				and ivd_charge is Not Null
			)
--update accessorial charges for Non-Invoiced Loads
Update #LegHeaderSummary
	Set AccChargeMove = AccChargeMove +
		
	
		(	SELECT  --<TTS!*!TMW><Begin><SQLVersion=7>
--				IsNull(sum(ivd_charge),0.00)
				--<TTS!*!TMW><End><SQLVersion=7>
				
				--<TTS!*!TMW><Begin><SQLVersion=2000+>
				IsNull(convert(money,sum(IsNull(dbo.fnc_convertcharge(ivd_charge,ord_currency,'Revenue',ivd_number,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00))),0.00)
				--<TTS!*!TMW><End><SQLVersion=2000+> 				
			FROM 	orderheader (NOLOCK),
				invoicedetail (NOLOCK), 
				chargetype (NOLOCK)
			WHERE 
				orderheader.mov_number =#LegHeaderSummary.mov_number
				And
				not exists (select * from invoiceheader (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
				AND
				orderheader.ord_hdrnumber= invoicedetail.ord_hdrnumber
				And
				
			
				/*Bkeeton 10/29/2002 Changed And To Or  */
				(
					Upper(invoicedetail.cht_itemcode) not like 'FUEL%'
					And
					CharIndex('FUEL', cht_description)=0
				)
				and
				invoicedetail.cht_itemcode=chargetype.cht_itemcode
				AND 
				(
					(chargetype.cht_basis='acc' 
					and 
					chargetype.cht_itemcode<>'min')
						OR   
					invoicedetail.cht_itemcode='UNK'
				)
				and ivd_charge is Not Null
		)
End
Update #LegHeaderSummary
	Set TotalFuelSurchargeForMove =0

	where TotalFuelSurchargeForMove is NULL
				
		
Update #LegHeaderSummary
	Set AccChargeMove = 0
	where 	AccChargeMove is NULL
Update #LegHeaderSummary
	Set PercentLghMlsOfMoveMls =  convert(float,TotMlsLegHeader) / convert(float,TotMlsMove)
	where TotMlsMove>0 and PercentLghMlsOfMoveMls=0
--======================
-- IF NO MILEAGE, ALLOCATE ON COUNT of LGH_number
Update #LegHeaderSummary
	Set PercentLghMlsOfMoveMls =  
	1 / 	(Select 
			count(l2.lgh_number) 
		From 
			#LegHeaderSummary l2
		where
			l2.lgh_number=#LegHeaderSummary.lgh_number
		)
	where TotMlsMove=0 and PercentLghMlsOfMoveMls=0
--====			
Update  #LegHeaderSummary
	Set AllChargesMove =
				TotLHChargeForMove
				+
				AccChargeMove
				+
				TotalFuelSurchargeForMove -- 7/31/01 add in separately
Update  #LegHeaderSummary
	Set AllocatedLHChargeForLgh =
		PercentLghMlsOfMoveMls * TotLHChargeForMove,
	
		AllocatedAcclChargeForLgh =
		PercentLghMlsOfMoveMls *AccChargeMove,
		AllocatedTotlChargesForLgh =
		PercentLghMlsOfMoveMls *AllChargesMove
Update  #LegHeaderSummary
	set RevPerMileLHCharge= 
		AllocatedLHChargeForLgh /
		TotMlsLegHeader
	where 
		TotMlsLegHeader>0
Update  #LegHeaderSummary
	set RevPerMileAllCharges= 
		AllocatedTotlChargesForLgh /
		TotMlsLegHeader
	where 
		TotMlsLegHeader>0
-- ===========================================================================================
-- 7/31/01 NEW FIELDS
-- ===========================================================================================
	--Convert(money,0.00) TotalFuelSurchargeForMove,
	-- END TotalFuelSurchargeForMove
	--convert(money,0.00) AllocatedFuelSurchargeChargeForLgh,
Update  #LegHeaderSummary
	Set AllocatedFuelSurchargeChargeForLgh =
		PercentLghMlsOfMoveMls * TotalFuelSurchargeForMove
	-- END AllocatedFuelSurchargeChargeForLgh,
Update  #LegHeaderSummary
	Set MinCommodityCode=
		(Select 
			min(IsNull(cmd_code,'UNK'))
		From
			Stops (NOLOCK)
		where
			stops.lgh_number=#LegHeaderSummary.lgh_number
		)
	where #LegHeaderSummary.lgh_number>0
-- END MinCommodityCode
Update  #LegHeaderSummary
	Set MinCommodityClass=
		(Select 
			IsNull(cmd_class,'UNK')
		From
			Commodity (NOLOCK)
		where
			#LegHeaderSummary.MinCommodityCode=commodity.cmd_code
		)
	where #LegHeaderSummary.lgh_number>0
-- Update WeekOfYear if there is an order-- if no order, then it continues to use
-- lgh_enddate
Update #LegHeaderSummary
	Set CompletionDateOnly =
		(Select 
		    Min(
			convert
				(
					DATETIME,
					FLOOR(	convert(float,ord_completiondate)  )
				)
			)
		from
			--Orderheader --DELVFIX
			#OrdCompDtFix ----DELVFIX
			
		where
			#LegHeaderSummary.MinOrderHdrnumber =
			--Orderheader.ord_hdrnumber ----DELVFIX
			#OrdCompDtFix.ord_hdrnumber ----DELVFIX
		)
	where
		MinOrderHdrnumber>0
			
Update #LegHeaderSummary
	Set WeekOfTheYear =Datepart(wk,CompletionDateOnly )
Update #LegHeaderSummary
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
				paydetail (NOLOCK)
			where
				paydetail.lgh_number=#LegHeaderSummary.lgh_number
				and
				pyd_pretax ='Y'
			)
		,0)
	where NumberOfPaytos>1
Update #LegHeaderSummary
	Set LastPayTo=''
	where LastPayTo=FirstPayto
Update #LegHeaderSummary 
	Set FirstPayToCompensation=
		(
			Select 
					--<TTS!*!TMW><Begin><SQLVersion=7>
--					Sum(ISNULL(pyd_amount,0))
					--<TTS!*!TMW><End><SQLVersion=7> 
					
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)) 
					--<TTS!*!TMW><End><SQLVersion=2000+>				
				from
					paydetail (NOLOCK)
				where
					paydetail.lgh_number=#LegHeaderSummary.lgh_number
					and
					pyd_pretax ='Y'
					AND
					(
					pyd_payto=FirstPayto
					or
					Asgn_id=FirstPayto
					)
		)
	where 
		FirstPayto>''
		AND
		NumberOfPaytos>0	
	
Update #LegHeaderSummary 
	Set LastPayToCompensation=
		(
			Select 		--<TTS!*!TMW><Begin><SQLVersion=7>	
--					Sum(ISNULL(pyd_amount,0)) 
					--<TTS!*!TMW><End><SQLVersion=7> 					
					
					--<TTS!*!TMW><Begin><SQLVersion=2000+>
					Sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00))
					--<TTS!*!TMW><End><SQLVersion=2000+>  				
				from
					paydetail (NOLOCK)
				where
					paydetail.lgh_number=#LegHeaderSummary.lgh_number
					and
					pyd_pretax ='Y'
					AND
					(
					pyd_payto=LastPayTo
					or
					Asgn_id=LastPayTo
					)
			)
	where NumberOfPaytos>1
Update #LegHeaderSummary 
	Set AllocRevMinusPay= IsnUll(AllocatedTotlChargesForLgh,0) -  IsNull(CompensationForLegHeader,0)
Update #LegHeaderSummary 
	Set AllocRevMinusPayPerTrvlMile= AllocRevMinusPay/ TotMlsLegHeader
	WHERE
		TotMlsLegHeader>0
	
	
-- ===========================================================================================
-- 
-- ===========================================================================================
SET NOCOUNT OFF 
-- FINAL SELECT
IF @DebugOnYN			='Y' select count(distinct(mov_number)) from #LegHeaderSummary 
IF @DebugOnYN			='Y'  select mov_number,ord_hdrnumber, lgh_number  from #LegHeaderSummary  order by mov_number, lgh_number  
/* jr

Select 
ord_hdrnumber, 
lgh_tractor, 
lgh_primary_trailer, 
--Fixed Lookup for Driver Last Name,First Name
--On December 11, 2002
Case when lgh_carrier='UNK' Or lgh_carrier='UNKNOWN' or lgh_carrier Is Null Then
	IsNull((Select mpp_lastfirst from manpowerprofile (NOLOCK) where DrvOrCarrier = manpowerprofile.mpp_id),DrvOrCarrier) 
 Else	
	
	IsNull((Select car_name from carrier (NOLOCK) where DrvOrCarrier = carrier.car_id),DrvOrCarrier)
End as DrvOrCarrier,
lgh_driver1,--'Drv1' ,
mov_number, --'Move#' ,
lgh_number, --'Leg#' ,
lgh_startdate,         --'Leg StartDate'                                 ,
lgh_Enddate,         --'Leg EndDate'                                   ,
NumberOfPaytos, --' # of PayTos',
CompensationForLegHeader, --'Pay For Leg',
FirstPayTo,  --'1st PayTo' ,
FirstPayToCompensation, --'1st Pay Amt' ,
LastPayTo, --'Last PayTo',
LastPayToCompensation, --'Last Pay Amt' ,
OrderStartDate,    --'Ord StartDate'                                     ,
OrderEndDate,            --'Ord EndDate'                               ,
trl_type1, --'TRL Type1',
trl_type2, --'TRL Type2',
trl_type3, --'TRL Type3',
trl_type4, --'TRL Type4',
lgh_carrier, --'Carrier',
'cmp_id_start' = (select Company.cmp_name from Company (NOLOCK) where cmp_id_start = Company.cmp_id), --'Start CMP ID' ,
lgh_startcty_nmstct,    --'Start City'   ,
'cmp_id_end' = (select Company.cmp_name from Company (NOLOCK) where cmp_id_end = Company.cmp_id), --'End CMP ID' ,
lgh_endcty_nmstct,    --'End City'     ,
LoadedMlsMove, --'LD Miles Move' ,
MTMlsMove, --'MT Miles Move'  ,
TotMlsMove, --'Tot Miles Move' ,
LoadedMlsLegHeader, --'LD Miles Leg',
MTMlsLegHeader, --'MT Miles Leg' ,
TotMlsLegHeader, --'Tot Miles Leg',
TotLHChargeForMove,  --'Tot LH Charge Move'  ,
AccChargeMove,                     --'Acc Charge Move'                    ,
AllChargesMove,       --'All Charges Move' ,
PercentLghMlsOfMoveMls, --'% Leg Miles of Move Miles',
AllocatedLHChargeForLgh, --'Allocated LH' ,
AllocatedAcclChargeForLgh, --'Allocated Acc' ,
AllocatedTotlChargesForLgh, --'Allocated Tot Charges',
RevPerMileAllCharges, --'Rev/Mile ALL Charges' ,
RevPerMileLHCharge,   --'Rev/Mile LH' ,
'FirstBillTo' = (select Company.cmp_name from Company (NOLOCK) where FirstBillTo = Company.cmp_id), --'First BillTo' ,
lgh_class1, --'RevType 1',
lgh_class2, --'RevType 2' ,
lgh_class3, --'RevType 3',
lgh_class4, --'RevType 4',
trc_type1, --'TRC Type 1',
trc_type2, --'TRC Type 2',
trc_type3, --'TRC Type 3',
trc_type4, --'TRC Type 4',
FirstBillDate,            --'First BillDate'                              ,
LastBillDate,   --'Last BillDate'                         ,
FirstCompletionDate,           --'First CMP Date'    ,
TotalFuelSurchargeForMove, --'Tot FUEL Move',
AllocatedFuelSurchargeChargeForLgh, --'Allocated FUEL',
trc_company, --'TRC Company',
trc_division, --'TRC Division',
trc_fleet, --'TRC Fleet',
MinCommodityCode, --'Min Commodity Code',
MinCommodityClass, --'Min Commodity Class',
MinOrderHdrnumber, --'Min Ord #',
WeekOfTheYear, --'Week of Year',
CompletionDateOnly,                   --'CMP Date',
mpp_type1, --'RV Type 1',
mpp_type2, --'RV Type 2',
mpp_type3, --'RV Type 3',
mpp_type4, --'RV Type 4',
NumberOfSplitsOnMove, --'# of Splits Move' ,
NumberOfOrdersOnLeg, --'# of Orders on Leg' ,
NumberOfInvoicesOnMove, --' # of Invoices on Move' ,
YYYY_MM_DD_LghEndDT, --'YYYY_MM_DD Leg EndDT' ,
YYYY_MM_WWLghEndDT, --'YYYY_MM_WW Leg EndDT',
AllocRevMinusPay,     --'Allocated Rev - Pay' ,
AllocRevMinusPayPerTrvlMile, --'Alloc Rev - Pay Per Travel Mile'
mpp_teamleader,
CountofLoads  
from #LegHeaderSummary 
order by mov_number, lgh_startdate
jr */
-- Limpia la tabla de la inf
delete LegHeaderSummary_SSRS_Ded_Optimizado;


Insert LegHeaderSummary_SSRS_Ded_Optimizado (ord_hdrnumber,
lgh_tractor,lgh_primary_trailer,mov_number,lgh_number,LoadedMlsMove,MTMlsMove,
TotMlsMove,LoadedMlsLegHeader,MTMlsLegHeader,TotMlsLegHeader,TotLHChargeForMove,AccChargeMove,
AllChargesMove,PercentLghMlsOfMoveMls,AllocatedLHChargeForLgh,AllocatedAcclChargeForLgh,AllocatedTotlChargesForLgh,
RevPerMileAllCharges,RevPerMileLHCharge,AllocRevMinusPay,AllocRevMinusPayPerTrvlMile,mpp_teamleader,
revtype1, revtype2, revtype3, revtype4, mpp_type1, mpp_type2, mpp_type3, mpp_type4 )
Select ord_hdrnumber, 
lgh_tractor, lgh_primary_trailer, mov_number, lgh_number, LoadedMlsMove,MTMlsMove,
TotMlsMove,LoadedMlsLegHeader,MTMlsLegHeader, TotMlsLegHeader,TotLHChargeForMove,AccChargeMove,
AllChargesMove,PercentLghMlsOfMoveMls,AllocatedLHChargeForLgh,AllocatedAcclChargeForLgh,AllocatedTotlChargesForLgh,
RevPerMileAllCharges,RevPerMileLHCharge,AllocRevMinusPay,  AllocRevMinusPayPerTrvlMile,mpp_teamleader,
lgh_class1, lgh_class2, lgh_class3, lgh_class4, mpp_type1, mpp_type2, mpp_type3, mpp_type4
from #LegHeaderSummary 
order by mov_number, lgh_startdate

--SET NOCOUNT ON
ENDE:
Drop table #movlist
Drop table #LegHeaderSummary
Drop table #OrdCompDTFix
--SET NOCOUNT OFF

GO
