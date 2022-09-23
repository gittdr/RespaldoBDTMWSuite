SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_Get_CheckCall]
		@iCheckCallNumber INT,			--1
		@sTruck VARCHAR(30),			--2
		@sDriver VARCHAR(20),			--3
		@sTrailer VARCHAR(20),			--4
		@iPreviousCount INT,			--5
		@dteDateAndTime DATETIME,		--6
		@iFlags INT						--7
		
AS

-- =============================================================================
-- Stored Proc: [dbo].[tmail_Get_CheckCall]
-- Author     :	Gudat, David
-- Create date: 2009
-- Description:
--      This procedure will retrieve the checkcall table record(s) for the input 
--      parameters supplied.
--      
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @iCheckCallNumber 	INT
--		002 - @sTruck 				NVARCHAR(30)
--		003 - @sDriver 				NVARCHAR(20)
--		004 - @sTrailer 			NVARCHAR(20)
--		005 - @iPreviousCount 		INT
--		006 - @sDateAndTime 		NVARCHAR(30)
--		007 - @sFlags 				VARCHAR(12)
--
--      Outputs:
--      ------------------------------------------------------------------------
--		001 - none
--  ============================================================================
--	Modification Log:
--  ----------------------------------------------------------------------------
--	2009        Gudat  Created.
--  2013-05-31  VMS    PTS 68616 - Modifications made for process optimization
--                     - Added (NOLOCK) and extended sp_execSQL command parameters.
--	2013-07-24	RRS		PTS 69912 - Enhancements made for performance (with Mindy)
--	2014-09-19  APC    PTS 82185 - fix made for trailer-only checkcalls
--  ============================================================================
/*
Used for testing proc
Exec tmail_Get_Checkcall 
		/* @iCheckCallNumber */ 0, 
		/* @sTruck           */ '', 
		/* @sDriver          */ '', 
		/* @sTrailer         */ 'SOMETRUCK', 
		/* @iPreviousCount   */ 1, 
		/* @dteDateAndTime     */ '05/31/2013 11:00:00', 
		/* @sFlags           */ ''
*/
-- =============================================================================

DECLARE @ExecSQL nvarchar(2000),
		@ParmDef nvarchar(2000),
		@sAnd	VARCHAR(5)
		
SET @sAnd = ''

IF ISNULL(@iCheckCallNumber,0) = 0
	SET @iCheckcallNumber = 0

IF ISNULL(@iPreviousCount, 0) = 0
	SET @iPreviousCount = 1

IF ISNULL(@sTruck, '') = ''
	SET @sTruck = ''

IF ISNULL(@sDriver, '') = ''
	SET @sDriver = ''

IF ISNULL(@sTrailer, '') = ''
	SET @sTrailer = ''

IF ISDATE(@dteDateAndTime) = 0
	BEGIN
		RAISERROR('tmail_Get_CheckCall:Date and Time passed in must be a valid date and time.', 16, 1)
		RETURN
	END

IF @sTruck = '' AND @sDriver ='' AND @sTrailer = '' AND @iCheckCallNumber = 0  
	BEGIN
		RAISERROR('tmail_Get_CheckCall:Resource or Check call Number must be passed in', 16, 1)
		RETURN
	END

--------------------------------------------------------------------------------
SET @ExecSQL = ''

SET @ExecSQL = 'SELECT TOP(@iPreviousCount) '
SET @ExecSQL = @ExecSQL + 'ckc_number, 
		ckc_status, 
		ckc_asgntype, 
		ckc_asgnid,	
		ckc_date, 
		ckc_event, 
		ckc_city, 
		ckc_comment, 
		ckc_updatedby, 
		ckc_updatedon,
		ckc_latseconds, 
		ckc_longseconds, 
		ckc_lghnumber, 
		ckc_tractor, 
		ckc_extsensoralarm, 
		ckc_vehicleignition, 
		ckc_milesfrom, 
		ckc_directionfrom, 
		ckc_validity, 
		ckc_mtavailable, 
		ckc_minutes, 
		ckc_mileage, 
		ckc_home, 
		ckc_cityname, 
		ckc_state, 
		ckc_zip, 
		ckc_commentlarge, 
		ckc_minutes_to_final, 
		ckc_miles_to_final, 
		ckc_Odometer, 
		TripStatus, 
		ckc_odometer2, 
		ckc_speed, 
		ckc_speed2, 
		ckc_heading, 
		ckc_gps_type, 
		ckc_gps_miles, 
		ckc_fuel_meter, 
		ckc_idle_meter, 
		ckc_AssociatedMsgSN
	FROM CheckCall (NOLOCK)
	WHERE '

	IF @iCheckCallNumber > 0
		BEGIN
			SET @ExecSQL = @ExecSQL + 'ckc_number = @iCheckCallNumber '
		END  
	ELSE
		BEGIN
			SET @ExecSQL = @ExecSQL + ' (ckc_date < @dteDateAndTime) '
			SET @sAND = ' AND '

			IF @sTruck > ''
				BEGIN
					SET @ExecSQL = @ExecSQL + ' AND ckc_tractor = @sTruck '					
				END              
			IF @sDriver > '' AND @sTrailer = ''
			--Driver and NO Trailer:
				BEGIN
					SET @ExecSQL = @ExecSQL + @sAND + ' ckc_asgnid = @sDriver AND ckc_asgntype = ''DRV'' '
				END
			IF @sTrailer > '' AND @sDriver = ''
			--Trailer and NO Driver
				BEGIN
					SET @ExecSQL = @ExecSQL + @sAND + ' ckc_asgnid = @sTrailer AND ckc_asgntype = ''TRL'' '
				END
			IF @sTrailer > '' AND @sDriver > ''
			--Trailer and Driver
				BEGIN
					SET @ExecSQL = @ExecSQL + @sAND + ' (ckc_asgnid = @sTrailer AND ckc_asgntype = ''TRL'') OR '
					SET @ExecSQL = @ExecSQL + ' (ckc_asgnid = @sDriver AND ckc_asgntype = ''DRV'') '
				END
                
			SET @ExecSQL = @ExecSQL + ' ORDER BY ckc_date DESC '
		END

SET @ParmDef = N'@iCheckCallNumber int, @iPreviousCount int, @dteDateAndTime DATETIME, @sTruck varchar(20), @sDriver varchar(20), @sTrailer varchar(20)'
EXEC sp_executeSQL @ExecSQL,
                   @ParmDef,
				   @iCheckCallNumber = @iCheckCallNumber,
                   @iPreviousCount = @iPreviousCount,
                   @dteDateAndTime = @dteDateAndTime,
                   @sTruck = @sTruck,
                   @sDriver = @sDriver,
                   @sTrailer = @sTrailer

GO
GRANT EXECUTE ON  [dbo].[tmail_Get_CheckCall] TO [public]
GO
