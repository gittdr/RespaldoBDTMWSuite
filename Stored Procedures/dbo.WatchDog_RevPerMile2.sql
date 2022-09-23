SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

	CREATE  Proc [dbo].[WatchDog_RevPerMile2]
( 
        @MinThreshold float = 1.25, -- If @MinThresholdWithoutFuelSurcharge is populated, this threshold is only for orders with fuel surcharge
        @MinsBack int=-20, 
        @TempTableName varchar(255) = '##WatchDogGlobalRevPerMile2', 
        @WatchName varchar(255) = 'RevPerMile2', 
        @ThresholdFieldName varchar(255) = 'RevenuePerMile', 
        @ColumnNamesOnly bit = 0, 
        @ExecuteDirectly bit = 0, 
        @ColumnMode varchar (50) ='Selected', 
	-- optional / additional parameters
        @RevType1 varchar(140)='', 
        @RevType2 varchar(140)='', 
        @RevType3 varchar(140)='', 
        @RevType4 varchar(140)='', 
        @IncludeChargeTypeListOnly varchar(255)='', 
        @ExcludeChargeTypeListOnly varchar(255) = '', 
		@FuelSurchargeTypeListOnly varchar(255) = '',
        @ExcludeBillToIDList varchar(255)='', 
        @IncludeBillToIDList varchar(255)='', 
        @InvoicedLoadsYN char(1) = 'N', 
        @InvoiceStatus varchar(255)='',
        @TeamLeaderIDList varchar(255) = '', 
        @RevType2Like varchar(30)='', 
        @DispatchStatus varchar(255)='', 
        @OnlyRevenueFromChargeTypesYN char(1) = 'N', 
        @OriginState varchar(255)='', 
        @ExcludeOriginState varchar(255)='', 
        @ExcludeOriginStateMiles varchar(255)='', 
        @MinThresholdWithoutFuelSurcharge float = 0,	-- If > 0, @FuelSurchargeTypeListOnly MUST be populated with Fuel surcharge charge types
                                                        -- If <= 0, judgement based on comparison of RevAllPerMile and @MinThreshold only
                                                        -- If >0, judgement based on comparison of RevAllPerMile and @MinThreshold AND RevNoFuel and @MinThresholdWithoutFuelSurcharge
														--	In that case, if EITHER fails the test the record is returned
        @ParameterToUseForDynamicEmail varchar(50) = '', -- RevType1, RevType2, RevType3, RevType4, BookedBy, 
        @IncludeLoadStatus varchar(20)= '' 
                                                                                                
) 

As 

        set nocount on 
        
        /* 
        Procedure Name:    WatchDog_RevPerMile 
        Author/CreateDate: Brent Keeton / 6-15-2004 
        Purpose:           
        Revision History: Lori Brickley / 5-24-2005 / Add Exclude Origin State 
				6/20/2008: This version changes the evaluation of the 2 available thresholds by adding an
					independent @FuelSurchargeTypeListOnly parameter to hold fuel surcharge charge type codes.
					This allows the alert to evaluate both an OVERALL Rev Per Mile and a NO FUEL Rev Per Mile
					and "bark" if either falls short of its respective threshold level.
					The logic is considerably different than that of version 1 in this regard.
					
        */ 
        
        
        --Reserved/Mandatory WatchDog Variables 
        Declare @SQL varchar(8000) 
        Declare @COLSQL varchar(4000) 
        --Reserved/Mandatory WatchDog Variables 

		--	6/20/2008: Prep @FuelSurchargeTypeListOnly in the event that client wants to restrict charge types
		--	included (@ExcludeChargeTypeListOnly) AND isolate the fuel surcharge values (@FuelSurchargeTypeListOnly)
		If @MinThresholdWithoutFuelSurcharge > 0
			begin
				If (@ExcludeChargeTypeListOnly <> '' AND @FuelSurchargeTypeListOnly <> '')
					begin
						Set @FuelSurchargeTypeListOnly = @FuelSurchargeTypeListOnly + ',' + @ExcludeChargeTypeListOnly
					end
			end

        
        Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ',' 
        Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ',' 
        Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ',' 
        Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ',' 
        Set @TeamLeaderIDList= ',' + RTrim(ISNULL(@TeamLeaderIDList,'')) + ',' 
        Set @ExcludeBillToIDList = ',' + RTrim(ISNULL(@ExcludeBillToIDList,'')) + ',' 
        Set @DispatchStatus = ',' + RTrim(ISNULL(@DispatchStatus,'')) + ',' 
        Set @OriginState =  ',' + ISNULL(@OriginState,'') + ',' 
        Set @ExcludeOriginState =  ',' + ISNULL(@ExcludeOriginState,'') + ',' 
        Set @ExcludeOriginStateMiles    =  ',' + ISNULL(@ExcludeOriginStateMiles,'') + ',' 
        Set @IncludeLoadStatus  =  ',' + ISNULL(@IncludeLoadStatus,'') + ',' 
        Set @InvoiceStatus  =  ',' + ISNULL(@InvoiceStatus,'') + ',' 
        

        Exec WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 
        
        
        --Create SQL and return results into #TempResults 
        
        --Look at Moves that have change in the last X minutes 
        select distinct mov_number 
        into   #MoveList 
        From   legheader_active (NOLOCK) 
        where  lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate()) 
                And lgh_outstatus <> 'CAN' 
                And legheader_active.ord_hdrnumber <> 0 --weed out dedicated empty moves 
                And (@RevType1 =',,' or CHARINDEX(',' + lgh_class1 + ',', @RevType1) >0) 
                AND (@RevType2 =',,' or CHARINDEX(',' + lgh_class2 + ',', @RevType2) >0) 
                AND (@RevType3 =',,' or CHARINDEX(',' + lgh_class3 + ',', @RevType3) >0) 
                AND (@RevType4 =',,' or CHARINDEX(',' + lgh_class4 + ',', @RevType4) >0) 
                AND (@DispatchStatus =',,' or CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatus) >0) 
                AND (@TeamLeaderIDList =',,' or CHARINDEX(',' + mpp_teamleader + ',', @TeamLeaderIDList) >0) 
                AND     (@RevType2Like = '' or lgh_class2 IN    (       SELECT abbr 
                                                                FROM labelfile (NOLOCK) 
                                                                WHERE labeldefinition = 'RevType2' 
                                                                AND name like @RevType2Like 
                                                                        
                                                        )   )    
        
        Select stops.ord_hdrnumber, 
               (        select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') 
                                from city (NOLOCK) 
                                where stp_city = cty_code 
                        ) as [Stop City State], 
               stops.mov_number,               
				IsNull(stops.stp_lgh_mileage,0) as Miles, 
               stp_mfh_sequence, 
               stp_loadstatus 
        into   #TempStops 
        From   #MoveList (NOLOCK),stops (NOLOCK) 
        Where  #MoveList.mov_number = stops.mov_number 
                   

        IF @ExcludeOriginStateMiles <> ',,' 
                UPDATE #TempStops 
                SET Miles = 0 
                FROM #TEmpStops , #TEmpStops ts 
                WHERE #TempStops.mov_number = ts.mov_number 
                and #TempStops.stp_mfh_sequence -1 = ts.stp_mfh_sequence 
                And CHARINDEX(',' + right(ts.[Stop City State],2) + ',', @ExcludeOriginStateMiles) > 0 


        Select  (	select cmp_name 
                    from company (NOLOCK) 
                    where cmp_id = ord_shipper) as Shipper, 
                [Origin], 
                [Destination], 
                ord_number as [Order #], 
                [Move #], 
                TotalMiles, 
                RevAll, 
                RevAllPerMile, 
-- fields added 6/20/2008 
                Case When @MinThresholdWithoutFuelSurcharge <=0 then
					NULL
				Else
					RevNoFuel
				End as RevNoFuel, 
                Case When @MinThresholdWithoutFuelSurcharge <=0 then
					NULL
				Else
					RevNoFuelPerMile
				End as RevNoFuelPerMile, 
                ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default, default, default, default, default, default, default, default, default, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, default, default, default, default, default, default, default, default, default, default, default, default, ord_bookedby),'') AS EmailSend ,
                ord_revtype2 as [RevType2], 
                ord_revtype1 as [RevType1] 
        into    #TempResults 
        From    orderheader (NOLOCK), 
				(	Select	Case When TotalMiles = 0 then 
								cast(RevAll as Money) 
							Else 
								cast((RevAll/TotalMiles) as Money) 
							End as RevAllPerMile
-- calculation added 6/20/2008 
						,Case When TotalMiles = 0 then 
							cast(RevNoFuel as Money) 
						Else 
							cast((RevNoFuel/TotalMiles) as Money) 
						End as RevNoFuelPerMile
						,TempMoves.* 
					From (	select 'Origin' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select min(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0))
								,'Destination' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select max(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0))  
								,[Order Header Number] = (select min(b.ord_hdrnumber) from #TempStops b (NOLOCK) where b.mov_number = #TempStops.mov_number and b.ord_hdrnumber <> 0)
								,mov_number as [Move #]
								,(select sum(IsNull(b.Miles,0)) from #TempStops b where b.mov_number = #TempStops.mov_number and (@IncludeLoadStatus=',,' or CHARINDEX(',' + RTrim(IsNull(stp_loadstatus,'')) + ',', @IncludeLoadStatus) >0)) as TotalMiles
--								,min(IsNull(dbo.fnc_TotRevForMove(mov_number,@IncludeChargeTypeListOnly,@ExcludeBillToIDList),0)) as Revenue
								,min(IsNull(dbo.fnc_TMWRN_Revenue('Movement',default,default,mov_number,default,default,default,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,'','',@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0)) as RevAll
-- field added 6/20/2008 
								,min(IsNull(dbo.fnc_TMWRN_Revenue('Movement',default,default,mov_number,default,default,default,@IncludeChargeTypeListOnly,@FuelSurchargeTypeListOnly,'','',@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0)) as RevNoFuel         
                            From   #TempStops 
                            Group By mov_number ) as TempMoves ) as TempMoveRevPerMile 
        Where	
-- logic modified 6/20/2008 
				(
					(RevAllPerMile < @MinThreshold)
                        OR 
					(RevNoFuelPerMile < @MinThresholdWithoutFuelSurcharge)
				)
-- end logic modified 6/20/2008 
			And orderheader.ord_hdrnumber = [Order Header Number] 
			And RevAll > 0 
			And ( 
					(@InvoicedLoadsYN = 'Y' and exists (	select * 
															from invoiceheader (NOLOCK) 
															where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
																AND  (@InvoiceStatus =',,' or CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatus) >0) ))
						Or 
					(@InvoicedLoadsYN = 'N') 
                ) 
            And (@OriginState=',,' or CHARINDEX(',' + ord_originstate + ',', @OriginState) >0) 
            And (@ExcludeOriginState=',,' or CHARINDEX(',' + ord_originstate + ',', @ExcludeOriginState) =0) 
--			And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + ord_billto + ',', @ExcludeBillToIDList) > 0)) 
        order by RevAllPerMile ASC 
        
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
GRANT EXECUTE ON  [dbo].[WatchDog_RevPerMile2] TO [public]
GO
