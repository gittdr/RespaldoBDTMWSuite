SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
	
CREATE   PROCEDURE [dbo].[user_defined_billing_sp] (
	@pl_ord_hdrnumber int , -- the current order being rated 
	@pl_tar_number int, -- number of the tariff
	@pdec_qty decimal(18,6) out, -- return the calculated billing quantity here. 
	@pdec_rate decimal (18,6) out, -- return the calculated bililng rate here.  Populate this with NULL if the rate is not to be returned.  
	@ps_message varchar(255) out -- You should return a message to the application to indicate failure and why the custom calculation failed.
	)
as

-- Replace these lines when creating your custom stored procedure.
-- BEGIN
Select @pdec_rate = NULL
Select @pdec_qty = NULL
Select @ps_message = 'This is the default stub.  Use this template to create your own customized stored procedure.'
-- END
GO
GRANT EXECUTE ON  [dbo].[user_defined_billing_sp] TO [public]
GO
