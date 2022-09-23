SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[import_credit](	@batch				int,
									@previous_batch 	int,
									@id					varchar(10)) as

/**
 * 
 * NAME:
 * dbo.import_credit
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

declare @batchCount	 		int,
		  @processedcount 	int,
		  @msg					varchar(254)

/* SET BATCH NUMBER */
while (@batch = 0 ) 
	begin
	select  @batch =   max(err_batch) + 1
				from tts_errorlog

	select @batch =  IsNull(@batch,1000)
	end 


UPDATE importcredit
	SET imc_batchnumber = @batch  
from importcredit
where imc_batchnumber = @previous_batch


IF @@ERROR != 0  goto ERROR_EXIT

/* CHECK FOR VALID COMPANIES.	SELECT ASSUMES CREDIT FLAG IS DEFAULTED TO 'N' */
update importcredit
SET imc_importflag = 'Y'
from importcredit i, company c
where i.cmp_id =  c.cmp_id

IF @@ERROR != 0  goto ERROR_EXIT

select @batchCount = count(*) 
from importcredit
where imc_batchnumber = @batch

INSERT INTO tts_errorlog  
         ( err_batch,   
           err_user_id,   
           err_message,   
           err_date,   
           err_number,   
           err_title,   
           err_response,   
           err_sequence,   
           err_icon,   
           err_item_number,   
           err_type )  

select	 @batch,   
          @id,
           'Invalid company code: ' + cmp_id,   
           getdate(),   
           0,   
           'Credit Import',   
           'OK',   
           0,   
           'StopSign!',   
           cmp_id,   
           'CMPINV' 
from importcredit 
where imc_importflag = 'N' and imc_batchnumber = @batch  



/* RULE OUT THOSE WITH NULL TRANSACTION DATES OR NULL AMOUNTS */

INSERT INTO tts_errorlog  
         ( err_batch,   
           err_user_id,   
           err_message,   
           err_date,   
           err_number,   
           err_title,   
           err_response,   
           err_sequence,   
           err_icon,   
           err_item_number,   
           err_type )  

select	  @batch,   
           @id,   
           'Either the Credit Amount or the Transaction Date are null. This record was not processed. Company Id: ' + cmp_id,   
           getdate(),   
           0,   
           'Credit Import',   
           'OK',   
           0,   
           'StopSign!',   
           cmp_id,   
           'CMPINV' 
from importcredit 
where (imc_amount IS null or 
		imc_transdate IS null or
		imc_agedinvflag  IS null)

update importcredit 
	set imc_importflag = 'N'
from importcredit 
where (imc_amount IS null or imc_transdate IS null or imc_agedinvflag  IS null) and 
		(imc_batchnumber = @batch )

IF @@ERROR != 0  goto ERROR_EXIT

/* UPDATE COMPANY PROFILE */
UPDATE company  
 SET cmp_creditavail_update= importcredit.imc_transdate,
     cmp_creditavail 		= (company.cmp_creditlimit - importcredit.imc_amount),
	  cmp_agedinvflag  		= importcredit.imc_agedinvflag
FROM company, importcredit  
   WHERE ( company.cmp_id = importcredit.cmp_id ) and
			(imc_batchnumber = @batch ) and 
		   (imc_importflag  = 'Y')


IF @@ERROR != 0  goto ERROR_EXIT

/* DELETE ALL RECORDS PROCESSED IN THE BATCH*/
Delete importcredit  
WHERE (imc_importflag  = 'Y') and
		(imc_batchnumber = @batch )	

IF @@ERROR != 0  goto ERROR_EXIT



ERROR_EXIT:

IF (@@ERROR != 0) 
	BEGIN
	insert into tts_errorlog
		(err_batch, err_user_id, err_icon, err_title, err_response, err_message, err_date, err_sequence)
	values(@batch, @id, 'S', 'Credit Import', 'OK', 'Database error for batch:' + convert(varchar(12), @batch), getdate(), 0)    
	END
else

	begin
	select @processedcount = (@batchCount - count(*) )
	from importcredit
	where imc_batchnumber = @batch


	select @msg = convert(varchar(12), @processedcount ) + ' of '  + convert(varchar(12), @batchCount) + 
					' records processed for Credit Import Batch# ' + convert(varchar(12), @batch) + 
					' on ' + convert(varchar(20),getdate(),100) + 
					'. Credit Import Batch successfully completed.' 


	insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_title, err_response, err_message, err_date, err_sequence)
	values(@batch, @id, 'OK!', 'Credit Import', 'OK', @msg, getdate(), 0)    

	end



return @batch

GO
GRANT EXECUTE ON  [dbo].[import_credit] TO [public]
GO
