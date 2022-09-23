SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRS_ErrorToAdmin]
(
	@ErrNumber int = -2147221504,
	@MessagePart varchar(8000),
	@FailurePart varchar(8000),
	@Source varchar(254)
) 
AS 

/**
 * 
 * NAME:
 * dbo.tm_XRS_ErrorToAdmin
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Sends errors to totalmail Admin inbox
 * 
 *
 *
 * Change Log: 
 * rwolfe init 2014/04/02
 * 
 *
 **/

SET NOCOUNT ON
-- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION IS UNACCEPTABLE BECAUSE OF tm_AddErrorToMessage

	Exec tm_ErrorToAdmin 
		@Source = @Source,
		@MessagePart = @MessagePart,
		@ErrorTxt1 = @FailurePart,
		@ErrNumber1 = @ErrNumber
	    
GO
GRANT EXECUTE ON  [dbo].[tm_XRS_ErrorToAdmin] TO [public]
GO
