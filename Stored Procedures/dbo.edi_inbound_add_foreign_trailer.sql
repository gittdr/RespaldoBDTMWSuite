SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_inbound_add_foreign_trailer]
	@trailer_number varchar(8),
	@@trailer_num varchar(13) OUTPUT
AS 
	
	-- UPPER CASE THE TRAILER NUMBER
	SELECT @trailer_number = UPPER(@trailer_number)
	SELECT @@trailer_num = 'FRGN,' + @trailer_number

	-- Variables
	DECLARE @exp_expirationdate datetime
	DECLARE @exp_expirationdate_new datetime
	DECLARE @trl_status_new varchar(6)

	-- New Experation Date
	SELECT @exp_expirationdate_new = DateAdd(day,28,getdate())

	-- Default Current Experation Date to Today - thus ensureing its pushed out to the new date
	SELECT @exp_expirationdate = getdate()


	IF EXISTS (SELECT 1 FROM trailerprofile
				WHERE trl_id = @@trailer_num)
		BEGIN
			exec edi_inbound_activateTrailer_sp @@trailer_num, @exp_expirationdate, @exp_expirationdate_new, @trl_status_new
		END
	ELSE
		BEGIN
			exec edi_inbound_insertForeignTrailer_sp @trailer_number, 'FRGN'
			exec edi_inbound_insertTrailerExp_sp @@trailer_num, @exp_expirationdate_new
		END
	
 

	select @@trailer_num
	
  	RETURN 1
GO
GRANT EXECUTE ON  [dbo].[edi_inbound_add_foreign_trailer] TO [public]
GO
