SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[Metric_HoursPerOrder]
            (
                --Standard Parameters
                @Result decimal(20, 5) OUTPUT, 
                @ThisCount decimal(20, 5) OUTPUT, 
                @ThisTotal decimal(20, 5) OUTPUT, 
                @DateStart datetime,
                @DateEnd datetime, 
                @UseMetricParms int,
                @ShowDetail int,
                @MetricCode varchar(255)= 'HoursPerOrder',

                --Additional/Optional Parameters
                @DateType varchar(50) = 'Start', -- OR End,Book
                @DispatchStatusList varchar(128) = '',
                @OrderStatusList varchar(128) = '',
                @ExcludeOrderStatusList varchar(128)='',  
                @OnlyRevClass1List varchar(255) ='',
                @OnlyRevClass2List varchar(255) ='',
                @OnlyRevClass3List varchar(255) ='',
                @OnlyRevClass4List varchar(255) ='',
                @OnlyMppType1List varchar(255) ='',
                @OnlyMppType2List varchar(255) ='',
                @OnlyMppType3List varchar(255) ='',
                @OnlyMppType4List varchar(255) ='',
                @OnlyTeamLeaderList varchar(255) = '', -- Used to include only selected Team Leaders
                @OnlyTrcClass1List varchar(255) = '',
                @OnlyTrcClass2List varchar(255) = '',
                @OnlyTrcClass3List varchar(255) = '',
                @OnlyTrcClass4List varchar(255) = '',
                @OnlyTrcTerminalList varchar(255) = '',
                @OrderTrailerType1 varchar(255)='',
                @OnlyOriginRegionList varchar(255) ='',
                @OnlyDestinationRegionList varchar(255) ='',
              	@OnlyBookedBy varchar(255) = '', -- Used to include only orders booked by selection
                @OnlyShipperList varchar(128)='',
                @OnlyConsigneeList varchar(128)='',
                @OnlyDriverIDList varchar(128)='',
                @UseDriverLogHoursYN varchar(1) = 'N'
             )

AS

SET NOCOUNT ON

            --Fixed CalcMiles to pull by segment instead of order
            --LBK 4/5/2005
            --Populate default currency and currency date types

        	EXEC PopulateSessionIDParamatersInProc 'Revenue', @MetricCode  
 

            /* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
            <METRIC-INSERT-SQL>

	        EXEC MetricInitializeItem
                        @sMetricCode = 'HoursPerOrder',
                        @nActive = 1,   -- 1=active, 0=inactive.
                        @nSort = 102,   -- Used to determine the sort order that updates should be run.
                        @sFormatText = '',        -- Typically 'PCT' or blank ('').
                        @nNumDigitsAfterDecimal = 2,
                        @nPlusDeltaIsGood = 1,
                        @nCumulative = 0,
                        @sCaption = 'Hours Per Order',
                        @sCaptionFull = 'Hours Per ORder',
                        @sProcedureName = 'Metric_HoursPerOrder',
                        @sCachedDetailYN = '',
                        @nCacheRefreshAgeMaxMinutes = 0,
                        @sShowDetailByDefaultYN = 'N', -- Typically 'N'
                        @sRefreshHistoryYN = '',          -- Typically 'N'
                        @sCategory = '@@NOCATEGORY'

            </METRIC-INSERT-SQL>

            */
            SET NOCOUNT ON
            Declare @currdate datetime
                        

            --Standard Parameter Initialization
            Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
            Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
            Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
            Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
            Set @OnlyMppType1List= ',' + ISNULL(@OnlyMppType1List,'') + ','
            Set @OnlyMppType2List= ',' + ISNULL(@OnlyMppType2List,'') + ','
            Set @OnlyMppType3List= ',' + ISNULL(@OnlyMppType3List,'') + ','
            Set @OnlyMppType4List= ',' + ISNULL(@OnlyMppType4List,'') + ','
            Set @OnlyTrcClass1List= ',' + ISNULL(@OnlyTrcClass1List,'') + ','
            Set @OnlyTrcClass2List= ',' + ISNULL(@OnlyTrcClass2List,'') + ','
            Set @OnlyTrcClass3List= ',' + ISNULL(@OnlyTrcClass3List,'') + ','
            Set @OnlyTrcClass4List= ',' + ISNULL(@OnlyTrcClass4List,'') + ','
            Set @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
            Set @OnlyOriginRegionList= ',' + ISNULL(@OnlyOriginRegionList,'') + ','
            Set @OnlyDestinationRegionList= ',' + ISNULL(@OnlyDestinationRegionList,'') + ','
            Set @OrderStatusList = ',' + ISNULL(@OrderStatusList,'') + ','
            Set @ExcludeOrderStatusList = ',' + ISNULL(@ExcludeOrderStatusList,'') + ','
            Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
            Set @DispatchStatusList = ',' + ISNULL(@DispatchStatusList,'') + ','
            Set @OnlyBookedBy = ',' + ISNULL(@OnlyBookedBy,'') + ','
            Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
            Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
            Set @OrderTrailerType1 = ',' + ISNULL(@OrderTrailerType1,'') + ',' 
            Set @OnlyDriverIDList = ',' + ISNULL(@OnlyDriverIDList,'') + ',' 
            

            Select   l.ord_hdrnumber as [Order Number],
                     'Not Invoiced' as [Invoice Number],
                     l.mov_number as [Move Number],          
                     lgh_startcty_nmstct as [Start City,State],
                     lgh_endcty_nmstct as [End City,State],
                     lgh_startdate as [Start Date],     
                     lgh_enddate as [End Date],       
                     cast((cast(DateDiff(mi,lgh_startdate,lgh_enddate) as float)/60.00) as decimal(20,2)) as [Leg Duration],
                     --[TotalCharge] = IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,Null,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'','','','','','',''),0),
                     --[LineHaulRevenue] = IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,Null,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'Y','','','','','',''),0),                                      
                     --[AccessorialRevenue] = IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,NULL,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'','Y','','','','',''),0),
                     --ISNULL(lgh_carrier,'UNKNOWN') CarrierID,
                     --ISNULL(lgh_tractor,'UNKNOWN') TractorID,
                     ISNULL(lgh_driver1,'UNKNOWN') DriverID
                     --lgh_outstatus as [Dispatch Status],
                     --ord_shipper as Shipper,

            INTO #LegHeader
            FROM  Legheader L (NOLOCK) Left Join OrderHeader O (NOLOCK) On L.ord_hdrnumber = O.ord_hdrnumber
            where    (
                        (@DateType = 'Start' and lgh_startdate >= @DateStart AND lgh_startdate < @DateEnd)
                            Or
                        (@DateType = 'End' And lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd)
                        )
                        AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
                        AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
                        AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
                        AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
                        AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
                        AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
                        AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
                        AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
                        AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminalList) >0)
                        AND (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0)
                        AND (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0)
                        AND (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0)
                        AND (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0)
                        AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( l.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
                        AND (@OnlyOriginRegionList =',,' or CHARINDEX(',' + RTRIM( lgh_Startregion1 ) + ',', @OnlyOriginRegionList) >0)                         
                        AND (@OnlyDestinationRegionList= ',,' or CHARINDEX(',' + RTRIM( lgh_Endregion1 ) + ',', @OnlyDestinationRegionList) >0)                                   
                        AND (@DispatchStatusList =',,' or CHARINDEX(',' + RTRIM( lgh_outstatus ) + ',', @DispatchStatusList) >0)
						AND (@OnlyBookedBy= ',,'  or CHARINDEX(',' + RTRIM( O.ord_bookedby ) + ',', @OnlyBookedBy) >0)         
                        AND (@OnlyShipperList =',,' or CHARINDEX(',' + RTRIM( ord_shipper ) + ',', @OnlyShipperList) >0)
                        AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + RTRIM( ord_consignee ) + ',', @OnlyConsigneeList) >0)                                                                                  
                        AND (@OrderTrailerType1 =',,' or CHARINDEX(',' + RTRIM( O.trl_type1 ) + ',', @OrderTrailerType1) >0)                  
                        AND (@OrderStatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) >0)
                        AND (@ExcludeOrderStatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @ExcludeOrderStatusList) =0)
                        AND (@OnlyDriverIDList =',,' or CHARINDEX(',' + RTRIM( lgh_driver1 ) + ',', @OnlyDriverIDList) >0)
 
            UPDATE #LegHeader
            SET [Invoice Number] = I.ivh_invoicenumber
            FROM invoiceheader I (NOLOCK)
            WHERE [Order Number] = I.ord_hdrnumber
            

            If @UseDriverLogHoursYN        = 'N'
                        Set @ThisCOUNT = (Select sum(isnull([Leg Duration],0.0)) from #Legheader)
            Else
                        Set @ThisCOUNT = ISNULL((     Select sum(on_duty_hrs) 
                                                            from log_driverlogs (nolock) 
                                                            where log_date>= @DateStart AND log_date < @DateEnd
                                                            and mpp_id in (select distinct DriverID from #LegHeader (Nolock))
                                                ),0.0)

            

            Set @ThisTOTAL = (Select count(distinct [Order Number]) from #Legheader)

            SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

            If @ShowDetail=1
            BEGIN
                        Select * from #LegHeader
                        order by [leg duration] desc
            END

            SET NOCOUNT OFF
            
GO
GRANT EXECUTE ON  [dbo].[Metric_HoursPerOrder] TO [public]
GO
