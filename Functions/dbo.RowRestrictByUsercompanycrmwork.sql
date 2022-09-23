SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RowRestrictByUsercompanycrmwork]
(
	--PTS 51570 JJF 20100510
	--@usr_type1	as	varchar(6),
	@rowsec_rsrv_id	as	int,
	@cmp_billto as	char(1)
)
RETURNS int
--0 restrict
--1 ok
--2 read only 
AS
/**
 * 
 * NAME:
 * dbo.RowRestrictByUsercompanycrmwork
 *
 * TYPE:
 * UDF
 *
 * DESCRIPTION:
 * Validates passed in user type value with user types allowed for the user
 * Intended to be used for companycrmwork lookups.  If the  companycrmwork being tested is a bill to, then an additional return of 2 read only indicates the user does not have rights to modify, but can read.
 *
 * RETURNS:
 * 0 restrict
 * 1 ok
 * 2 read only 
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
			@tmwuser 		varchar(255)

	--IF @usr_type1 = 'UNK' BEGIN
	--	SET @Result = 1
	--END
	--ELSE BEGIN
	--	SELECT @rowsecurity = gi_string1
	--	FROM generalinfo 
	--	WHERE gi_name = 'RowSecurity'

	--	IF @rowsecurity = 'Y' BEGIN
	--		--PTS 41877
	--		--SELECT @tmwuser = suser_sname()
	--		exec @tmwuser = dbo.gettmwuser_fn

	--		IF NOT EXISTS(SELECT * 
	--							FROM UserTypeAssignment
	--							WHERE usr_userid = @tmwuser) BEGIN
	--			SET @Result = 1
	--		END
	--		ELSE IF EXISTS(SELECT * 
	--					FROM UserTypeAssignment
	--					WHERE usr_userid = @tmwuser
	--							and (uta_type1 = @usr_type1 
	--									or uta_type1 = 'UNK')) BEGIN
	--			SET @Result = 1	
	--		END
	--		ELSE BEGIN
	--			IF @cmp_billto = 'Y' BEGIN
	--				SET @Result = 2		--signifies readonly
	--			END
	--			ELSE BEGIN
	--				SET @Result = 0
	--			END
	--		END
	--	END
	--	ELSE BEGIN
	--		SET @Result = 1
	--	END
	--END
	--RETURN @Result

	IF isnull(@rowsec_rsrv_id, '') = '' BEGIN
		SET @Result = 1
	END
	ELSE BEGIN
		SELECT @rowsecurity = gi_string1
		FROM generalinfo 
		WHERE gi_name = 'RowSecurity'

		IF @rowsecurity = 'Y' BEGIN
			IF EXISTS	(	SELECT	* 
							FROM	RowRestrictValidAssignments_companycrmwork_fn() r
							WHERE	r.rowsec_rsrv_id = @rowsec_rsrv_id or r.rowsec_rsrv_id = 0
						) BEGIN
				SET @Result = 1
			END 
			ELSE BEGIN
				IF @cmp_billto = 'Y' BEGIN
					SET @Result = 2		--signifies readonly
				END
				ELSE BEGIN
					SET @Result = 0
				END
			END
		END
		ELSE BEGIN
			SET @Result = 1
		END
	END
	RETURN @Result
END
GO
GRANT EXECUTE ON  [dbo].[RowRestrictByUsercompanycrmwork] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowRestrictByUsercompanycrmwork] TO [public]
GO
