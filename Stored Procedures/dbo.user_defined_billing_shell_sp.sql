SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[user_defined_billing_shell_sp] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_tar_number int, -- number of the tariff
    @pl_fgtnumber int,  -- if rate by detail this has the fgt number of commodity
    @pl_dbh_id int,		-- PTS 64242 dedicated billing header id
    @pl_dbs_id int,		-- PTS 64242 dedicated schedule id
	@pdec_calcqty decimal(18,6) out, -- return the calculated billing quantity here. Populate this with NULL if quantity is not to be returned. 
	@pdec_calcrate decimal(18,6) out, -- return the calculated bililng rate here.  Populate this with NULL if the rate is not to be returned. 
	@ps_returnmsg varchar(255) out -- You should return a message to the application to indicate why the custom calculation failed.
	)
as

--Modfication Log
-- 08/30/07 EMK - Changed @pdec_cal_qty in procedure declaration to decimal. 
-- PTS50468 (cons 48966)  DPETE for Reed Dallman add fgt_number to the arguments
--      To leave old procs valid must check string2 to see which args proc supports
--      +FGT means add fgt_number to input arguments
-- PTS 64242 NLOKE - Add argument to handle dedicated biling custom proc using +DED on string2 GI UserDefinedBillingMethod


DECLARE @proc_name varchar(60)
select @proc_name = (select gi_string1 from generalinfo where gi_name = 'UserDefinedBillingMethod')

If exists (select 1 from generalinfo where gi_name =  'UserDefinedBillingMethod'
   and upper(gi_string2) = '+FGT') 
	exec @proc_name @pl_ord_hdrnumber,@pl_tar_number,@pl_fgtnumber, @pdec_qty = @pdec_calcqty output, @pdec_rate=@pdec_calcrate output,@ps_message = @ps_returnmsg output
else 
	-- begin 64242
	If exists (select 1 from generalinfo where gi_name =  'UserDefinedBillingMethod' and upper(gi_string2) = '+DED')	
		exec @proc_name @pl_ord_hdrnumber,@pl_tar_number,@pl_fgtnumber, @pl_dbh_id, @pl_dbs_id, @pdec_qty = @pdec_calcqty output, @pdec_rate=@pdec_calcrate output,@ps_message = @ps_returnmsg output
	else
	-- end 64242
		EXEC @proc_name @pl_ord_hdrnumber,@pl_tar_number,@pdec_qty = @pdec_calcqty output, @pdec_rate=@pdec_calcrate output,@ps_message = @ps_returnmsg output
GO
GRANT EXECUTE ON  [dbo].[user_defined_billing_shell_sp] TO [public]
GO
