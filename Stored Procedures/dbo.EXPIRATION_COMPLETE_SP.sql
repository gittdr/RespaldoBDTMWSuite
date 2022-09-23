SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS
--- VERSION 11.20.00 SQL SCRIPT
--- TMWSuite1120_Script1.sql
--- CHANGED 02/08/2007 MB
--- CHANGED 09/08/2006 MB
----------------------------------
CREATE PROC [dbo].[EXPIRATION_COMPLETE_SP]
        @EXP_KEY INT,
        @EXP_COMPLDATE DATETIME = NULL,
  @EXP_ORDERID INT = NULL 

AS
BEGIN
	DECLARE @DEBUG INTEGER
	SET @DEBUG = 0	-- 0 = Off, 1 = On

	IF @DEBUG = 1 Print 'EXPIRATION_COMPLETE_SP'
	
	IF ISNULL(@EXP_KEY, -1) = -1 AND @EXP_ORDERID IS NOT NULL
		SELECT @EXP_KEY = MIN(EXP_KEY) FROM TMT_EXPIRATIONS WHERE EXP_ORDERID = @EXP_ORDERID AND EXP_COMPLETED = 'N' AND EXP_CODE = 'INSHOP' 
	
	IF ISNULL(@EXP_KEY, -1) = -1	-- INVALID KEY, RETURN
		RETURN 
	
    DECLARE @CURRENTDATE DATETIME
    SET @CURRENTDATE = GETDATE()
    
    IF ISNULL(@EXP_COMPLDATE,'01/01/1901 00:00:00') > DATEADD ( yyyy , 1, @CURRENTDATE ) 
        BEGIN
            SET @EXP_COMPLDATE = @CURRENTDATE
        END
    
    
    IF ISNULL(@EXP_COMPLDATE,'01/01/1901 00:00:00') <> '01/01/1901 00:00:00'
    BEGIN
        IF DATEPART(HH, @EXP_COMPLDATE) = 0 AND DATEPART(MI,@EXP_COMPLDATE) = 0
            BEGIN
                        SELECT @EXP_COMPLDATE = @EXP_COMPLDATE + '23:59:59'
            END
    
        UPDATE [dbo].[EXPIRATION] 
        SET [EXP_COMPLDATE] = @EXP_COMPLDATE,
            [EXP_COMPLETED]='Y',
			[exp_updateby]	= 'AMS Interface',
			[exp_updateon]	= GetDate()
        WHERE [EXP_KEY] = @EXP_KEY
        
        UPDATE TMT_Expirations 
        SET [EXP_COMPLDATE] = @EXP_COMPLDATE,
            [EXP_COMPLETED]='Y'
        WHERE [EXP_KEY] = @EXP_KEY
    END
    
    IF NOT ISNULL(@EXP_ORDERID,0) = 0 
    BEGIN
        SET @EXP_COMPLDATE = GETDATE()
        IF DATEPART(HH, @EXP_COMPLDATE) = 0 AND DATEPART(MI,@EXP_COMPLDATE) = 0
            BEGIN
                        SELECT @EXP_COMPLDATE = @EXP_COMPLDATE + '23:59:59'
            END
    
        UPDATE [dbo].[EXPIRATION] 
        SET [EXP_COMPLDATE] = @EXP_COMPLDATE,
            [EXP_COMPLETED] = 'Y',
			[exp_updateby]	= 'AMS Interface',
			[exp_updateon]	= GetDate()
                              
		WHERE [EXP_KEY] in (select EXP_KEY from TMT_Expirations where EXP_ORDERID = @EXP_ORDERID)
        --WHERE PATINDEX('%OrderID '+CAST(@EXP_ORDERID as VARCHAR)+'%', [EXP_DESCRIPTION])= 1
        update TMT_Expirations
        SET [EXP_COMPLDATE] = @EXP_COMPLDATE,
                              [EXP_COMPLETED] = 'Y'
		WHERE EXP_ORDERID = @EXP_ORDERID
    END
    ELSE
        BEGIN
            UPDATE [dbo].[EXPIRATION] 
				SET [EXP_COMPLETED]= 'Y',
				[exp_updateby]	= 'AMS Interface',
				[exp_updateon]	= GetDate()
				WHERE [EXP_KEY]=@EXP_KEY
			UPDATE TMT_Expirations
				SET [EXP_COMPLETED] = 'Y'
				WHERE [EXP_KEY]=@EXP_KEY
        END
    
    EXEC [dbo].[TRC_EXPSTATUS] @EXP_KEY
END
GO
GRANT EXECUTE ON  [dbo].[EXPIRATION_COMPLETE_SP] TO [public]
GO
