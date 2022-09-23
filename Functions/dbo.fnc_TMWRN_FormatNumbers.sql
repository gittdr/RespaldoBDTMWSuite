SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_FormatNumbers] 
	(
		@Numeric_Value decimal(20,4)
		,@NumDigitsAfterDecimal int 
	) 

returns varchar(20)

AS

BEGIN
	declare @Return_Value varchar(20)
	declare @is_negative bit

	select @is_negative = case when @Numeric_Value < 0 then 1 else 0 end

	if @is_negative = 1
		set @Numeric_Value = -1 * @Numeric_Value

	set @Numeric_Value = Round(@Numeric_Value,@NumDigitsAfterDecimal)

	set @Return_Value = convert(varchar, isnull(@Numeric_Value, 0))

	declare @before varchar(20), @after varchar(20)

	if charindex ('.', @Return_Value ) > 0 
	  begin
			set @before= substring(@Return_Value, 1, charindex ('.', @Return_Value )-1)      
			set @after= substring(@Return_Value, charindex ('.', @Return_Value ), len(@Return_Value))     
	  end
	else
	  begin
			set @before = @Return_Value
			set @after='.0000'
	  end

	-- after every third character:
	declare @i int

	if len(@before) > 3 
	  begin
			set @i = 3
			while @i > 1 and @i < len(@before)
				begin
					  set @before = substring(@before,1,len(@before)-@i) + ',' + right(@before,@i)
					  set @i = @i + 4
				end
	  end

	set @Return_Value = @before + @after

	set @Return_Value = 
		Case when @NumDigitsAfterDecimal = 0 Then
			Substring(@Return_Value,1,CharIndex('.',@Return_Value,1) -1)
		Else
			Substring(@Return_Value,1,CharIndex('.',@Return_Value,1) + @NumDigitsAfterDecimal)
		End

	if @is_negative = 1
		set @Return_Value = '-' + @Return_Value

	return @Return_Value 
END

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_FormatNumbers] TO [public]
GO
