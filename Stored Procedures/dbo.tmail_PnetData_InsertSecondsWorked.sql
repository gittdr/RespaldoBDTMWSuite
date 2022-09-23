SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PnetData_InsertSecondsWorked]
( 
	@Value INT,
	@Sequence INT,
	@CycleTimeId INT
)
AS

/**
 * 
 * NAME:
 * dbo.[tmail_PnetData_InsertSecondsWorked]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  insert record into SecondsWorked table and return id
 *
 * RETURNS:
 *  SecondsWorkedId
 * 
 * REVISION HISTORY:
 * 05/27/2014.01 - PTS77176 - APC - create proc
 *
 **/

SET NOCOUNT ON

INSERT INTO dbo.SecondsWorked
        ( Value, Sequence, CycleTimeId, ModifiedLast )
VALUES  
		( @Value, @Sequence, @CycleTimeId, GETDATE() )

SELECT @@IDENTITY;

GO
GRANT EXECUTE ON  [dbo].[tmail_PnetData_InsertSecondsWorked] TO [public]
GO
