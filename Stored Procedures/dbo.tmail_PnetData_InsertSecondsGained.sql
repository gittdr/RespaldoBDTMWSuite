SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PnetData_InsertSecondsGained]
( 
	@Value INT,
	@Sequence INT,
	@HoSRuleId INT
)
AS

/**
 * 
 * NAME:
 * dbo.[tmail_PnetData_InsertSecondsGained]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  insert record into SecondsGained table and return id
 *
 * RETURNS:
 *  SecondsGainedId
 * 
 * REVISION HISTORY:
 * 05/27/2014.01 - PTS77176 - APC - create proc
 *
 **/

SET NOCOUNT ON

INSERT INTO dbo.SecondsGained
        ( Value, Sequence, HoSRuleId, ModifiedLast )
VALUES  ( @Value, @Sequence, @HoSRuleId, GETDATE() )

SELECT @@IDENTITY;

GO
GRANT EXECUTE ON  [dbo].[tmail_PnetData_InsertSecondsGained] TO [public]
GO
