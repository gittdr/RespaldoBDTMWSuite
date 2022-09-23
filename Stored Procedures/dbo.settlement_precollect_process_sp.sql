SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
	
CREATE   PROCEDURE [dbo].[settlement_precollect_process_sp] (
	@pl_pyhnumber int , 
	@ps_asgn_type varchar(6),
	@ps_asgn_id varchar(13) ,
	@pdt_payperiod datetime, 
	@psd_id int,
	@ps_message varchar(255) out -- You should return a message to the application to indicate failure and why the custom calculation failed.
	)
as

-- Replace these lines when creating your custom stored procedure.
-- BEGIN
Select @ps_message = 'This is the default stub.  Use this template to create your own customized stored procedure.'
-- END
GO
GRANT EXECUTE ON  [dbo].[settlement_precollect_process_sp] TO [public]
GO
