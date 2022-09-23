SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_XRS_tractordriverpull]
(
	@ID VARCHAR(8)
)
AS 
/*
Name: tmail_XRS_tractordriverpull

Type:
Stored Procedure

Descritption:
gets driver 1 and 2 for a tracotr number

Returns:
vals of driver1 and driver2

Parameters:
Truck id

Change Log:
rwolfe init 06-09-2014

*/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT trc_driver, trc_driver2 FROM dbo.tractorprofile WHERE trc_number = @ID;

GO
GRANT EXECUTE ON  [dbo].[tmail_XRS_tractordriverpull] TO [public]
GO
