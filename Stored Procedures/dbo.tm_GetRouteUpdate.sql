SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetRouteUpdate]	
					@RouteUpdateID	varchar (12), 
				  	@sActualRouteID	varchar(12), 
					@sAction varchar(10), 
					@sFlags varchar(12)
AS

SET NOCOUNT ON

DECLARE @lRouteUpdateID int,
		@lActualRouteID int,
		@lStatus int,
		@lFlags int,
		@MaxDate datetime

if ISNUMERIC(ISNULL(@RouteUpdateID, '')) = 0 AND ISNUMERIC(ISNULL(@sActualRouteID, '')) = 0
	BEGIN
	RAISERROR('Actual or Route Update ID must be supplied', 1, 16)
	RETURN
	END

SET @lRouteUpdateID = CONVERT(int, @RouteUpdateID)
SET @lActualRouteID = CONVERT(int, @sActualRouteID)
SET @lFlags = CONVERT(int, @sFlags)

IF @lFlags & 1 = 1
	BEGIN

		if ISNUMERIC(ISNULL(@sActualRouteID, '')) = 0
			BEGIN
			RAISERROR('Actual ID must be supplied when flag 1 is set.', 1, 16)
			RETURN
			END

		SELECT @MaxDate = MAX(UpdatedOn)
			FROM tblFARouteUpdates  (NOLOCK)
			WHERE Action = CASE WHEN ISNULL(@sAction, '') = '' THEN Action ELSE @sAction END
				AND ActualRouteID = @lActualRouteID

		SELECT RouteUpdateID, ActualRouteID, Action, Status, StatusDescr, UpdatedOn 
			FROM tblFARouteUpdates  (NOLOCK)
			WHERE UpdatedOn = @MaxDate
				AND ActualRouteID = @lActualRouteID
	END
ELSE
	SELECT RouteUpdateID, ActualRouteID, Action, Status, StatusDescr, UpdatedOn 
		FROM tblFARouteUpdates  (NOLOCK)
		WHERE RouteUpdateID = CASE WHEN @lRouteUpdateID = 0 THEN RouteUpdateID ELSE @lRouteUpdateID END
			AND ActualRouteID = CASE WHEN @lActualRouteID = 0 THEN ActualRouteID ELSE @lActualRouteID END
			AND Action = CASE WHEN @sAction = '' THEN Action ELSE @sAction END
	
GO
GRANT EXECUTE ON  [dbo].[tm_GetRouteUpdate] TO [public]
GO
