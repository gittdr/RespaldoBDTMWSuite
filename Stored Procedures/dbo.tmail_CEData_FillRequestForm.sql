SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[tmail_CEData_FillRequestForm]
	 @p_eventKey varchar(15)
AS

/**
 * 
 * NAME:
 * dbo.tmail_CEData_FillRequestForm
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	Used by the Critical Event Report form to fill the relevant data for the form
 * 
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * N/A
 *
 * PARAMETERS
 * 001 - @p_CEDATA_SN varchar
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 6/4/2015.01 - JMG - created
 *
 **/

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @eventKey int
	DECLARE @critcalEvent varchar(50)
	DECLARE @ord_Number AS varchar(20)
	DECLARE @trl_Number as varchar(20)

	IF (ISNUMERIC(@p_eventKey) > 0)    
		SET @eventKey = CONVERT(int,@p_eventKey)    
	ELSE    
	BEGIN    
		RAISERROR ('INVALID CRITICAL EVENT SN: %s.', 16, 1, @p_eventKey)    
		RETURN    
	END      

	--VALIDATION
	Select	@critcalEvent = criticalEvent,
			@ord_Number = orderNbr,
			@trl_Number = trailerID			
	from dbo.tblCEData c
	where c.eventKey = @eventKey


	select @critcalEvent as criticalEvent, @ord_Number as orderNumber, @trl_Number as trl_Number

GO
GRANT EXECUTE ON  [dbo].[tmail_CEData_FillRequestForm] TO [public]
GO
