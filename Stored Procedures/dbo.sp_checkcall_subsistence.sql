SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_checkcall_subsistence]
		(				
			@ckc_asgntype varchar(6),
			@ckc_asgnid varchar(13),
			@ckc_Date datetime			-- checkcall date
		)

AS

/* REVISION HISTORY:
 * 10/01/2012	 - PTS64388 - APC - created - to calculate subsistence qualification and set flags in dbo.checkcall and dbo.DriverSubsistence
*/

DECLARE	
	@RowCounter INT,
	@ckc_number int,
	@ckc_latseconds float,		-- checkcall latitude
	@ckc_longseconds float		-- checkcall longitude

	CREATE TABLE #tmpCheckcall(
		_ID smallint Primary KEY IDENTITY(0,1), tmp_ckc_number INT, 
		tmp_ckc_latseconds INT, tmp_ckc_longseconds INT 
	)

	INSERT INTO #tmpCheckcall
		(
		  tmp_ckc_number ,
		  tmp_ckc_latseconds ,
		  tmp_ckc_longseconds 
		)
		SELECT	ckc_number,
				ISNULL(ckc_latseconds, -1), 
				ISNULL(ckc_longseconds, -1)
		FROM	dbo.checkcall	(NOLOCK)
		WHERE	(ckc_asgntype = @ckc_asgntype) AND (ckc_asgnid = @ckc_asgnid) AND DATEDIFF(D,ckc_date,@ckc_date) = 0
		ORDER BY ckc_date;

	SET @RowCounter = 1;

	WHILE EXISTS(SELECT COUNT(*) FROM #tmpCheckcall HAVING COUNT(*) >= @RowCounter)
		BEGIN
			SELECT	@ckc_number = tmp_ckc_number,
					@ckc_latseconds = ISNULL(tmp_ckc_latseconds, -1), 
					@ckc_longseconds = ISNULL(tmp_ckc_longseconds, -1)
			FROM    #tmpCheckcall
			WHERE	[_ID] = @RowCounter - 1;

			-- convert seconds to degrees
			IF @ckc_latseconds <> -1 AND @ckc_longseconds <> -1
				BEGIN
					set @ckc_latseconds = @ckc_latseconds / 3600
					set @ckc_longseconds = @ckc_longseconds / 3600

					EXEC sp_checkcall_subsistence_calculation @ckc_asgnid, @ckc_number, @ckc_latseconds, @ckc_longseconds, @ckc_Date, @ckc_asgntype
				END			
			-- Increment Loop Counter
			SET @RowCounter = @RowCounter + 1		
		END
	
	DROP TABLE #tmpCheckcall;
GO
GRANT EXECUTE ON  [dbo].[sp_checkcall_subsistence] TO [public]
GO
