SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[LOAD_REVTYPES_for_Tariff_Template_dddws_SP] @name varchar(20) AS

-- pts 46628 created ( -- copied from LOAD_LABEL_BYSTATUS_WITHROWSECURITYOVERRIDE_SP ) 

declare @retired_flag varchar(1)
declare @RowSecurityOverride varchar(1)
set @retired_flag = 'N'
set @RowSecurityOverride = 'N'

declare	@tmwuser	varchar(255)

create table #temp_return(name varchar(20), abbr varchar(6), code int) 
insert into #temp_return(name, abbr, code)
values('FRMORD', 'FRMORD', 999999 )


if @name = 'REVTYPE1' and upper(left((select gi_string1 from generalinfo where gi_name = 'rowsecurity'),1)) = 'Y'
begin
	exec @tmwuser = dbo.gettmwuser_fn

	IF NOT EXISTS(SELECT * 
						FROM UserTypeAssignment
						WHERE usr_userid = @tmwuser)
		OR
	EXISTS(SELECT * 
				FROM UserTypeAssignment
				WHERE usr_userid = @tmwuser
						and (uta_type1 = 'UNK'))
		OR
	@RowSecurityOverride = 'Y' BEGIN
		IF @retired_flag = 'Y'
			Insert into #temp_return
			SELECT name, 
			abbr, 
			code 
			FROM labelfile 
			WHERE 	labeldefinition = @name
		ELSE
			Insert into #temp_return
			SELECT name, 
			abbr, 
			code 
			FROM labelfile 
			WHERE 	labeldefinition = @name AND
				IsNull(retired, 'N') <> 'Y'
				
				
		select * from #temp_return	order by code	
		return
	END


	IF @retired_flag = 'Y'
		Insert into #temp_return
		SELECT name, 
		abbr, 
		code 
		FROM labelfile 
		WHERE 	labeldefinition = @name
			and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))

	ELSE
		Insert into #temp_return
		SELECT name, 
		abbr, 
		code 
		FROM labelfile 
		WHERE 	labeldefinition = @name AND
			IsNull(retired, 'N') <> 'Y'
			and (abbr = 'UNK' or abbr in (select uta_type1 from usertypeassignment where usr_userid = dbo.gettmwuser_fn()))
			
	select * from #temp_return	order by code			
	return
end


IF @retired_flag = 'Y'
	Insert into #temp_return
	SELECT name, 
	abbr, 
	code 
	FROM labelfile 
	WHERE 	labeldefinition = @name

ELSE
	Insert into #temp_return
	SELECT name, 
	abbr, 
	code 
	FROM labelfile 
	WHERE 	labeldefinition = @name AND
		IsNull(retired, 'N') <> 'Y'


select * from #temp_return	order by code	

GO
GRANT EXECUTE ON  [dbo].[LOAD_REVTYPES_for_Tariff_Template_dddws_SP] TO [public]
GO
