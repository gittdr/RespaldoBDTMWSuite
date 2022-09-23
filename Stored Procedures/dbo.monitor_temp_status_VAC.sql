SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[monitor_temp_status_VAC] AS

DECLARE 
	  @type		char(3)
	, @id		varchar(13)
	, @key		int
	, @now		datetime
	, @code		char(6)

--SELECT	  @now = GetDate()
	--, @code = gi_string1
--FROM	  generalinfo
--WHERE	  gi_name = 'TempHoldCode'

Select @now = GetDate()
Select @code = 'VAC'

IF @code IS NULL
	RETURN

--DPH PTS 23645
DECLARE @asset1 VARCHAR(3),
	@asset2 VARCHAR(3),
	@asset3 VARCHAR(3)

SELECT  @asset1 = gi_string2,
	@asset2 = gi_string3,
	@asset3 = gi_string4
FROM 	generalinfo
WHERE	gi_name = 'TempHoldCode'
--DPH PTS 23645

DECLARE find_hold CURSOR FOR 
SELECT 	exp_key, exp_idtype, exp_id
FROM	expiration
WHERE	exp_code = @code
  AND	exp_compldate < @now
  AND   exp_completed <> 'Y'

OPEN find_hold
FETCH NEXT FROM find_hold
INTO @key, @type, @id
WHILE @@FETCH_STATUS = 0

BEGIN
	--DPH PTS 23645
	IF @type = 'TRC' and ((@asset1 = 'TRC' or @asset2 = 'TRC' or @asset3 = 'TRC') or 
				(@asset1 = '' and @asset2 = '' and @asset3 = ''))
	BEGIN
		UPDATE 	expiration
		SET	exp_completed = 'Y'
		WHERE	exp_key = @key
		EXEC 	trc_expstatus @id
	END
	ELSE IF @type = 'DRV' and ((@asset1 = 'DRV' or @asset2 = 'DRV' or @asset3 = 'DRV') or 
				(@asset1 = '' and @asset2 = '' and @asset3 = ''))
	BEGIN
		UPDATE 	expiration
		SET	exp_completed = 'Y'
		WHERE	exp_key = @key
		EXEC 	drv_expstatus @id
	END
	ELSE IF @type = 'TRL' and ((@asset1 = 'TRL' or @asset2 = 'TRL' or @asset3 = 'TRL') or 
				(@asset1 = '' and @asset2 = '' and @asset3 = ''))
	BEGIN
		UPDATE 	expiration
		SET	exp_completed = 'Y'
		WHERE	exp_key = @key
		EXEC 	trl_expstatus @id
	END
	/* PTS12130 MBR 10/10/01 */
	ELSE IF @type = 'CAR' and ((@asset1 = 'CAR' or @asset2 = 'CAR' or @asset3 = 'CAR') or 
				(@asset1 = '' and @asset2 = '' and @asset3 = ''))
	BEGIN
		UPDATE 	expiration
		SET	exp_completed = 'Y'
		WHERE	exp_key = @key
		EXEC 	car_expstatus @id
	END
	--DPH PTS 23645
    	FETCH NEXT FROM find_hold
	INTO @key, @type, @id

END

CLOSE find_hold
DEALLOCATE find_hold

GO
