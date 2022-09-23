SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[WatchDog_HPBoard]           
 (  
  @MinThreshold FLOAT = 0,  
  @MinsBack INT = -1440, -- 1 day  
  @TempTableName VARCHAR(255) = '##WatchDogGlobalLateLoads',  
  @WatchName VARCHAR(255)='WatchLateLoads',  
  @ThresholdFieldName VARCHAR(255) = null,  
  @ColumnNamesOnly bit = 0,  
  @ExecuteDirectly bit = 0,  
  @ColumnMode VARCHAR(50) = 'Selected',  
  @AirMPHSpeed float=40,  
  @OnlyRevType1 varchar(255) = '',  
  @OnlyRevType2 varchar(255) = '',  
  @OnlyRevType3 varchar(255) = '',  
  @OnlyRevType4 varchar(255) = '',  
  @ExcludeLastStopYN CHAR(1)='N',  
  @ExcludeFirstStopYN CHAR(1) = 'N',  
  @OnlyStopEventList varchar(255)= '',  
  @ExcludeStopEventList varchar(255)= 'HPL,HLT,DLT,DMT',  
  @ParameterToUseForDynamicEmail varchar(140)='',  
  @BufferMinutes float = 60,  
  @ExcludeRevType1 varchar(255)= '',  
  @ExcludeRevType2 varchar(255)= '',  
  @ExcludeRevType3 varchar(255)= '',  
  @ExcludeRevType4 varchar(255)= '',  
  @AVLOrderHoursOut int = 24,
  @AdjustTimeZones char(1) = 'Y'
  
  )  
        
AS  
  
 SET NOCOUNT ON  
   
 /***************************************************************  
 Procedure Name:    WatchDog_HPBoard  
 Author/CreateDate: David Wilks / 5-9-2006  
 Purpose: Similar to show high priority loads   
  parameters and columns returned are custom to A&R  
  
  
 Revision History:   
 ****************************************************************/  
   
 --Reserved/Mandatory WatchDog Variables  
 Declare @SQL VARCHAR(8000)  
 Declare @COLSQL VARCHAR(4000)  
 --Reserved/Mandatory WatchDog Variables  
   
 --Standard Parameter Initialization  
  
 Set @OnlyRevType1 = ',' + ISNULL(@OnlyRevType1,'') + ','   
 Set @OnlyRevType2 = ',' + ISNULL(@OnlyRevType2,'') + ','   
 Set @OnlyRevType3 = ',' + ISNULL(@OnlyRevType3,'') + ','   
 Set @OnlyRevType4 = ',' + ISNULL(@OnlyRevType4,'') + ','   
 Set @ExcludeRevType1 = ',' + ISNULL(@ExcludeRevType1,'') + ','   
 Set @ExcludeRevType2 = ',' + ISNULL(@ExcludeRevType2,'') + ','   
 Set @ExcludeRevType3 = ',' + ISNULL(@ExcludeRevType3,'') + ','   
 Set @ExcludeRevType4 = ',' + ISNULL(@ExcludeRevType4,'') + ','   
  
 SET @OnlyStopEventList = ',' + ISNULL(@OnlyStopEventList,'') + ','  
 SET @ExcludeStopEventList = ',' + ISNULL(@ExcludeStopEventList,'') + ','  
  
  
 Declare @R TABLE  
 ([Origin Terminal] varchar(6),  
 [Load Number] int,   
 lgh_number int,   
 [Dispatch Status] varchar(6),  
 [Next Stop Scheduled Time] datetime,  
 [Next Stop City and State] varchar(50),  
 [Origin City and State] varchar(50),  
 Shipper varchar(100),  
 [Destination Scheduled Time] datetime, 
 [Destination City and State] varchar(50),  
 [Tractor Number] varchar(8),  
 [Driver Terminal] varchar(6),  
 [Driver Name] varchar(45),  
 [Current Qualcomm Position] varchar(255),  
 [IGN Status] char(1),  
 trc_gps_latitude int,  
 trc_gps_longitude int,  
 trc_gps_date datetime,  
 LghStatus varchar(6),  
 AirMilesToDest int,  
 AirMPHNeeded int,  
 DestCityCode int,  
 LatSecondsOfDestCity int,  
 LongSecondsOfDestCity int,  
 Revtype2 varchar(6),  
 Revtype3 varchar(6),  
 Revtype4 varchar(6),  
 EmailSend varchar(500),
 cty_GMTDelta int,
 cty_DSTApplies char(1)

 )     
  
  
-- retreive all high priority orders that are available, dispatched, or started.  
 Insert @R (   
 [Origin Terminal],  
 [Load Number],   
 lgh_number,   
 [Next Stop Scheduled Time],  
 [Next Stop City and State],
 [Origin City and State],  
 Shipper,  
 [Destination Scheduled Time],
 [Destination City and State],  
 LghStatus,  
 AirMilesToDest,  
 AirMPHNeeded,  
 DestCityCode,  
 LatSecondsOfDestCity,  
 LongSecondsOfDestCity,  
 Revtype2,  
 Revtype3,  
 Revtype4,  
 EmailSend,  
 cty_GMTDelta,
 cty_DSTApplies 

 )  
 Select   
 [Origin Terminal] = t1.ord_revtype1,  
 [Load Number] = t1.ord_number,  
 lgh_number = t2.lgh_number,  
 [Next Stop Scheduled Time] = t3.stp_schdtlatest,  
 [Next Stop City and State]=(select cty_name + ', ' + cty_state from city (NOLOCK) where t3.stp_city=cty_code),  
 [Origin City and State]=(select cty_name + ', ' + cty_state from city (NOLOCK) where lgh_startcity=cty_code),  
 Shipper = (SELECT cmp_name FROM company c (nolock) Where c.cmp_id = t1.ord_shipper),  
 [Destination Scheduled Time] = t4.stp_schdtlatest,  
 [Destination City and State]=(select cty_name + ', ' + cty_state from city (NOLOCK) where t4.stp_city=cty_code),  
 LghStatus=IsNull(lgh_outstatus,'AVL'),  
 AirMilesToDest=convert(float,0),  
 AirMPHNeeded=convert(float,0),  
 DestCityCode=t3.stp_city,  
 LatSecondsOfDestCity=0 ,  
 LongSecondsOfDestCity=0,  
 t1.ord_revtype2,  
 t1.ord_revtype3,  
 t1.ord_revtype4,  
 ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default, default,default,default, default, default, default, ord_originregion1, t1.ord_revtype1, t1.ord_revtype2, t1.ord_revtype3, t1.ord_revtype4, default, default, default, default, default, default, default, default,default,default,default,default,default),'') AS EmailSend, --TeamLeaderEmail  
 0 	cty_GMTDelta,
 null cty_DSTApplies 
  
 From   orderheader t1 (NOLOCK)  
  left join legheader t2 (nolock) on t1.ord_hdrnumber = t2.ord_hdrnumber  
  Left Join stops t3 (NOLOCK) on  t2.lgh_number = t3.lgh_number  and  t1.ord_hdrnumber = t3.ord_hdrnumber
     AND (  
          (@ExcludeFirstStopYN ='Y'   
           AND stp_mfh_sequence = (           
                 SELECT MIN(stops.stp_mfh_sequence)   
                 FROM legheader (NOLOCK), stops (NOLOCK)  
                 WHERE legheader.lgh_number = stops.lgh_number  
                  AND legheader.lgh_number = t2.lgh_number  
                  AND stp_status = 'OPN'   
                  AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)  
                  AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @ExcludeStopEventList) =0)  
                  AND stops.stp_mfh_sequence >1  
                  )  
          )  
         OR  
          (@ExcludeFirstStopYN ='N'   
           AND stp_mfh_sequence = (           
                  SELECT MIN(stops.stp_mfh_sequence)   
                  FROM legheader (NOLOCK), stops (NOLOCK)  
                  WHERE legheader.lgh_number = stops.lgh_number  
                   AND legheader.lgh_number = t2.lgh_number  
                   AND stp_status = 'OPN'   
                   AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)  
                   AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @ExcludeStopEventList) =0)  
                  )  
          )  
         )  
          
        AND (  
          (@ExcludeLastStopYN = 'Y' AND stp_mfh_sequence <> (  
                       SELECT MAX(stops.stp_mfh_sequence)   
                       FROM legheader (NOLOCK), stops (NOLOCK)  
                       WHERE legheader.lgh_number = stops.lgh_number  
                        AND legheader.lgh_number = t2.lgh_number  
                        AND stp_status = 'OPN'   
                        AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)  
                        AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @ExcludeStopEventList) =0)  
                        AND stops.stp_mfh_sequence >1  
                       )  
          )  
          OR @ExcludeLastStopYN <> 'Y'  
         )  
  Left Join stops t4 (NOLOCK) on  t2.lgh_number = t4.lgh_number  and  t1.ord_hdrnumber = t4.ord_hdrnumber
	AND t4.stp_mfh_sequence = (  
                       SELECT MAX(stops.stp_mfh_sequence)   
                       FROM stops (NOLOCK)  
                       WHERE t2.lgh_number = stops.lgh_number  
                        AND t1.ord_hdrnumber = stops.ord_hdrnumber
                        AND (@OnlyStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @OnlyStopEventList) >0)  
                        AND (@ExcludeStopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @ExcludeStopEventList) =0)  
                       )  

 Where t2.lgh_outstatus in ('AVL','PLN','DSP','STD')  
 and IsNull(t1.ord_priority,'UNK') = '1'  
  
  
-- Now add tractor information if trip is started.  
 Update @R   
 Set  
  [Tractor Number] = trc_Number,  
  [Driver Terminal] = IsNull((SELECT mpp_terminal FROM manpowerprofile (NOLOCK) WHERE t2.lgh_driver1 = mpp_id),''),  
  [Driver Name] = IsNull((SELECT mpp_lastfirst FROM manpowerprofile (NOLOCK) WHERE t2.lgh_driver1 = mpp_id),''),  
  [Current Qualcomm Position] = t3.trc_gps_desc,  
  [IGN Status] = (SELECT ckc_vehicleignition FROM checkcall (NOLOCK) WHERE ckc_tractor = t3.trc_number and ckc_date = t3.trc_gps_date),  
  trc_gps_latitude=t3.trc_gps_latitude,  
  trc_gps_longitude=t3.trc_gps_longitude,  
  trc_gps_date=t3.trc_gps_date  
  FROM  @R t1  
  Left Join Legheader_active t2 (NOLOCK) on t1.lgh_number = t2.lgh_number  
  Join tractorprofile t3 (NOLOCK) on t3.trc_pln_lgh = t1.lgh_number AND trc_retiredate>Getdate()   
    
  
 Delete from @r   
  WHERE LghStatus = 'AVL'  
  and DateDiff(hh,GetDate(), [Next Stop Scheduled Time]) > @AVLOrderHoursOut  
  


 Delete from @r   
  WHERE (@OnlyRevType1 >',,' and  CHARINDEX(',' + ISNULL([Origin Terminal],'')  + ',', @OnlyRevType1) =0)  
  OR (@OnlyRevType2 >',,' and  CHARINDEX(',' + ISNULL(RevType2,'')  + ',', @OnlyRevType2) =0)  
  OR (@OnlyRevType3 >',,' and CHARINDEX(',' + ISNULL(RevType3,'')  + ',', @OnlyRevType3) =0)  
  OR (@OnlyRevType4 >',,' and CHARINDEX(',' + ISNULL(RevType4,'')  + ',', @OnlyRevType4) =0)  
  
   
 Delete from @r   
  WHERE (@ExcludeRevType1 >',,' and  CHARINDEX(',' + ISNULL([Origin Terminal],'')  + ',', @ExcludeRevType1) >0)  
  OR (@ExcludeRevType2 >',,' and  CHARINDEX(',' + ISNULL(RevType2,'')  + ',', @ExcludeRevType2) >0)  
  OR (@ExcludeRevType3 >',,' and CHARINDEX(',' + ISNULL(RevType3,'')  + ',', @ExcludeRevType3) >0)  
  OR (@ExcludeRevType4 >',,' and CHARINDEX(',' + ISNULL(RevType4,'')  + ',', @ExcludeRevType4) >0)  
  
  
	If @AdjustTimeZones = 'Y'
	Begin
		declare @OfficeGMTDelta int
		set @OfficeGMTDelta = DATEDIFF(Hour, GETDATE(), GETUTCDATE())

		-- find out if DST is in effect (this will not work if dispatch office is in Arizona)
		declare @ActiveTimeBias int
		declare @Bias int
		exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
		'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
		'ActiveTimeBias', @ActiveTimeBias OUT
		exec master.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
		'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
		'Bias', @Bias OUT

		If @Bias <> @ActiveTimeBias -- DST in affect at this time
			BEGIN
			Update @r 
				Set [Next Stop Scheduled Time] = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, [Next Stop Scheduled Time])
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
				and cty_DSTApplies = 'N'
			SET @OfficeGMTDelta = @OfficeGMTDelta + 1
			Update @r 
				Set [Next Stop Scheduled Time] = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, [Next Stop Scheduled Time])
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
				and cty_DSTApplies = 'Y'
			END
		ELSE   -- DST not in affect at this time 
			Update @r 
				Set [Next Stop Scheduled Time] = DateAdd(Hour, cty_GMTDelta - @OfficeGMTDelta, [Next Stop Scheduled Time])
				Where IsNull(cty_GMTDelta, @OfficeGMTDelta) <>  @OfficeGMTDelta
	END
   
 --Select DateDiff(n,'11/15/04',Getdate())  
 Update @r   
  Set AirMPHNeeded  
  =( convert(float,AirMilesToDest) /  
  (convert(float,DateDiff(n,trc_gps_date, [Next Stop Scheduled Time]))/60.0 ) - @BufferMinutes )  
  Where LghStatus<>'CMP' and AirMilesToDest>1   
  and DateDiff(n,trc_gps_date, [Next Stop Scheduled Time]) - @BufferMinutes > 0  
  
  
  
 SELECT   
 [Origin Terminal],  
 [Load Number],   
 [Dispatch Status]=LghStatus,  
 [Next Stop City and State],
 [Next Stop Scheduled Time],  
 [ETA]= DateAdd(n, (convert(float,AirMilesToDest) / @AirMPHSpeed) * 60, trc_gps_date),  
 [Miles out]= Case when (DateDiff(n,trc_gps_date,GetDate()) / 60) * @AirMPHSpeed > AirMilesToDest  
      Then 0  
      Else  
       AirMilesToDest - (DateDiff(n,trc_gps_date,GetDate()) / 60) * @AirMPHSpeed  
      End,  
 [Origin City and State],  
 Shipper,  
 [Destination Scheduled Time], 
 [Destination City and State],  
 [Tractor Number],  
 [Driver Terminal],  
 [Driver Name],  
 [Current Qualcomm Position],  
 [IGN Status],  
 EmailSend   
  INTO #tempResults FROM @R ORDER BY  [Next Stop Scheduled Time] 
  
 --Commits the results to be used in the wrapper  
 IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1  
 BEGIN  
  SET @SQL = 'SELECT * FROM #TempResults'  
 END  
 ELSE  
 BEGIN  
  SET @COLSQL = ''  
  EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT  
  SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'  
 END  
   
 EXEC (@SQL)  
   
	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[WatchDog_HPBoard] TO [public]
GO
