SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'revpermile',1


CREATE    Proc [dbo].[WatchDog_RevPerMile] 
( 
        @MinThreshold float = 1.25, -- If @MinThresholdWithoutFuelSurcharge is populated, this threshold is only for orders with fuel surcharge

        @MinsBack int=-20, 
        @TempTableName varchar(255) = '##WatchDogGlobalRevPerMile', 
        @WatchName varchar(255) = 'RevPerMile', 
        @ThresholdFieldName varchar(255) = 'RevenuePerMile', 
        @ColumnNamesOnly bit = 0, 
        @ExecuteDirectly bit = 0, 
        @ColumnMode varchar (50) ='Selected', 

        @RevType1 varchar(140)='', 
        @RevType2 varchar(140)='', 
        @RevType3 varchar(140)='', 
        @RevType4 varchar(140)='', 
        @IncludeChargeTypeListOnly varchar(255)='', 
        @ExcludeChargeTypeListOnly varchar(255) = '', 
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
        @MinThresholdWithoutFuelSurcharge float = 0, -- If used, @ExcludeChargeTypeListOnly MUST be populated with Fuel surcharge charge types

                                                                                                -- If this is not used, MinThreshold will return even orders without fuel surcharge

                                                                                                -- If populated, @MinThresholdWithoutFuelSurcharge will contain a higher value than @MinThreshold

        @ParameterToUseForDynamicEmail varchar(50) = '', -- RevType1, RevType2, RevType3, RevType4, BookedBy, 
        @IncludeLoadStatus varchar(20)= '' ,
		@OnlyOriginRegionList varchar(255) ='',
		@OnlyDestinationRegionList varchar(255) ='',
		@OnlyOriginRegion2List varchar(255) ='',
		@OnlyDestinationRegion2List varchar(255) ='',
		@OnlyOriginRegion3List varchar(255) ='',
		@OnlyDestinationRegion3List varchar(255) ='',
		@OnlyOriginRegion4List varchar(255) ='',
		@OnlyDestinationRegion4List varchar(255) ='',
		@LHOnlyYN char(1) = 'N'

                                                                                                
) 

As 

        set nocount on 
        
        /* 
        Procedure Name:    WatchDog_RevPerMile 
        Author/CreateDate: Brent Keeton / 6-15-2004 
        Purpose:           
        Revision History: 	Lori Brickley / 5-24-2005 / Add Exclude Origin State 
							Brad Young / 7/31/06 Adding Region Parms
							Marcia Sachs / 8/7/2006 Add Tractor and Updated Date columns
							Brad Young  9/5/06 Add LHOnlyYN parm
							Marcia Sachs 12/7/06 Added TOTMLS and REVMPCT columns
		*/ 
        
        
        --Reserved/Mandatory WatchDog Variables 
        Declare @SQL varchar(8000) 
        Declare @COLSQL varchar(4000) 
        --Reserved/Mandatory WatchDog Variables 
        
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
        
		Set @OnlyOriginRegionList= ',' + ISNULL(@OnlyOriginRegionList,'') + ','
		Set @OnlyDestinationRegionList= ',' + ISNULL(@OnlyDestinationRegionList,'') + ','
		Set @OnlyOriginRegion2List= ',' + ISNULL(@OnlyOriginRegion2List,'') + ','
		Set @OnlyDestinationRegion2List= ',' + ISNULL(@OnlyDestinationRegion2List,'') + ','
		Set @OnlyOriginRegion3List= ',' + ISNULL(@OnlyOriginRegion3List,'') + ','
		Set @OnlyDestinationRegion3List= ',' + ISNULL(@OnlyDestinationRegion3List,'') + ','
		Set @OnlyOriginRegion4List= ',' + ISNULL(@OnlyOriginRegion4List,'') + ','
		Set @OnlyDestinationRegion4List= ',' + ISNULL(@OnlyDestinationRegion4List,'') + ','


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
				AND (@OnlyOriginRegionList =',,' or CHARINDEX(',' + lgh_Startregion1 + ',', @OnlyOriginRegionList) >0)			
				AND (@OnlyDestinationRegionList= ',,' or CHARINDEX(',' + lgh_Endregion1 + ',', @OnlyDestinationRegionList) >0)			
				AND (@OnlyOriginRegion2List =',,' or CHARINDEX(',' + lgh_Startregion2 + ',', @OnlyOriginRegion2List) >0)			
				AND (@OnlyDestinationRegion2List= ',,' or CHARINDEX(',' + lgh_Endregion2 + ',', @OnlyDestinationRegion2List) >0)			
				AND (@OnlyOriginRegion3List =',,' or CHARINDEX(',' + lgh_Startregion3 + ',', @OnlyOriginRegion3List) >0)			
				AND (@OnlyDestinationRegion3List= ',,' or CHARINDEX(',' + lgh_Endregion3 + ',', @OnlyDestinationRegion3List) >0)			
				AND (@OnlyOriginRegion4List =',,' or CHARINDEX(',' + lgh_Startregion4 + ',', @OnlyOriginRegion4List) >0)			
				AND (@OnlyDestinationRegion4List= ',,' or CHARINDEX(',' + lgh_Endregion4 + ',', @OnlyDestinationRegion4List) >0)			

        
        Select stops.ord_hdrnumber, 
               (        select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') 
                                from city (NOLOCK) 
                                where stp_city = cty_code 
                        ) as [Stop City State], 
               stops.mov_number,               IsNull(stops.stp_lgh_mileage,0) as Miles, 
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

        Select  (       select cmp_name 
                                from company (NOLOCK) 
                                where cmp_id = ord_shipper 
                        ) as Shipper, 
                [Origin], 
                [Destination], 
                ord_number as [Order #], 
                [Move #], 
                TotalMiles, 
                Revenue, 
                RevPerMile, 
                ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default, default, default, default, default, default, default, default, default, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, default, default, default, default, default, default, default, default, default, default, default, default, ord_bookedby),'') AS EmailSend ,

                ord_revtype2 as [RevType2], 
                ord_revtype1 as [RevType1],
				ord_tractor as [Tractor],
				last_updatedate as [Updated Date],
				TOTMLS =dbo.fnc_TMWRN_MoveMiles(mov_number,'','','All','','y',''),
  		  		REVMPCT = convert(money,case  when ISNULL(dbo.fnc_TMWRN_MoveMiles(mov_number,'','','All','','y',''),0) > 0 
    		   		then 
     			     (ISNULL(dbo.fnc_TMWRN_MoveMiles(mov_number,'','','All','','y',''),0)/dbo.fnc_MetricHelper_TravelMilesForMove(mov_number)) * 100 
    		   		end)        
        into    #TempResults 
        From    orderheader (NOLOCK), 
                        ( 
                                Select  Case When TotalMiles = 0 then 
                                            cast(Revenue as Money) 
                                        Else 
                                            cast((Revenue/TotalMiles) as Money) 
                                        End as RevPerMile, 
                                        TempMoves.* 
                                From  
                                ( 
                                        select 'Origin' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select min(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0)),

                                        'Destination' = (select min([Stop City State]) from #TempStops b (NOLOCK) where b.mov_number = #Tempstops.mov_number and b.ord_hdrnumber <> 0 and b.stp_mfh_sequence = (select max(c.stp_mfh_sequence) from #TempStops c (NOLOCK) where c.mov_number = b.mov_number and c.ord_hdrnumber <> 0)),  

                                        [Order Header Number] = (select min(b.ord_hdrnumber) from #TempStops b (NOLOCK) where b.mov_number = #TempStops.mov_number and b.ord_hdrnumber <> 0),

                                        mov_number as [Move #], 
                                        (select sum(IsNull(b.Miles,0)) from #TempStops b where b.mov_number = #TempStops.mov_number and (@IncludeLoadStatus=',,' or CHARINDEX(',' + RTrim(IsNull(stp_loadstatus,'')) + ',', @IncludeLoadStatus) >0)) as TotalMiles,

                                        --min(IsNull(dbo.fnc_TotRevForMove(mov_number,@IncludeChargeTypeListOnly,@ExcludeBillToIDList),0)) as Revenue

                                        min(IsNull(dbo.fnc_TMWRN_Revenue('Movement',default,default,mov_number,default,default,default,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,@LHOnlyYN,'',@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0)) as Revenue         

--                                      min(IsNull(dbo.fnc_TMWRN_Revenue('Movement',default,default,mov_number,default,default,default,@IncludeChargeTypeListOnly,@ExcludeChargeTypeListOnly,'','',@OnlyRevenueFromChargeTypesYN,@ExcludeBillToIDList,@IncludeBillToIDList,'',''),0)) as Revenue         

                                        From   #TempStops 
                                        Group By mov_number 
                                ) as TempMoves 
        
                        ) as TempMoveRevPerMile 
        Where  (RevPerMile < @MinThreshold AND @MinThresholdWithoutFuelSurcharge = 0 
                        OR RevPerMile < @MinThreshold 
                        AND IsNull((    SELECT IsNull(sum(ivd_charge),0.00) 
                                                FROM  invoicedetail (NOLOCK), 
                                                        chargetype (NOLOCK) 
                                                WHERE invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber 
                                                        And invoicedetail.cht_itemcode=chargetype.cht_itemcode 
                                                        AND ( 
                                                                        Upper(chargetype.cht_itemcode) like 'FUEL%' 
                                                                        OR 
                                                                        CharIndex('FUEL', cht_description)>0 
                                                                ) 
                                                        and ivd_charge is Not Null 
                                                        ),0) >= 1 
                        OR RevPerMile < @MinThresholdWithoutFuelSurcharge 
                                And IsNull((    SELECT IsNull(sum(ivd_charge),0.00) 
                                                FROM  invoicedetail (NOLOCK), 
                                                        chargetype (NOLOCK) 
                                                WHERE invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber 
                                                        And invoicedetail.cht_itemcode=chargetype.cht_itemcode 
                                                        AND ( 
                                                                        Upper(chargetype.cht_itemcode) like 'FUEL%' 
                                                                        OR 
                                                                        CharIndex('FUEL', cht_description)>0 
                                                                ) 
                                                        and ivd_charge is Not Null 
                                                        ),0) < 1) 

                And orderheader.ord_hdrnumber = [Order Header Number] 
                And Revenue > 0 
                And ( 
                                (@InvoicedLoadsYN = 'Y' and exists (
																		select * 
																		from invoiceheader (NOLOCK) 
																		where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
																			AND  (@InvoiceStatus =',,' or CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatus) >0) ))

                                Or 
                                (@InvoicedLoadsYN = 'N') 
                ) 
                And (@OriginState=',,' or CHARINDEX(',' + ord_originstate + ',', @OriginState) >0) 
                And (@ExcludeOriginState=',,' or CHARINDEX(',' + ord_originstate + ',', @ExcludeOriginState) =0) 
                
                
                        -- And 
               --(@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + ord_billto + ',', @ExcludeBillToIDList) > 0)) 
        order by RevPerMile ASC 
        
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
