SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--Intended to take a query parameter (@parmvalue) in the form of A or A,B,C or ,A,B,C,
--Parameters are expected to be strings, such that they can be expressed in an in clause as IN('A', 'B', 'C')
--@Parmname is a parameter name to place in the expression if there's only one value in @parm.  A parameter is invalid in the IN clause.
--@Parmname can be blank, in which case the string in @parmvalue will be used.
--Also accepts a wildcard (UNK, ALL).  @ParmValue must include ONLY the wildcard in order it to consider it a match

--Returns '' if no condition is needed (matches wildcard or is empty)
--Otherwise returns ' IN 'DDD','EEE' or = 'DDD', depending on the number of comma separated parameters
--If ParmName is specified, " IN 'DDD','EEE'" or " = @SomeParmName" will be returned

--Typical usage:  select @sql = @sql + SELECT @sql = @sql + dbo.EquateCondition('and trl.trl_type1', '', @p_trlstatus, 'UNK')

CREATE  FUNCTION [dbo].[EquateCondition]	(		@Condition varchar(1024),
												@ParmName varchar(1024), 
												@ParmValue varchar(1024),
												@Wildcard varchar(8)
										)
RETURNS  NVARCHAR(1024)

AS BEGIN
	DECLARE @sql nvarchar(1024) 
	
	SET @sql = ''
	
	SELECT @ParmValue = REPLACE(@ParmValue,' ','')

	--If parameter leads with delimiter, remove it
	IF LEFT(@ParmValue, 1) = ',' BEGIN
		SELECT @ParmValue = SUBSTRING(@ParmValue, 2, LEN(@ParmValue))
	END
	IF RIGHT(@ParmValue, 1) = ',' BEGIN
		SELECT @ParmValue = SUBSTRING(@ParmValue, 1, LEN(@ParmValue) -	1)
	END 

	--If any parms themselves contain a single quote, double it	
	SELECT @ParmValue = REPLACE(@ParmValue, '''', '''''')		
	
	IF ISNULL(@ParmValue, '') <> '' AND @ParmValue <> ISNULL(@Wildcard, '') BEGIN
		IF CHARINDEX(',', @ParmValue) > 0 BEGIN --has more than one value, use IN
			--put double quotes around both sides of comma
			SELECT @ParmValue = REPLACE(@ParmValue,',',''',''')
			SELECT @sql = N' IN (''' + @ParmValue + ''') '
		END
		ELSE BEGIN --only has one value, use an = sign.
			IF LEN(ISNULL(@ParmName, '')) > 0 BEGIN
				SELECT @sql = N' = ' + @ParmName  
			END
			ELSE BEGIN
				SELECT @sql = N' = ''' + @ParmValue + ''' '
			END
		END
	END
	
	IF LEN(@sql) > 0 BEGIN
		SELECT @Sql = @Condition + @Sql
	END

	RETURN @sql
END
GO
GRANT EXECUTE ON  [dbo].[EquateCondition] TO [public]
GO
