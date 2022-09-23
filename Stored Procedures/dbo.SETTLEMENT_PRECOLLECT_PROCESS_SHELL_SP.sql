SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[SETTLEMENT_PRECOLLECT_PROCESS_SHELL_SP] (
	@pl_pyhnumber int , 
	@ps_asgn_type varchar(6),
	@ps_asgn_id varchar(13) ,
	@pdt_payperiod datetime, 
	@psd_id int,
	@ps_returnmsg varchar(255) out -- You should return a message to the application to indicate why the custom calculation failed.
	)
as

--Modfication Log
-- LOR	PTS# 41370	created
DECLARE @proc_name varchar(60)

select @proc_name = (select gi_string2 from generalinfo where gi_name = 'HourlyOTPay')

EXEC @proc_name @pl_pyhnumber, @ps_asgn_type, @ps_asgn_id, @pdt_payperiod, @psd_id, @ps_message = @ps_returnmsg output
GO
GRANT EXECUTE ON  [dbo].[SETTLEMENT_PRECOLLECT_PROCESS_SHELL_SP] TO [public]
GO
