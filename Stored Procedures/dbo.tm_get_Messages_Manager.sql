SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_get_Messages_Manager]	
					@LoginSN int,
					@LoginInboxSN int,
					@TruckSN int,
					@DriverSN int,
					@MessageSN int,
					@MessageSNType int,
					@FolderSN int,
					@sDispatchKey1 varchar(20),
					@sDispatchKey2 varchar(20),
					@sDispatchKeyType varchar(10),
					@FormID int,
					@MaxMessages int,
					@FromDate datetime,
					@ToDate datetime,
					@RetrievalDateToUse varchar(20),
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20),
					@ErroredMessagesOnly varchar(1),
					@FormIDFilter INT,
					@LastTimeStamp datetime,
					@NewTimeStamp datetime OUT,
					@ExportedFlag varchar(1)=NULL,
					@Flags varchar(12)=NULL
AS
DECLARE @Temp datetime,
		@iFlags int
  
SET NOCOUNT ON  
 
SET @iFlags = CONVERT(int, ISNULL(@Flags,'0'))

-- Get Last delivery datetime from tbllogin for this user  
SELECT @Temp = ISNULL(LastTMDlvry, '19510101') FROM tblLogin  
 WITH (NOLOCK)  
 WHERE SN = @LoginSN   
  
-- Convert to get rid of milliseconds  
SELECT @NewTimeStamp = CONVERT(varchar(20), @Temp, 107) + ' ' + CONVERT(varchar(20), @Temp, 108)  
  
-- If no new messages have been delivered, just exit  
IF @NewTimeStamp !> @LastTimeStamp  
 RETURN  
  
  
--CREATE TABLE #T2 ( DTSent datetime NULL, SN int )   
CREATE TABLE #T2 (SN int )   
CREATE TABLE #T3 (SN int )   
  
INSERT #T2 EXECUTE dbo.tm_get_Messages_Manager_help @LoginSN,   
             @LoginInboxSN,   
             @TruckSN,  
             @DriverSN,  
             @MessageSN,  
             @MessageSNType,  
             @FolderSN,  
             @sDispatchKey1,  
             @sDispatchKey2,  
             @sDispatchKeyType,  
             @FormID,  
             @MaxMessages,   
             @FromDate,   
             @ToDate,   
             @RetrievalDateToUse,   
             @OrderByDate,  
             @OrderByDateOrder,  
             @ErroredMessagesOnly,  
             @FormIDFilter,  
             @ExportedFlag,
			 @Flags  
 
IF (@iFlags & 1 = 1) AND ISNULL(@MessageSN,0) = 0
	INSERT #T3 EXECUTE dbo.tm_get_Positions_Manager_help @TruckSN,  
				 @DriverSN,  
				 NULL,  
				 NULL,  
				 @MaxMessages,   
				 @FromDate,   
				 @ToDate,   
				 'DateAndTime',  
				 @OrderByDateOrder,  
				 NULL  

-- Go collect and return the data.  
SELECT DISTINCT   
  tblMessages.SN,  
  tblMessages.Type Type,  
  tblMessages.DeliverToType,   
  tblMessages.DeliverTo,   
  tblMessages.Status AS Status,    
  tblMessages.Priority,  
  tblMessages.FromName AS ToFrom,   
  tblMessages.FromType,     
  tblMessages.OrigMsgSN,     
  tblMessages.Folder,  
  tblMessages.Subject AS Subject,     
  tblMessages.DTReceived AS SentReceived,   
  tblMessages.DTSent,   
  tblMessages.DTAcknowledged,  
  tblMessages.DTTransferred,  
  tblMessages.HistDrv,  
  tblMessages.HistDrv2,  
  tblMessages.HistTrk,  
  tblMessages.Receipt,  
  tblMessages.DeliveryKey,  
  tblMessages.Position,  
  tblMessages.PositionZip,  
  tblMessages.NLCPosition,  
  tblMessages.NLCPositionZip,  
  tblMessages.VehicleIgnition,  
  tblMessages.Latitude,  
  tblMessages.Longitude,  
  tblMessages.DTPosition,  
  tblMessages.SpecialMsgSN,  
  tblMessages.ResubmitOF,  
  tblMessages.Odometer,   
  tblMessages.ReplyMsgSN,   
  tblMessages.ReplyMsgPage,   
  tblMessages.ReplyFormID,   
  tblMessages.ReplyPriority,   
  tblMessages.ToDrvSN,   
  tblMessages.ToTrcSN,   
  tblMessages.FromDrvSN,   
  tblMessages.FromTrcSN,   
  tblMessages.MaxDelayMins,  
  tblMessages.BaseSN,  
  tblMessages.Export,  
  tblMessages.MCUID,  
  DATALENGTH(tblMessages.Contents) AS Size,   
  CONVERT(VARCHAR(8000), tblMessages.Contents) AS Text,   
  CONVERT(VARCHAR(255),tblMsgShareData.MsgImage) AS Preview,   
  tblMessages.DTRead as DTRead,   
  tblMsgShareData.ReadByName,   
  tblMsgProperties.Value as ErrListID,  
  tblForms.FormId,  
  tblForms.Version,  
  CASE WHEN tblAttachments.SN > 0 THEN 1 ELSE 0 END AS Attachment,     
  p2.Value as FormSN,  
  CASE WHEN ISNULL(p2.Value, 0) = 0 THEN   
  CASE WHEN ISNULL(tblMessages.SpecialMsgSN, 0) = 0 THEN 'Text' ELSE 'Special Message' END   
 ELSE 'Form' END AS MessageType  
FROM #T2    
WITH (NOLOCK)  
  INNER JOIN (tblMsgProperties (NOLOCK)  
    RIGHT JOIN  (tblMessages (NOLOCK)  
     LEFT JOIN tblMsgShareData (NOLOCK) ON tblMessages.OrigMsgSN = tblMsgShareData.OrigMsgSN  
     LEFT JOIN tblMsgProperties p2 (NOLOCK) ON p2.MsgSN = tblMessages.SN AND p2.PropSN = 2  
     LEFT JOIN tblForms (NOLOCK) ON p2.Value = tblForms.SN  
    LEFT JOIN tblAttachments (NOLOCK)  
   ON tblMessages.SN = tblAttachments.Message)  
  ON (tblMsgProperties.MsgSN = tblMessages.SN AND tblMsgProperties.PropSN = 6) )   
ON tblMessages.SN = #T2.SN 
   
UNION  

SELECT -tblLatLongs.SN,  --Negative so that we do not get confused with message SNs
   99 [Type],  --No msg type for positions, make it 99  
   tblcabunits.LinkedAddrType DeliverToType,  --No msg type for positions, make it 99  
   CASE tblcabunits.LinkedAddrType WHEN 5 THEN tbldrivers.Name WHEN 4 THEN tblTrucks.TruckName ELSE tblCabUnits.UnitID END DeliverTo,  
   4 [Status], --No msg status for position, make it ack (4)  
   2 [Priority], --No msg priority for positions, make it med (2)  
   CASE tblcabunits.LinkedAddrType WHEN 5 THEN tbldrivers.Name WHEN 4 THEN tblTrucks.TruckName ELSE tblCabUnits.UnitID END ToFrom,  
   tblcabunits.LinkedAddrType FromType,  --No msg type for positions, make it 99  
   -tblLatLongs.SN [OrigMsgSN],  
   0 Folder, --No msg folder for positions, make it 0  
   tblLatLongs.Remark + ' | Motion = ' + CONVERT(VARCHAR(MAX), ISNULL(tblLatLongs.TripStatus, '-1')) Subject,  
   tblLatLongs.DateAndTime SentReceived,  
   tblLatLongs.DateAndTime DTSent,  
   tblLatLongs.DateAndTime DTAcknowledged,  
   tblLatLongs.DateAndTime DTTransferred,  
   ISNULL(tblDrivers.SN, 0) HistDrv,   
   0 HistDrv2,  
   ISNULL(tblTrucks.SN, 0) HistTrk,  
   1 Receipt,  
   tblLatLongs.[STATUS] DeliveryKey,  --Use DeliverKey for the status
   tblLatLongs.Remark Position,  
   tblLatLongs.Zip PositionZip,   
   tblLatLongs.NearestLargeCityName NLCPosition,   
   tblLatLongs.NearestLargeCityZip NLCPositionZip,   
   tblLatLongs.VehicleIgnition VehicleIgnition,  
   tblLatLongs.Lat Latitude,  
   tblLatLongs.Long Longitude,  
   tblLatLongs.DateAndTime DTPosition,  
   0 SpecialMsgSN,  
   0 ResubmitOF,  
   tblLatLongs.Odometer,   
   tblLatLongs.AssociatedMsgSN ReplyMsgSN,   
   1 ReplyMsgPage,  
   0 ReplyFormID,  
   0 ReplyPriority,  
   0 ToDrvSN,  
   0 ToTrcSN,  
   ISNULL(tblDrivers.SN, 0) FromDrvSN,  
   ISNULL(tblTrucks.SN, 0) FromTrcSN,  
   0 MaxDelayMins,  
   0 BaseSN,  
   0 Export,  
   tblCabUnits.UnitID MCUID,  
   DATALENGTH(tblLatLongs.Remark) AS Size,   
   tblLatLongs.Remark Text,  
   tblLatLongs.[StatusReason] Preview,  
   tblLatLongs.DateAndTime DTRead,  
   '' ReadByName,  
   0 ErrListID,  
   0 FormId,  
   0 Version,  
   0 Attachment,  
   0 FormSN,  
   'Position' MessageType  
FROM #T3    
	WITH (NOLOCK)  
	INNER JOIN tblLatlongs (NOLOCK) ON #T3.SN = tblLatlongs.SN   
	INNER JOIN tblCabUnits (NOLOCK) on tbllatlongs.Unit = tblCabUnits.SN  
	LEFT JOIN tblDrivers (NOLOCK) on tblcabunits.LinkedObjSN = tblDrivers.SN AND tblcabunits.LinkedAddrType = 5
	LEFT JOIN tblTrucks (NOLOCK) on tblcabunits.LinkedObjSN = tblTrucks.SN AND tblcabunits.LinkedAddrType = 4
WHERE (@iFlags & 1 = 1) AND ISNULL(@MessageSN,0) = 0 AND (ISNULL(@ErroredMessagesOnly, 0) = 0 OR ((tblLatLongs.[STATUS] & 2048) <> 0))
ORDER BY DTSent DESC  

GO
GRANT EXECUTE ON  [dbo].[tm_get_Messages_Manager] TO [public]
GO
