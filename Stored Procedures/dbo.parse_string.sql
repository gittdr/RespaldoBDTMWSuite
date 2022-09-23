SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
  This proc is used recursively to parse a long string with intervening delimiter entries into 
  individual lines by returning the next line (up to the next delimiter or end of string) and 
  removing that next line from the passed long string.  

  For example if @multilinetext contains 'Line 1CR/LFLine 2CR/LFLine3' 
  and the delimiter is 'CR/LF':
                        INPUT                              OUTPUT
    
     FIRST CALL  'Line 1CR/LFLine 2CR/LFLine3' ''    'Line 2CR/LFLine3' 'Line 1'
     2nd   CALL  'Line 2CR/LFLine3'            ''    'Line3'            'Line 2'
     3rd   CALL  'Line3'                       ''    ''                 'Line 3'
  
  
  If the calling proc need the single lines to be truncated, it will take care of that.
*/


CREATE PROC [dbo].[parse_string] 
	@multilinetext varchar(250) output, 
	@singlelinetext varchar(250) output,
	@delimiter varchar(10) output
AS
DECLARE @pos int
	
	SELECT @pos = isnull(charindex(@delimiter,@multilinetext),0)

	IF @pos < 1 select @pos = isnull(charindex(char(10),@multilinetext),0)

	IF @pos > 0
	  BEGIN
		SELECT @singlelinetext = LTRIM(SUBSTRING(@multilinetext,1,@pos - 1))
		SELECT @multilinetext = SUBSTRING(@multilinetext,@pos + 2,250)

	  END
	ELSE
	  BEGIN
		select @singlelinetext = LTRIM(@multilinetext)	
		select @multilinetext = ''
	  END

	IF LEN(@multilinetext) > 0
		return 1
	else
		return 0


GO
GRANT EXECUTE ON  [dbo].[parse_string] TO [public]
GO
