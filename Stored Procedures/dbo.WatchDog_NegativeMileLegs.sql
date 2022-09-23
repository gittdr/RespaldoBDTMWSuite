SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--select * from stops where stp_arrivaldate >= '4/1/2005' and stp_lgh_mileage=-1



--WatchDogProcessing 'NegativeMileLegs' ,1
Create                                                                 Proc [dbo].[WatchDog_NegativeMileLegs] (@MinThreshold float = 200,@MinsBack int=-20,@TempTableName varchar(255) = '##WatchDogGlobalNegativeMileLegs',@WatchName varchar(255)='WatchNegativeMileLegs',@ThresholdFieldName varchar(255) = 'Negative Miles',@ColumnNamesOnly bit = 0,@ExecuteDirectly bit = 0,@ColumnMode varchar(50) = 'Selected',
						  @DrvType1 varchar(255)='',
					          @DrvType2 varchar(255)='',
					          @DrvType3 varchar(255)='',
						  @DrvType4 varchar(255)='',
						  @RevType1 varchar(255)='',
					          @RevType2 varchar(255)='',
					          @RevType3 varchar(255)='',
						  @RevType4 varchar(255)='',
						  @DispatchStatus varchar(140)='',
						  @OnlyOriginRegion1List varchar(255) = '',
						  @OnlyDestinationRegion1List varchar(255) = '',
						  @ExcludeOriginRegion1List varchar(255) = '',
						  @ExcludeDestinationRegion1List varchar(255) = '',
						  @OnlyOriginStateList varchar(255) = '',
						  @OnlyDestinationStateList varchar(255) = '',
						  @ExcludeOriginStateList varchar(255) = '',
						  @ExcludeDestinationStateList varchar(255) = '',
						  @TractorTerminal varchar(255) = '',
						  @TeamLeaderIDList varchar(255) = ''
 						 )
						

As

Set NoCount On


/*
Procedure Name:    WatchDog_NegativeMileLegs
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns all empty legs above a specific threshold
Revision History:
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables





Set @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
Set @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
Set @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
Set @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
Set @DispatchStatus= ',' + ISNULL(@DispatchStatus,'') + ','
Set @OnlyOriginRegion1List= ',' + ISNULL(@OnlyOriginRegion1List,'') + ','
Set @OnlyDestinationRegion1List= ',' + ISNULL(@OnlyDestinationRegion1List,'') + ','
Set @ExcludeOriginRegion1List= ',' + ISNULL( @ExcludeOriginRegion1List,'') + ','
Set @ExcludeDestinationRegion1List= ',' + ISNULL(@ExcludeDestinationRegion1List,'') + ','
Set @OnlyOriginStateList= ',' + ISNULL(@OnlyOriginStateList,'') + ','
Set @OnlyDestinationStateList= ',' + ISNULL(@OnlyDestinationStateList,'') + ','
Set @ExcludeOriginStateList= ',' + ISNULL( @ExcludeOriginStateList,'') + ','
Set @ExcludeDestinationStateList= ',' + ISNULL(@ExcludeDestinationStateList,'') + ','
Set @TractorTerminal = ',' + ISNULL(@TractorTerminal,'') + ','
Set @TeamLeaderIDList = ',' + ISNULL(@TeamLeaderIDList,'') + ','



Select legheader_active.lgh_number,
       legheader_active.mov_number,
       lgh_updatedby as [Updated By],
       --'Updated By' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = mpp_teamleader and labeldefinition = 'UpdatedBy'),lgh_updatedby),
       lgh_driver1 as [Driver ID],
       lgh_outstatus,
       'Driver' = IsNull((select mpp_lastfirst from manpowerprofile (NOLOCK) where mpp_id = lgh_driver1),lgh_driver1),
       c1.cty_region1 as [Origin Region1],
       c2.cty_region1 as [Destination Region1],
       cast((select sum(IsNull(stp_lgh_mileage,0)) from stops (NOLOCK) where stops.mov_number = legheader_active.mov_number) as float) as MoveMiles
into   #LegList
From   legheader_active (NOLOCK) Left Join  orderheader(NOLOCK) On orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber
				 Left Join  city c1 (NOLOCK) On c1.cty_code = orderheader.ord_origincity
				 Left Join  city c2 (NOLOCK) On c2.cty_code = orderheader.ord_destcity
Where
       lgh_enddate >= DateAdd(mi,@MinsBack,GetDate())
       And
       (@DrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
       AND 
       (@DrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
       AND 
       (@DrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
       AND 
       (@DrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
       And
       (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0)
       AND 
       (@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0)
       AND 
       (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0)
       AND 
       (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0)
       And
       (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0)
       And
       (@OnlyOriginRegion1List =',,' or CHARINDEX(',' + c1.cty_region1 + ',', @OnlyOriginRegion1List) >0)			
       And
       (@TractorTerminal =',,' or CHARINDEX(',' + trc_terminal + ',', @TractorTerminal) >0)
       And
       (@OnlyDestinationRegion1List =',,' or CHARINDEX(',' + c2.cty_region1 + ',', @OnlyDestinationRegion1List) >0)			
       And
       (@ExcludeOriginRegion1List = ',,' OR Not (CHARINDEX(',' + c1.cty_region1 + ',', @ExcludeOriginRegion1List) > 0)) 
       And 
       (@ExcludeDestinationRegion1List = ',,' OR Not (CHARINDEX(',' + c2.cty_region1 + ',', @ExcludeDestinationRegion1List) > 0)) 
       And
       (@OnlyOriginStateList =',,' or CHARINDEX(',' + ord_originstate + ',', @OnlyOriginStateList) >0)			
       And
       (@OnlyDestinationStateList =',,' or CHARINDEX(',' +ord_deststate + ',', @OnlyDestinationStateList) >0)			
       And
       (@ExcludeOriginStateList = ',,' OR Not (CHARINDEX(',' + ord_originstate + ',', @ExcludeOriginStateList) > 0)) 
       And 
       (@ExcludeDestinationStateList = ',,' OR Not (CHARINDEX(',' + ord_deststate + ',', @ExcludeDestinationStateList) > 0)) 
	And
       (@TeamLeaderIDList =',,' or CHARINDEX(',' + mpp_teamleader + ',', @TeamLeaderIDList) >0) 
		

Select #LegList.*
       
       
into   #TempLegHeaders
From   #LegList,stops (NOLOCK)
Where  
       
       stops.lgh_number = #LegList.lgh_number
  

group by #LegList.lgh_number,[Updated By],[Driver ID],[Driver],lgh_outstatus,#LegList.mov_number,[Origin Region1],[Destination Region1],MoveMiles
--If threshold is on the move level then test the threshold
--if on the leg will test it below


      
order by #LegList.lgh_number,#LegList.mov_number


Select  
	IsNull((select cty_name from city (NOLOCK) where a.stp_city = cty_code),'') as 'Origin City',
	IsNull((select cty_state from city (NOLOCK) where a.stp_city = cty_code),'') as 'Origin State',
	[Dest City],
	[Dest State],
	[Miles],
	[Updated By],
	--[Dispatcher ID],
	--[Dispatcher],
        [Order Number],
	a.mov_number as [Move Number],
        [Dispatch Status],
	[Origin Region1],
	[Destination Region1]
	
        
into   #TempResults	
from   stops a (NOLOCK),
	(
       Select
       	     IsNull((select cty_name from city (NOLOCK) where a.stp_city = cty_code),'') as 'Dest City',
             IsNull((select cty_state from city (NOLOCK) where a.stp_city = cty_code),'') as 'Dest State',
             a.stp_lgh_mileage as [Miles],
	     --[Dispatcher ID],

	     --[Dispatcher],
	     [Updated By],
             [Driver ID],
             (select ord_number from orderheader (NOLOCK) where a.ord_hdrnumber = orderheader.ord_hdrnumber) as [Order Number],
             lgh_outstatus as [Dispatch Status],
	     #TempLegHeaders.mov_number,
             #TempLegHeaders.lgh_number,
             a.stp_mfh_sequence,
             a.stp_number,
	     #TempLegHeaders.[Origin Region1],
	     #TempLegHeaders.[Destination Region1]
	   

from   #TempLegHeaders,stops a (NOLOCK)
where   #TempLegHeaders.lgh_number = a.lgh_number
       and
        (
	  (a.lgh_number = (select min(b.lgh_number) from legheader b (NOLOCK) where b.mov_number = a.mov_number and b.lgh_outstatus <> 'CAN') and a.stp_mfh_sequence > (select min(b.stp_mfh_sequence) from stops b (NOLOCK) where b.lgh_number = a.lgh_number))
	 	OR
	  (a.lgh_number > (select min(b.lgh_number) from legheader b (NOLOCK) where b.mov_number = a.mov_number and b.lgh_outstatus <> 'CAN') and a.stp_mfh_sequence >= (select min(b.stp_mfh_sequence) from stops b (NOLOCK) where b.lgh_number = a.lgh_number))

        )
       ) as TempDestination


where  a.stp_mfh_sequence = (select max(b.stp_mfh_sequence) from stops b (NOLOCK) where b.stp_mfh_sequence < TempDestination.stp_mfh_sequence and b.mov_number = TempDestination.mov_number)
       and
       a.mov_number = TempDestination.mov_number
       And
       [Miles]= -1
     

Order By [Move Number],a.stp_mfh_sequence

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


Set NoCount Off



GO
GRANT EXECUTE ON  [dbo].[WatchDog_NegativeMileLegs] TO [public]
GO
