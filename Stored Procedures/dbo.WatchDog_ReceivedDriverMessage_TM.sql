SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchDog_ReceivedDriverMessage_TM]
	@MinsBack int=-20,
	@FormIdList VARCHAR(255) = NULL  -- This is the TotalMail FormID or Macro Number.
AS

	SET NOCOUNT ON

 	CREATE TABLE #t1 (sn int, DTSent datetime, FormId int, DispSysTruckId VARCHAR(15) null, DispSysDriverID VARCHAR(15) null, msgImage text) 

	SELECT @FormIdList = ',' + ISNULL(@FormIdList, '') + ','

	INSERT INTO #t1 (sn, dtsent, FormId, DispSysTruckId, DispSysDriverID, MsgImage)
	 SELECT t1.sn, dtsent, t4.id, 
	   CASE WHEN t1.FromType = 4 THEN t1.FromName ELSE Null END,  
	   CASE WHEN t1.FromType = 5 THEN t1.FromName ELSE Null END,  
	   t3.MsgImage  
	   FROM tblMessages t1 (nolock)   
	   INNER JOIN tblMsgProperties t2 (nolock) ON t1.sn = t2.msgsn  
	   INNER JOIN tblMsgShareData t3 (nolock) ON t1.sn = t3.OrigMsgSN   
	   INNER JOIN tblSelectedMobileComm t4 (nolock) on t2.Value = t4.FormSn
	   INNER JOIN tblhistory t5 (nolock) on t5.Msgsn = t1.sn
	   WHERE t1.dtsent >= DateAdd(mi,@MinsBack,GetDate())   
	    AND t1.FromType IN (4, 5, 6)     
	    AND t2.PropSN = 2  
	    AND (@FormIdList= ',,' OR CHARINDEX(',' + CONVERT(VARCHAR(10), t4.id) + ',', @FormIdList) > 0)   
 
	-- Attempt to set the Truck and Driver values from history.
	UPDATE #t1
	SET DispSysTruckID = (SELECT DispSysTruckID FROM tblTrucks WHERE sn = t0.TruckSN), 
		DispSysDriverID = (SELECT DispSysDriverID FROM tblDrivers WHERE sn = t0.DriverSN) 
		 	FROM (tblHistory t0 INNER JOIN #t1 ON t0.MsgSn = #t1.sn
				INNER JOIN tblMessages t1 ON #t1.sn = t1.sn 
				INNER JOIN tblMsgProperties t2 ON t1.sn = t2.MsgSN AND t2.PropSN = 2
				INNER JOIN tblForms t3 ON t2.Value = t3.sn)

	-- Third pass at driver values.
	UPDATE #t1 
		SET DispSysDriverID = (SELECT DispSysDriverId FROM tblDrivers WHERE sn = tblTrucks.DefaultDriver)
		FROM #t1 INNER JOIN tblMessages t1 ON #t1.sn = t1.sn 
				 INNER JOIN tblTrucks ON TruckName = t1.FromName
		WHERE IsNull(DispSysDriverID,'')= ''
		AND t1.FromType = 4 
		AND IsNull(DefaultDriver,'') > ''

	SELECT * from #t1 
--WatchDog_ReceivedDriverMessage_TM -500000, ''

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[WatchDog_ReceivedDriverMessage_TM] TO [public]
GO
