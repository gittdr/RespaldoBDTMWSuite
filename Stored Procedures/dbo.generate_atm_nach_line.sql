SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[generate_atm_nach_line] 
	@asgn_type		varchar(6),
	@asgn_id		varchar(13),
	@advance_amount	money
as 

declare		@company_acct_number	char(18),
			@card_acct_number		char(18),
			@currency				varchar(6),
			@advance_string			varchar(38),
			@line					varchar(1000)

select @company_acct_number =  gi_string1
  from generalinfo
 where gi_name = 'CompanyBankAccount'

select @card_acct_number = mpp_misc2
  from manpowerprofile mpp
  where mpp.mpp_id = @asgn_id and @asgn_type = 'DRV'

/*
if @asgn_type = 'DRV' 
	select @currency = mpp.mpp_currency
      from manpowerprofile mpp
     where mpp.mpp_id = @asgn_id
else if @asgn_type = 'TRC'
	select @currency = pto.pto_currency
	  from tractorprofile trc
      join payto pto on pto.pto_id = trc_owner
	 where trc.trc_number = @asgn_id
else if @asgn_type = 'TRL'
	select @currency = pto.pto_currency
	  from trailerprofile trl
	  join payto pto on pto.pto_id = trl_owner
	 where trl.trl_id = @asgn_id
*/
select @currency = 'MXP'

set @advance_string = '0000000000000000' + isnull(convert(varchar(38),@advance_amount),'00.00')
set @advance_string = substring(@advance_string,len(convert(varchar(38),@advance_string))-15,16)


set @line = rtrim(ltrim(isnull(@card_acct_number,'NULLCARD'))) + rtrim(ltrim(isnull(@company_acct_number,'NULLCOMPACCT'))) + isnull(@currency, 'NULLCURRENCY') + @advance_string
select @line

GO
GRANT EXECUTE ON  [dbo].[generate_atm_nach_line] TO [public]
GO
