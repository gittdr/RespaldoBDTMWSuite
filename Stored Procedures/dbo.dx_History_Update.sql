SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_History_Update]
	@p_dx_origin varchar(10), 
	@p_dx_command varchar(40), 
	@p_dx_commandstring varchar(max), 
	@p_dx_returncode int, 		
	@p_dx_ordernumber varchar(30) 
AS

/*******************************************************************************************************************  
  Object Description:
  dx_History_Update

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	DECLARE @p_LastIndex as INT,
	@p_CurrentCount int,
	@p_dx_importid varchar(8), 
	@p_dx_sourcedate datetime,
	@p_dx_orderhdrnumber int, 
	@p_dx_docnumber varchar(30)
	
	SELECT @p_CurrentCount = Count(dx_ident) FROM  dx_History WHERE dx_ordernumber = @p_dx_ordernumber
	
	IF (@p_CurrentCount > 0) 
		BEGIN 
			SELECT 
				@p_LastIndex = (MAX(dx_hist_seq)+1), @p_dx_orderhdrnumber = dx_orderhdrnumber, 
				@p_dx_sourcedate = dx_sourcedate, @p_dx_importid = dx_importid, @p_dx_docnumber = dx_docnumber
			FROM  
				dx_History 
			WHERE
				dx_ordernumber = @p_dx_ordernumber
			GROUP BY
				dx_orderhdrnumber, dx_sourcedate, dx_importid, dx_docnumber
	
			INSERT INTO dx_History
				(dx_importid, dx_sourcename, dx_sourcedate, dx_actiondate, 
				dx_hist_seq, dx_origin, dx_command, dx_commandstring, 
				dx_returncode, dx_orderhdrnumber, dx_ordernumber, dx_docnumber)
			VALUES
				(@p_dx_importid, USER, @p_dx_sourcedate, GETDATE(),
				@p_LastIndex, @p_dx_origin, @p_dx_command, @p_dx_commandstring,
				@p_dx_returncode, @p_dx_orderhdrnumber, @p_dx_ordernumber,  @p_dx_docnumber)
		END


GO
GRANT EXECUTE ON  [dbo].[dx_History_Update] TO [public]
GO
