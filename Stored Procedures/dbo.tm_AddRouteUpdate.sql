SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_AddRouteUpdate]	
					@sRouteUpdateID	varchar (12), 
				  	@sActualRouteID	varchar(12), 
					@sAction varchar(10), 
					@sStatus varchar(3),
				  	@sStatusDescription varchar(50),
					@sFlags varchar(12)
AS

SET NOCOUNT ON

DECLARE @lRouteUpdateID int,
		@lActualRouteID int,
		@lStatus int,
		@lFlags int

if ISNUMERIC(ISNULL(@sRouteUpdateID, '')) = 0
	BEGIN
	RAISERROR('Invalid or blank Route Update ID: %s', 1, 16, @sRouteUpdateID)
	RETURN
	END

if ISNUMERIC(ISNULL(@sActualRouteID, '')) = 0
	BEGIN
	RAISERROR('Invalid or blank Actual Route ID: %s', 1, 16, @sActualRouteID)
	RETURN
	END

if ISNULL(@sAction, '') = ''
	BEGIN
	RAISERROR('Action must be set.', 1, 16)
	RETURN
	END

if ISNUMERIC(ISNULL(@sStatus, '')) = 0
	BEGIN
	RAISERROR('Invalid or blank Status: %s', 1, 16, @sStatus)
	RETURN
	END

if ISNULL(@sStatusDescription, '') = ''
	BEGIN
	RAISERROR('Status Description must be set.', 1, 16)
	RETURN
	END

SET @lRouteUpdateID = CONVERT(int, @sRouteUpdateID)
SET @lActualRouteID = CONVERT(int, @sActualRouteID)
SET @lStatus = CONVERT(int, @sStatus)
SET @lFlags = CONVERT(int, @sFlags)

INSERT INTO tblFARouteUpdates (RouteUpdateID, ActualRouteID, Action, Status, StatusDescr, UpdatedOn) 
	VALUES (@lRouteUpdateID, @lActualRouteID, @sAction, @lStatus, @sStatusDescription, GETDATE())

GO
GRANT EXECUTE ON  [dbo].[tm_AddRouteUpdate] TO [public]
GO
