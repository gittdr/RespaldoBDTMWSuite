SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_GetDefaultValueForParmeterForStoredProc]
	(@ProcName Varchar(80), @ParameterName Varchar(80))

RETURNS Varchar(80)
AS
BEGIN



Declare @QuoteDelimiterFound int

Declare @Text1 varchar(8000)
--Declare @Text1_5 varchar(8000) -- was going to make look across more than first 8000 bytes but deemed unnecesary
--Declare @Text2 varchar(8000)	 -- Also look at making it recursive to do this...
--Declare @Text2_5 varchar(8000)
--Declare @Text3 varchar(8000)
Declare @Work varchar(8000)
Declare @i int
Declare @r Varchar(80)

Set @Text1=(	Select 
			text 
		from 
			sysobjects o,
			syscomments c
		where 
			o.name=@ProcName and xtype='P'
			AND
			o.id=c.id and c.colid=1
		)
/*
Set @Text2=(	Select 
			text 
		from 
			sysobjects o,
			syscomments c
		where 
			o.name=@ProcName and xtype='P'
			AND
			o.id=c.id and c.colid=2
		)
	
Set @Text3=(	Select 
			text 
		from 
			sysobjects o,
			syscomments c
		where 
			o.name=@ProcName and xtype='P'
			AND
			o.id=c.id and c.colid=3
		)
if Len(@Text1)=8000
BEGIN	
	Set @Text1_5 =Substring(@Text1,4001,4000) +Substring(@Text2,1,4000)
END
if Len(@Text2)=8000
BEGIN	
	Set @Text2_5 =Substring(@Text2,4001,4000) +Substring(@Text3,1,4000)
END
Set @text1 =(select dbo.fnc_StripCommentsFromSQLString(@Text1))
Set @text2 =(select dbo.fnc_StripCommentsFromSQLString(@Text2))
Set @text3 =(select dbo.fnc_StripCommentsFromSQLString(@Text3))
Set @text1_5 =(select dbo.fnc_StripCommentsFromSQLString(@Text1_5))
Set @text2_5 =(select dbo.fnc_StripCommentsFromSQLString(@Text2_5))
*/

Set @text1 =(select dbo.fnc_StripCommentsFromSQLString(@Text1))
Set @text1 =Replace(@text1,char(13),' ')
Set @text1 =Replace(@text1,char(10),' ')
Set @i=CharIndex(@ParameterName,@text1,1)
--Select @i,@ParameterName,@text1

Set @work=''
Set @QuoteDelimiterFound=0
If @i>0 
BEGIN
	Set @i=@i +LEN(@ParameterName)
	While @i< Len(@Text1)
	BEGIN
		IF (ASCII(Substring(@text1,@i,1)) =44)  BREAK	
		If Substring(@text1,@i,1)='='
		BEGIN
			Set @I=@i+1
			If @i>= Len(@Text1) BREAK
			WHILE 1=1
			BEGIN
				
				IF ASCII(Substring(@text1,@i,1)) <32 BREAK
				IF ( (ASCII(Substring(@text1,@i,1)) =34) or (ASCII(Substring(@text1,@i,1)) =39) )
				BEGIN
					IF @QuoteDelimiterFound<>0 
						BEGIN
							IF (@QuoteDelimiterFound=ASCII(Substring(@text1,@i,1)))
							BEGIN
								Set @work=@work + Substring(@text1,@i,1)
								BReAK
							END
						END
					ELSE Set @QuoteDelimiterFound=ASCII(Substring(@text1,@i,1))
				
				END
				IF ( (@QuoteDelimiterFound=0) and  (ASCII(Substring(@text1,@i,1)) =44) ) BREAK	--comma
				IF ( (@QuoteDelimiterFound=0) and  (ASCII(Substring(@text1,@i,1)) =41) ) BREAK	--()
				IF ( (@QuoteDelimiterFound=0) and  (ASCII(Substring(@text1,@i,1)) =40) ) BREAK	--()
				IF ( (@QuoteDelimiterFound=0) and  (ASCII(Substring(@text1,@i,1)) =32) AND (LEN(@WORK)>1) ) BREAK	
				
				Set @work=@work + Substring(@text1,@i,1)	
				IF ( (@QuoteDelimiterFound=0) )
				begin
					Set @Work =ltrim(RTRIM(Left(@work,80)))
				END
				Set @I=@i+1
				If @i>= Len(@Text1) BREAK
			END
			BREAK
		END
		Set @I=@i+1
	END
END
--Select @work

Set @R =ltrim(RTRIM(Left(@work,80)))
Return @R 
END

GO
GRANT EXECUTE ON  [dbo].[fnc_GetDefaultValueForParmeterForStoredProc] TO [public]
GO
