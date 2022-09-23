SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RowRestrictByUserMultiple]
(
	
	@usr_type1	as varchar(1000),
	@itemvalue	as varchar(254),
	@generalinfosettingname	as varchar(254),
	@parmlist	as varchar(254)
)
RETURNS int
AS
/**
 * 
 * NAME:
 * dbo.RowRestrictByUserMultiple
 *
 * TYPE:
 * UDF
 *
 * DESCRIPTION:
 * Validates passed in user type values (comma separated list) with user types allowed for the user
 * If any match, pass test.  If none match, do not pass test.
 *
 * RETURNS:
 * 0: Does not pass test
 * 1: Passes test
 * RESULT SETS: 
 * None
 *
  * 
 * REVISION HISTORY:
 * 20090521 vjh PTS 47312 Initial creation
 *
 **/

--PTS 51570 JJF 20100510 - deprecated.  Do not use.

BEGIN
	RETURN 1
	
--	DECLARE @Result			int,
--			@rowsecurity	char(1),
--			@parm			varchar(1000),
--			@sub			varchar(20),
--			@cidx			integer
--	
--	SELECT @rowsecurity = gi_string1
--	FROM generalinfo 
--	WHERE gi_name = 'RowSecurity'
--
--	IF @rowsecurity = 'Y' BEGIN
--		IF @usr_type1 = 'UNK' BEGIN
--			SET @Result = 1
--		END
--		ELSE BEGIN
--			SET @Result = 0	
--			select @parm = @usr_type1
--			while @parm <> ''  and @result = 0 begin
--				select @cidx = charindex(',',@parm)
--				if @cidx = 0 begin
--					select @sub = @parm
--					select @parm = ''
--				end else begin
--					select @sub = left(@parm,@cidx-1)
--					select @parm = right(@parm,len(@parm) - @cidx)
--				end
--				select @sub = rtrim(ltrim(@sub))
--				if dbo.RowRestrictByUser(@sub, @itemvalue, @generalinfosettingname, @parmlist) = 1 set @result = 1
--			end
--		END
--	END
--	ELSE BEGIN
--		SET @Result = 1	
--	END
--
--
--
--	RETURN @Result
END
GO
GRANT EXECUTE ON  [dbo].[RowRestrictByUserMultiple] TO [public]
GO
