SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DeleteTrailer] 	@sTrailerName varchar(15) = NULL, 
										@sTrailerSN varchar(12) = NULL,
										@sDispatchSystemID varchar(20) = NULL, 
										@sDeleteHistory varchar(1) = NULL,
										@sDeleteCabUnit varchar(1) = NULL

AS

SET NOCOUNT ON

--//  @sTrailerName				- TotalMail Trailer Name to delete (Optional if SN or Dispatch ID supplied)
--//  @sTrailerSN				- Trailer SN to delete (Optional if Name or Dispatch ID supplied)
--//  @sDispatchSystemID		- Dispatch System ID for Trailer to delete (Optional if Name or SN supplied). 
--//  @sDeleteHistory     - Delete history messages for trailer
--//        0 or No, 1 for Yes. 
--//        NULL means keep history messages
--//
--//  @sDeleteCabUnit     - Delete cab unit for trailer
--//        0 or No, 1 for Yes. 
--//        NULL means keep cab unit
--//
--// Calls tm_DeleteTruck - Wrapper just checks for TRL: and gives trailer error codes

DECLARE @lTrailerSN int
	
SELECT @sTrailerName = ISNULL(@sTrailerName, '')
SELECT @sDispatchSystemID = ISNULL(@sDispatchSystemID, '')
SELECT @lTrailerSN = ISNULL(CONVERT(int, @sTrailerSN), 0)

IF @lTrailerSN = 0
	BEGIN
		IF @sTrailerName > ''
			BEGIN
				SELECT @lTrailerSN = SN 
				FROM tblTrucks (NOLOCK)
				WHERE TruckName = @sTrailerName
				
				IF ISNULL(@lTrailerSN, 0) = 0
					BEGIN
					RAISERROR('Trailer Name (%s) not found in TotalMail', 16, 1, @sTrailerName)
					RETURN
					END
		
			END
		else if @sDispatchSystemID > ''
			BEGIN
			------------------ Init @sDispatchSystemID  --------------------------
			 IF UPPER(LEFT(ISNULL(@sDispatchSystemID, '    '), 4)) <> 'TRL:'
				SELECT @sDispatchSystemID = 'TRL:' + @sDispatchSystemID
		
				SELECT @lTrailerSN = SN 
				FROM tblTrucks (NOLOCK)
				WHERE DispSysTruckID = @sDispatchSystemID
				
				IF ISNULL(@lTrailerSN, 0) = 0
					BEGIN
					RAISERROR('Trailer Name not specified and Dispatch System ID (%s) not found in TotalMail', 16, 1, @sDispatchSystemID)
					RETURN
					END
			END
		else
			BEGIN
			RAISERROR('Trailer Name or Dispatch System ID must be specified', 16, 1)
			RETURN
			END
	END
else
	IF NOT EXISTS(SELECT * 
					FROM tblTrucks (NOLOCK)
					WHERE SN = @lTrailerSN)
		BEGIN
		RAISERROR('Trailer SN (%d) not found in TotalMail', 16, 1, @lTrailerSN)
		RETURN
		END

--Get basic information
SELECT @sTrailerName = TruckName, 
	   @sDispatchSystemID = DispSysTruckID
	FROM tblTrucks (NOLOCK)
	WHERE SN = @lTrailerSN

EXEC tm_DeleteTruck 	@sTrailerName, 
						@sTrailerSN,
						@sDispatchSystemID, 
						@sDeleteHistory,
						@sDeleteCabUnit

GO
GRANT EXECUTE ON  [dbo].[tm_DeleteTrailer] TO [public]
GO
