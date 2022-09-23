SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RowRestrictByUser]
(
	--PTS 51570 JJF 20100427
	--@usr_type1	as varchar(6),
	@TableName  varchar(50),
	@BelongsTo  int,
	--END PTS 51570 JJF 20100427
	@itemvalue	as varchar(254),
	@generalinfosettingname	as varchar(254),
	@parmlist	as varchar(254)
)
RETURNS int
AS
/**
 * 
 * NAME:
 * dbo.RowRestrictByUser
 *
 * TYPE:
 * UDF
 *
 * DESCRIPTION:
 * Validates passed in user type value with user types allowed for the user
 * 
 *
 * RETURNS:
 * 0: Does not pass test
 * 1: Passes test
 * RESULT SETS: 
 * None
 *
  * 
 * REVISION HISTORY:
 * 20071206 JJF PTS 40136 Initial creation
 *
 **/

BEGIN
	DECLARE @Result			int,
			@rowsecurity	char(1),
			@RowSecurityCustom char(1),
			@tmwuser 		varchar(255),
			--PTS 38816 JJF 20080310
			@proctocall varchar(255)
			--END PTS 38816 JJF 20080310

	
	SELECT @rowsecurity = gi_string1
	FROM generalinfo 
	WHERE gi_name = 'RowSecurity'

	--PTS 56468 JJF 20110331 
	--IF @rowsecurity = 'Y' BEGIN
	IF (@rowsecurity = 'Y') AND (ISNULL(@BelongsTo, 0) > 0) BEGIN
	--END PTS 56468 JJF 20110331 
		--PTS 51570 JJF 20100427
		--IF @usr_type1 = 'UNK' BEGIN
		--	SET @Result = 1
		--END
		--ELSE BEGIN
		--END PTS 51570 JJF 20100427
			exec @tmwuser = dbo.gettmwuser_fn

			
			--PTS 51570 JJF 20100427
			
			IF EXISTS	(	SELECT	* 
							FROM	RowRestrictValidAssignments_fn(@TableName) r
							WHERE	r.rowsec_rsrv_id = @BelongsTo or r.rowsec_rsrv_id = 0
						) BEGIN
				SET @Result = 1
			END 
			ELSE BEGIN
				SET @Result = 0
			END
			--END
			--IF NOT EXISTS(SELECT * 
			--					FROM UserTypeAssignment
			--					WHERE usr_userid = @tmwuser) BEGIN
			--	SET @Result = 1
			--END
			--ELSE IF EXISTS(SELECT * 
			--			FROM UserTypeAssignment
			--			WHERE usr_userid = @tmwuser
			--					and (uta_type1 = @usr_type1 
			--							or uta_type1 = 'UNK')) BEGIN
			--	SET @Result = 1	
			--END
			--ELSE BEGIN
			--	SET @Result = 0
			--END
			--END PTS 51570 JJF 20100427
		--PTS 51570 JJF 20100427
		--END
		--END PTS 51570 JJF 20100427
	END
	ELSE BEGIN
		SET @Result = 1	
	END

	--PTS 38816 JJF 20080310
	SELECT @RowSecurityCustom = gi_string1
	FROM generalinfo 
	WHERE gi_name = 'RowSecurityCustom'

	IF @RowSecurityCustom = 'Y' BEGIN
		IF @Result = 1 BEGIN
			--See if there's another function to call for custom security
			SELECT @proctocall = IsNull(gi_string2, '')
			FROM generalinfo
			WHERE gi_name = @generalinfosettingname

			If @proctocall > ''	and @parmlist > '' BEGIN
				exec @Result = @proctocall @itemvalue, @generalinfosettingname, @parmlist
			END
		END
	END 
	--END PTS 38816 JJF 20080310

	RETURN @Result
END
GO
GRANT EXECUTE ON  [dbo].[RowRestrictByUser] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowRestrictByUser] TO [public]
GO
