SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  FUNCTION [dbo].[ud_manpower_shell_FN] 
(@p_data varchar(255),
@Header_or_Data varchar(2),
@Column char(1))

RETURNS varchar(255)
AS
BEGIN
	DECLARE @func_name varchar(60),
	@output varchar(255)
	

	
	IF @Column = 1 
	BEGIN
		select @func_name = (select gi_string1 from generalinfo where gi_name = 'UD_MANPOWER_FUNCTIONS')
	END			
	IF @Column = 2 
	BEGIN
		select @func_name = (select gi_string2 from generalinfo where gi_name = 'UD_MANPOWER_FUNCTIONS')
	END	
	IF @Column = 3 
	BEGIN
		select @func_name = (select gi_string3 from generalinfo where gi_name = 'UD_MANPOWER_FUNCTIONS')
	END			
	IF @Column = 4 
	BEGIN
		select @func_name = (select gi_string4 from generalinfo where gi_name = 'UD_MANPOWER_FUNCTIONS')
	END				
	-- FOR DEBUGGING
	--select @proc_name = 'udf_stop_leg_1_sp'
	EXEC @output = @func_name @p_data,@Header_or_Data

RETURN @output
	
END
GO
GRANT EXECUTE ON  [dbo].[ud_manpower_shell_FN] TO [public]
GO
