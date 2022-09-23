SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[get_payto_ytd_sp] (@as_payto varchar(12),@adec_ytd money output)
as
declare @li_year int
begin
	-- jyang pts13004
	Declare @PeriodforYTD Varchar(3)

	SELECT @PeriodforYTD = isnull(gi_string1,'no') 
	FROM generalinfo
	WHERE gi_name = 'UsePayperiodForYTD'
        
        if left(ltrim(@PeriodforYTD),1) = 'Y' begin
		select @li_year = datepart(yyyy,getdate())
		select @adec_ytd = sum(pyh_totalcomp) from payheader 
			where pyh_payto = @as_payto and datepart(yyyy,pyh_payperiod) = @li_year
	end else begin
		select @li_year = datepart(yyyy,getdate())
		select @adec_ytd = sum(pyh_totalcomp) from payheader 
			where pyh_payto = @as_payto and datepart(yyyy,IsNull(pyh_issuedate,pyh_payperiod)) = @li_year
	end 

	-- RE - 01/25/02 - PTS #13126
	select @adec_ytd = isnull(@adec_ytd, 0)

	update payto set pto_yrtodategross=@adec_ytd where pto_id = @as_payto
	return
end
GO
GRANT EXECUTE ON  [dbo].[get_payto_ytd_sp] TO [public]
GO
