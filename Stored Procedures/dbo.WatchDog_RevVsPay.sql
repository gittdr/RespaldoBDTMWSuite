SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'revenuevspay',1

CREATE Proc [dbo].[WatchDog_RevVsPay] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalRevvsPay',
	@WatchName varchar(255) = 'RevenueVsPay',
	@ThresholdFieldName varchar(255) = 'Net',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @ThresholdType varchar(255) = 'Dollars', --Choices:Dollars,PercentofRevenue
  	@RevType1 varchar(140)='',
  	@RevType2 varchar(140)='',
  	@RevType3 varchar(140)='',
  	@RevType4 varchar(140)='',
  	@DriverType1 varchar(140)='',
  	@DriverType2 varchar(140)='',
  	@DriverType3 varchar(140)='',
  	@DriverType4 varchar(140)='',
	@DriverFleet varchar(255)='',
  	@IncludeChargeTypeListOnly varchar(255)='',
  	@ExcludeChargeTypeListOnly varchar(255)='',
	@LineHaulRevenueOnlyYN varchar(1)='',
  	@IncludePayTypeListOnly varchar(255)='',
 	@ExcludePayTypeListOnly varchar(255)='',
  	@IncludeBillToIDList varchar(255)='',
  	@ExcludeBillToIDList varchar(255)='',
 	@DateType varchar(100)='BILL',
  	@PayDetailStatus varchar(200) = '',
  	@OnlyRevenueFromChargeTypesYN char(1) = 'N',
	@InvoiceStatusList varchar(255)='',
  	@PayHeaderStatus varchar(200) = 'XFR,COL,REL',
  	@PayMovementMode varchar(200) = 'ReleasedPay', --Other Modes-> 'GreaterThenZeroPay','' (if blank then the amount of pay doesn't matter it will return if threshold is met)
		--A.ReleasedPay -> Only show movements where the net between revenue and pay 
				 --is below or equal to the specified threshold and ONLY MOVES where the pay has been released
		--B.GreaterThenZeroPay-> Only show movements where the net between revenue and pay 
				 --is below or equal to the specified threshold and ONLY MOVES where the pay is > 0
		--C.AllPay-> Show All Movements where the net between revenue and pay is below or equal the specified threshold
			   --There is no requirement on the pay amount or no pay status restriction
	@OnlyDestState varchar(255)='',
	@ExcludeDestState varchar(255)=''
 
	)

As

set nocount on


/*
Procedure Name:    WatchDog_RevVsPay
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   
Revision History:
		 1. Changed PayMovementMode to Allow records to be returned regardless of pay status V 1.7 LBK
		 2. Added InvoiceStatus List as of 6/3/05
*/


--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
Set @DriverType1= ',' + RTrim(ISNULL(@DriverType1,'')) + ','
Set @DriverType2= ',' + RTrim(ISNULL(@DriverType2,'')) + ','
Set @DriverType3= ',' + RTrim(ISNULL(@DriverType3,'')) + ','
Set @DriverType4= ',' + RTrim(ISNULL(@DriverType4,'')) + ','
Set @PayDetailStatus = ',' + RTrim(ISNULL(@PayDetailStatus,'')) + ','
Set @PayHeaderStatus = ',' + RTrim(ISNULL(@PayHeaderStatus,'')) + ','
Set @DriverFleet = ',' + RTrim(ISNULL(@DriverFleet,'')) + ','
Set @InvoiceStatusList =  ',' + RTrim(ISNULL(@InvoiceStatusList,'')) + ','
Set @OnlyDestState =  ',' + RTrim(ISNULL(@OnlyDestState,'')) + ','
Set @ExcludeDestState =  ',' + RTrim(ISNULL(@ExcludeDestState,'')) + ','

/*ThresholdField->Net*/


Exec WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 


--Create SQL and return results into #TempResults

Create Table #MoveList (mov_number int)

If @DateType = 'Bill'
Begin
	--Look at Moves that have change in the last X minutes
	Insert Into #MoveList
	select distinct invoiceheader.mov_number
	From   invoiceheader (NOLOCK),legheader (NOLOCK)
	where  ivh_billdate >= DateAdd(mi,@MinsBack,GetDate())
       	       And
       	       ivh_invoicestatus <> 'CAN'
               And
               invoiceheader.ord_hdrnumber <> 0 
               And
               (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
               AND 
               (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
               AND 
               (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
               AND 
               (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
	           AND
	           legheader.mov_number = invoiceheader.mov_number
	           AND 
	           (@DriverType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @DriverType1) >0)
               AND 
	           (@DriverType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @DriverType2) >0)
               AND 
               (@DriverType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @DriverType3) >0)
               AND 
               (@DriverType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @DriverType4) >0)
			   AND 
               (@DriverFleet =',,' or CHARINDEX(',' + mpp_fleet + ',', @DriverFleet) >0)
	           And
      	       (
				(@ColumnNamesOnly = 1 And 1=0)
				OR
				(@ColumnNamesOnly = 0)
       	       )
		

End
Else
Begin
	
	--Look at Moves that have change in the last X minutes
	--but driven by when the paydetails last changed or 
	--more then likely released
	Insert Into #MoveList
	select distinct invoiceheader.mov_number
	From   paydetail (NOLOCK)
			Left Join payheader (NOLOCK) On paydetail.pyh_number = payheader.pyh_pyhnumber
			Inner Join legheader (NOLOCK) On legheader.mov_number = paydetail.mov_number
			Inner Join invoiceheader (NOLOCK) On paydetail.mov_number = invoiceheader.mov_number
			
	where  pyd_updatedon >= DateAdd(mi,@MinsBack,GetDate())
       	       And
       	       ivh_invoicestatus <> 'CAN'
               And
              (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
               AND 
              (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
               AND 
              (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
               AND 
              (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
	           AND 
	          (@DriverType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @DriverType1) >0)
               AND 
               (@DriverType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @DriverType2) >0)
               AND 
               (@DriverType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @DriverType3) >0)
               AND 
               (@DriverType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @DriverType4) >0)
			   AND 
               (@DriverFleet =',,' or CHARINDEX(',' + mpp_fleet + ',', @DriverFleet) >0)
	           AND
	           (@PayDetailStatus =',,' or CHARINDEX(',' + pyd_status + ',', @PayDetailStatus) >0)
	           AND
	           (@PayHeaderStatus =',,' or CHARINDEX(',' + pyh_paystatus + ',', @PayHeaderStatus) >0)
	           AND
	       	   (
				(@ColumnNamesOnly = 1 And 1=0)
				OR
				(@ColumnNamesOnly = 0)
       	       )




End

Select stops.ord_hdrnumber,
       (select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK) where stp_city = cty_code) as [Stop City State], 
       stops.mov_number,
       stops.stp_lgh_mileage as Miles,
       stp_mfh_sequence,
	   (select IsNull(cty_state,'') from city (NOLOCK) where stp_city = cty_code) as DestState 
       

into   #TempStops
From   #MoveList (NOLOCK),stops (NOLOCK)
Where  #MoveList.mov_number = stops.mov_number
      
Select

      (select cmp_name from company (NOLOCK),orderheader (NOLOCK) where orderheader.ord_shipper = company.cmp_id and orderheader.ord_hdrnumber = [Order Header Number]) as Shipper,
       [Origin],
       [Destination],
       [Order Header Number] as 'Order Number',
       [Move #],
       cast([Revenue] as decimal(15,2)) as Revenue,
       cast([Pay] as decimal(15,2)) as Pay,
       cast((Revenue-Pay) as decimal(15,2)) as Net,
       [PayReleased],
       NumberofSplits,
      ((Pay)/Case When Revenue = 0 Then 1 Else Revenue End)  as PercentofRevenue
       
       
	
     	
into    #TempResults
From

(

Select TempMoves.*,
       IsNull(dbo.fnc_TMWRN_Revenue('Movement',default,default,[Move #],default,default,default,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,@LineHaulRevenueOnlyYN,'',@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,'',@InvoiceStatusList),0) as Revenue, 
       dbo.fnc_TotPayForMove([Move #],@ExcludePayTypeListOnly,@IncludePayTypeListOnly) as Pay,
       PayReleased = IsNull((select min('Y') from paydetail (NOLOCK) where paydetail.mov_number = TempMoves.[Move #] and paydetail.pyd_status = 'REL'),'N'),	
       NumberofSplits = (Select count(lgh_number) from legheader (NOLOCK) where legheader.mov_number = TempMoves.[Move #] and legheader.lgh_outstatus <> 'CAN')

From  

(

select 'Origin' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select min(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0)),
       'Destination' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select max(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0)),  
       [Order Header Number] = (select min(b.ord_hdrnumber) from #TempStops b (NOLOCK) where b.mov_number = #TempStops.mov_number and b.ord_hdrnumber <> 0),
       mov_number as [Move #],
	   deststate = (select min(deststate) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select max(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0))
         
From   #TempStops
Group By mov_number

) as TempMoves

) as TempRevVsPay

Where  (
			(@ThresholdType = 'Dollars' And (Revenue-Pay) <= @MinThreshold)
			 Or
			(@ThresholdType = 'PercentOfRevenue' And (Case When Revenue <> 0 Then ((Pay)/Revenue) Else 0 End) >= @MinThreshold)
       )
       And
       Revenue > 0
       And
       (
	 		(@PayMovementMode = 'ReleasedPay' and PayReleased = 'Y')  --just moves where the pay is released
	 		 Or  
	 		(@PayMovementMode = 'GreaterThenZeroPay' and Pay > 0) --just moves where pay > 0
	 		 Or 
	 		(@PayMovementMode = 'AllPay') --No Restriction so only return where the net
				 --is below or equal to the threshold
       )
	   And (@OnlyDestState =',,' or CHARINDEX(',' + DestState + ',', @OnlyDestState) >0)		
       And (@ExcludeDestState =',,' or CHARINDEX(',' + DestState + ',', @ExcludeDestState) =0)	
	  
order by case when @ThresholdType = 'Dollars' then (Revenue-Pay) end,
	 case when @ThresholdType = 'PercentOfRevenue' then ((Pay)/Case When Revenue = 0 Then 1 Else Revenue End) end 
	 DESC
		
	  

--Commits the results to be used in the wrapper
If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
Begin
	Set @SQL = 'Select * from #TempResults'
End
Else
Begin
	Set @COLSQL = ''
	Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
End

Exec (@SQL)


set nocount off


GO
GRANT EXECUTE ON  [dbo].[WatchDog_RevVsPay] TO [public]
GO
