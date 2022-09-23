SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[translate_numbers_to_words_sp] (@number decimal(16,2), @language varchar (64), @text varchar (256) output) 
AS

declare @remainder decimal,
	@million smallint,	
	@thousand smallint,
	@hundred smallint,
	@hundredcheck smallint,
	@ten smallint,
	@one smallint,
	@textwork varchar (256),
	@qualifier varchar (6), 
        @return int

set @return = 0
set @million  = round (@number / 1000000, 0, 1)
set @number = @number - @million * 1000000
set @thousand  = round (@number/1000, 0, 1)
set @number = @number - @thousand * 1000
set @hundredcheck = @number
set @hundred  = round (@number/100, 0, 1)
set @number = @number - @hundred * 100
set @ten  = round (@number/10, 0, 1)
set @number = @number - @ten * 10
set @one  = round (@number, 0, 1)
set @number = @number - @one

Set @textwork = ''
if @million > 0 
begin
	exec translate_numbers_to_words_sp @million, @language, @textwork output
--	exec translate_sp @textwork, @language, @textwork output 
	set @text =  @text + @textwork 
	exec translate_sp 'Million', @language, @textwork output
	set @text =  @text + @textwork 
end 

set @textwork = ''
if @thousand > 0 
begin 
	exec translate_numbers_to_words_sp @thousand, @language, @textwork output
--	exec translate_sp @textwork, @language, @textwork output 
	set @text =  @text + @textwork 
	exec translate_sp 'Thousand', @language, @textwork output
	set @text =  @text + @textwork 
end 

set @textwork = ''
if @hundred > 0 
begin 
	exec translate_numbers_to_words_sp @hundred, @language, @textwork output
--	exec translate_sp @textwork, @language, @textwork output 
	set @text =  @text + @textwork 
	exec translate_sp 'Hundred', @language, @textwork output
        if Upper (@language) = 'SPANISH' and @hundredcheck = 100
           set @textwork = 'Cien'
        if Upper (@language) = 'DUTCH' and @hundredcheck = 100
           set @textwork = 'Honderd'
	if Upper (@language) = 'GERMAN' and @hundredcheck = 100
           set @textwork = 'Hundert'
	if Upper (@language) = 'FRENCH' and @hundredcheck = 100
           set @textwork = 'Cent'
        if @language = 'spanish' and @hundredcheck > 199
           set @textwork = 'Cientos'
	set @text =  Case when @text = 'Uno' and left (@textwork, 4) = 'Cien' Then '' 
                          when @text = 'Ein' and left (@textwork, 7) = 'Hundert' then ''
			  when @text = 'Een' and left (@textwork, 7) = 'Honderd' then ''	
			  when @text = 'Un' and left (@textwork, 4) = 'Cent' then ''	
                          Else @text end + @textwork
end 

set @textwork = ' '
if @ten between 2 and 9
begin
set @textwork = 
	case @ten 
	when 2 then 'Twenty'
	when 3 then 'Thirty'
	when 4 then 'Forty'
	when 5 then 'Fifty'
	when 6 then 'Sixty'
	when 7 then 'Seventy'
	when 8 then 'Eighty'
	when 9 then 'Ninety' 
end 
exec translate_sp @textwork, @language, @textwork output , @qualifier output  
set @text = @text + @textwork 
end

set @textwork = ''
if @ten = 1 
begin
set @textwork =
	case @one 
	when 1 then 'Eleven'
	when 2 then 'Twelve'
	when 3 then 'Thirteen'
	when 4 then 'Fourteen'
	when 5 then 'Fifteen'
	when 6 then 'Sixteen'
	when 7 then 'Seventeen'
	when 8 then 'Eighteen'
	when 9 then 'Nineteen'
	end 
exec translate_sp @textwork, @language, @textwork output 
end
if @one > 0 and @ten <> 1
begin
	set @textwork =
		case @one
		when 1 then 'One'
		when 2 then 'Two'
		when 3 then 'Three'
		when 4 then 'Four'
		when 5 then 'Five'
		when 6 then 'Six'
		when 7 then 'Seven'
		when 8 then 'Eight'
		when 9 then 'Nine'
	end

exec translate_sp @textwork, @language, @textwork output 
end

if @qualifier is null
set @qualifier = ''

set @text = LTRIM(@text + Case when @one > 0 then @qualifier else '' end + @textwork)

if @number > .00 and @number < 1
   set @return = convert(int, Round((@number * 100), 0, 1))

return @return

GO
GRANT EXECUTE ON  [dbo].[translate_numbers_to_words_sp] TO [public]
GO
