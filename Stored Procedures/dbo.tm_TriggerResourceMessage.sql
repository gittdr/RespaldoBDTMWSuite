SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--PTS 40978
-- Adding resource information to the table 'TblSqlMessage' and 'TblSqlMessageData'
CREATE PROCEDURE [dbo].[tm_TriggerResourceMessage]
	@sResourceSN  INT,	
	@sResourceType VARCHAR(3),		--Trc = Truck, Drv = Driver, Trl = Trailer, Mcu = MC Unit, Lgn = Login
	@Flags  VARCHAR(1),			--1 = Add,2 = Edit, 4 = Delete,8 = Retired
	@sOrigName	VARCHAR(50)		-- Old name.

AS

SET NOCOUNT ON 

Declare @FormID VARCHAR(50),
	 @FormSN INT,
	 @FilterData VARCHAR(25),
	 @Subject VARCHAR(25),
	 @ViewCode VARCHAR(20),
	 @MsgID INT,
	 @ViewFieldName VARCHAR(50),
	 @FieldValue VARCHAR(50),
	 @ViewFieldSN INT,
	 @TblName VARCHAR(50),
	 @SeqNo INT,
	 @HolDViewFieldSn INT,
	 @SQLPara AS nVARCHAR(1000),
	 @SQLString AS nVARCHAR(1000),
	 @SubjectPart VARCHAR(15)

IF @Flags = 1
	SET @SubjectPart = 'Creating '
ELSE IF @Flags = 2
	SET @SubjectPart = 'Updating '
ELSE IF @Flags = 4
	SET @SubjectPart = 'Deleting '
ELSE IF @Flags = 8
	SET @SubjectPart = 'Retire '

IF  @sResourceType = 'Trc' 
	BEGIN
		SET @FormID 	= 'ConfigureTruck'
		SET @FilterData = 'TMTruck: ' + CAST(@sResourceSN AS varchar(10))
		SET @Subject = 'Truck' 
		SET @ViewCode = 'TMCNFGTRK'
		SET @TblName = 'TblTrucks'
	END
ELSE IF  @sResourceType = 'Drv' 	
	BEGIN
		SET @FormID 	= 'ConfigureDriver'
		SET @FilterData = 'TMDriver: ' + CAST(@sResourceSN AS varchar(10))
		SET @Subject = 'Driver'
		SET @ViewCode = 'TMCNFGDRV'
		SET @TblName = 'TblDrivers'
	END
ELSE IF  @sResourceType = 'Trl' 
	BEGIN
		SET @FormID 	= 'ConfigureTrailer'
		SET @FilterData = 'TMTrailer: ' + CAST(@sResourceSN AS varchar(10))
		SET @Subject = 'Trailer'
		SET @ViewCode = 'TMCNFGTRL'
		SET @TblName = 'TblTrucks'
	END
ELSE IF  @sResourceType = 'Mcu' 
	BEGIN
		SET @FormID 	= 'ConfigureMCT'
		SET @FilterData = 'TMMCUnit: ' + CAST(@sResourceSN AS varchar(10))
		SET @Subject = 'MC Unit'
		SET @ViewCode = 'TMCNFGMCU'
		SET @TblName = 'TblCabUnits'
	END
ELSE
	BEGIN
		SET @FormID 	= 'ConfigureLogin'
		SET @FilterData = 'TMLogin: ' + CAST(@sResourceSN AS varchar(10))
		SET @Subject = 'Login'
		SET @ViewCode = 'TMCNFGLGN'
		SET @TblName = 'TblLogin'
	END

SET @Subject = @SubjectPart + ' ' + @Subject  

--Get FormID
SET @FormSN = 0
SELECT @FormSN = ISNULL(f.FormID,0) 
FROM TblForms f (NOLOCK), TblSelectedMobileComm s (NOLOCK),  TblMobileCommType T (NOLOCK) 
WHERE f.SN = s.FormSN AND s.ID = @FormID AND s.Status = 'Current' AND s.MobileCommSn = T.sn AND T.MobileCommType = 'TotalMail'

IF @FormSN = 0 OR LEN(@FormSN) = 0
	RETURN

BEGIN TRANSACTION T1

--Insert message in TblSqlMessage
INSERT INTO TblSqlMessage (msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_From, msg_FromType, msg_Subject)
VALUES (GETDATE(), @FormSN, 'V:TotalMail', 0, @FilterData, 5, 'Admin', 1, @Subject)

IF ISNULL(@@ERROR,0) <> 0 
	BEGIN
		ROLLBACK TRANSACTION T1
		RETURN
	END

SET @MsgID = @@IDENTITY
SET @ViewFieldSN = 0
SET @SeqNo = 0

SELECT TOP 1 @ViewFieldName =ISNULL( f.FieldName,''), @ViewFieldSN = ISNULL(f.SN,0)  
FROM TblViewFields f  (NOLOCK), TblViews v (NOLOCK)  
WHERE v.ViewCode = @ViewCode AND v.SN = f.ViewNumber AND f.Sn > @ViewFieldSN ORDER BY f.SN

IF ISNULL(@@ERROR,0) <> 0 
	BEGIN
		ROLLBACK TRANSACTION T1
		RETURN
	END


WHILE  (@ViewFieldSN <> 0)
	BEGIN
		SET @HolDViewFieldSn = @ViewFieldSN
		SET @ViewFieldSN = 0
		SET @FieldValue = ''		
		SET @SeqNo = @SeqNo + 1


		IF @ViewFieldName = 'OriginalResourceName'	
			BEGIN
				--Insert flag value in TblSqlMessageData
				INSERT INTO TblSqlMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				VALUES (@MsgID, @SeqNo,@ViewFieldName,@sOrigName)		
	
				if ISNULL(@@ERROR,0) <> 0 
					BEGIN
						ROLLBACK TRANSACTION T1
						RETURN
					END
			END

		ELSE IF @ViewFieldName = 'Flags'  
			BEGIN
				--Insert flag value in TblSqlMessageData
				INSERT INTO TblSqlMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
				VALUES (@MsgID, @SeqNo,'Flags',@Flags)
	
				IF ISNULL(@@ERROR,0) <> 0 
					BEGIN
						ROLLBACK TRANSACTION T1
						RETURN
					END
			END

		ELSE 
			BEGIN
				IF EXISTS (SELECT * 
							FROM syscolumns a, sysobjects b 
							WHERE a.name = @ViewFieldName AND a.id = b.id AND b.name = @TblName)
					BEGIN
						SET @SQLPara = N'@pFieldValue VARCHAR(50) output, @psResourceSN  INT'
						SET @SQLString = N'SELECT @pFieldValue =ISNULL( ' + @ViewFieldName + ','''')  FROM ' + @TblName + ' (NOLOCK) ' + ' WHERE SN = @psResourceSN'
						EXECUTE sp_executesql  @SQLString, @SQLPara, @pFieldValue = @FieldValue output,@psResourceSN = @sResourceSN

						IF ISNULL(@@ERROR,0) <> 0 
							BEGIN
								ROLLBACK TRANSACTION T1
								RETURN
							END

						--Insert message in TblSqlMessageData
						INSERT INTO TblSqlMessageData (msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
						VALUES (@MsgID, @SeqNo,@ViewFieldName, @FieldValue)

						IF ISNULL(@@ERROR,0) <> 0 
							BEGIN
								ROLLBACK TRANSACTION T1
								RETURN
							END
					 END
			END

		SELECT TOP 1 @ViewFieldName =ISNULL( f.FieldName,''), @ViewFieldSN = ISNULL(f.SN,0)  
		FROM TblViewFields f (NOLOCK), TblViews v (NOLOCK)  
		WHERE v.ViewCode = @ViewCode AND v.SN = f.ViewNumber AND f.Sn > @HolDViewFieldSn ORDER BY f.SN

		if ISNULL(@@ERROR,0) <> 0 
			BEGIN
				ROLLBACK TRANSACTION T1
				RETURN
			END

	END

COMMIT TRANSACTION T1
GO
GRANT EXECUTE ON  [dbo].[tm_TriggerResourceMessage] TO [public]
GO
