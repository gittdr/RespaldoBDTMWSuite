SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[DescribeTrailerCommand](@trlc_id int) returns varchar(MAX)
as
begin
	declare @System varchar(6), @Command varchar(6), @BaseCommandText varchar(30),
		@Parm1 varchar(30), @Parm2 varchar(30), @Parm3 varchar(30), @Parm4 varchar(30),
		@retval varchar(MAX)
	SELECT @system = acm_system, @Command = trlc_command, @Parm1 = trlc_parm1, @Parm2 = trlc_parm2, @Parm3 = trlc_parm3, @Parm4 = trlc_parm4  FROM TRAILERCOMMANDS where trlc_id = @trlc_id
	if @system = 'STRTRK'
	begin
		select @BaseCommandText = name from labelfile where labeldefinition = 'StarTrakCommands' and abbr = @command
		if @command = 21012 or @Command = 21040 or @Command = 30010
			select @retval = @BaseCommandText + ': ' + @parm1 
		else if @command = 21030
			select @retval = @BaseCommandText + ': Compartment ' + @parm1 + ' to '+ @Parm2 
		else if @command = 30020 or @command = 30030
			begin
			if ISNULL(@Parm2, '')=''
				select @Retval = @BaseCommandText + ': ' + @Parm1
			else if ISNULL(@Parm3, '')=''
				select @Retval = @BaseCommandText + ': ' + @Parm1 + ':' + @Parm2
			else if ISNULL(@Parm4, '')=''
				select @Retval = @BaseCommandText + ': ' + @Parm1 + ':' + @Parm2 + ':' + @Parm3
			else
				select @Retval = @BaseCommandText + ': ' + @Parm1 + ':' + @Parm2 + ':' + @Parm3 + ':' + @Parm4
			end
		else
			select @retval = @BaseCommandText
	end
	return @retval
end
GO
GRANT EXECUTE ON  [dbo].[DescribeTrailerCommand] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DescribeTrailerCommand] TO [public]
GO
