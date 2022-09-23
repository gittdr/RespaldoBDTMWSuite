SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	
CREATE Procedure [dbo].[SubsistenceQualificationFilteredByAirmilesAndALKCLR]
(
	@ThresholdRadius FLOAT,
	@AirMiles FLOAT,
	@homeTerminal_lat FLOAT,
	@homeTerminal_long FLOAT,
	@checkcall_lat FLOAT,
	@checkcall_long FLOAT,
	@subsistence_Qualified CHAR(1) OUT	
)

AS

/**
 * 
 * NAME:
 * dbo.SubsistenceQualificationFilteredByAirmilesAndALKCLR
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * compare airmiles to threshold, and call ALKCLR to get route mileage if necessary
 *
 * RETURNS:
 * @subsistence_Qualified CHAR(1)
 * 
 * PARAMETERS:
 *	@ThresholdRadius FLOAT,
 *	@AirMiles FLOAT,
 *	@homeTerminal_lat FLOAT,
 *	@homeTerminal_long FLOAT,
 *	@checkcall_lat FLOAT,
 *	@checkcall_long FLOAT,
 *	@subsistence_Qualified CHAR(1) OUT
 *
 * HISTORY: 
 * 2013-08-14 - APC - Created procedure tmail_FilterSubsistenceByAirmilesForALKMileage for TotalMail SVN
 * 2013-10-16 - APC - renamed proc for .NetOps SVN to supplant totalmail proc, Added GI switch
 **/

--- @subsistence_Qualified values:
-- 'Y' - subsistence qualified
-- 'N' - not subsistence qualified

BEGIN
	DECLARE @LowThreshold FLOAT,
			@RouteDistance FLOAT,
			@sql NVARCHAR(800),
			@gi_ALKCLR VARCHAR(60),
			@gi_ALKCLRProc VARCHAR(60),
			@ParmDefinition NVARCHAR(300)
				
	IF @ThresholdRadius = 0 BEGIN	
		-- ZERO THRESHOLD : subsistence qualified 
		SET @subsistence_Qualified = 'Y';
	END
	ELSE BEGIN		
		IF @AirMiles >= @ThresholdRadius BEGIN	
			-- GREATER THAN THRESHOLD : subsistence qualified
			SET @subsistence_Qualified = 'Y';
		END
		ELSE BEGIN				
			SET @LowThreshold = @ThresholdRadius / 2;
			
			-- LESS THAN THRESHOLD
			IF @AirMiles < @LowThreshold BEGIN
					-- LESS THAN Low Threshold : not subsistence qualified
					SET @subsistence_Qualified = 'N';
			END
			ELSE BEGIN
				-- Airmiles GREATER THAN Low Threshold & Airmiles LESS THAN THRESHOLD : 
				-- if GI setting is on, calculate by ALK for route mileage, else subsistence not qualified			
				SELECT @gi_ALKCLR = UPPER(ISNULL(gi_string1,'N')), @gi_ALKCLRProc = ISNULL(gi_string2,'')
					FROM generalinfo
					WHERE gi_name = 'ALKCLRinsteadofdefaultAirMiles'			

				IF @gi_ALKCLR = 'Y' BEGIN
					SET @sql = N'EXEC ' + @gi_ALKCLRProc + 'sp_CalcALKRouteMileage ' +
										'@homeTerminal_lat,
										 @homeTerminal_long,
										 @checkcall_lat,
										 @checkcall_long,
										 @RouteDistance OUT'
								 					
					SET @ParmDefinition=N'@homeTerminal_lat FLOAT,
										  @homeTerminal_long FLOAT,
										  @checkcall_lat FLOAT,
										  @checkcall_long FLOAT,
										  @RouteDistance FLOAT OUT'
					EXEC sp_executesql 
						@sql, 
						@ParmDefinition,
						@homeTerminal_lat = @homeTerminal_lat,
						@homeTerminal_long = @homeTerminal_long,
						@checkcall_lat = @checkcall_lat,
						@checkcall_long = @checkcall_long, 
						@RouteDistance = @RouteDistance OUT
					
					IF @RouteDistance >= @ThresholdRadius BEGIN
						SET @subsistence_Qualified = 'Y';
					END
					ELSE BEGIN
						SET @subsistence_Qualified = 'N';
					END					
				END
				ELSE BEGIN
					SET @subsistence_Qualified = 'N';
				END
			END
		END
	END
END
GO
