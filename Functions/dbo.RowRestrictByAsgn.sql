SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RowRestrictByAsgn]
	(
	@asgn_type	as varchar (6),
	@asgn_id	as varchar (13)
	)
RETURNS int
AS
BEGIN
	DECLARE @Result			int,
			@rowsecurity	char(1)

	SET @Result = 1 
	SELECT @rowsecurity = gi_string1
	FROM generalinfo 
	WHERE gi_name = 'RowSecurity'

	IF @rowsecurity = 'Y' BEGIN
		IF @asgn_type = 'DRV' BEGIN
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510
			--SET @Result = (SELECT dbo.RowRestrictByUser (mpp_terminal, '', '', '')
			SET @Result = (SELECT dbo.RowRestrictByUser ('manpowerprofile', rowsec_rsrv_id, '', '', '')
							FROM manpowerprofile 
							WHERE mpp_id = @asgn_id)
		END
		ELSE IF @asgn_type = 'TRC' BEGIN
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510
			--SET @Result = (SELECT dbo.RowRestrictByUser (trc_terminal, '', '', '')
			SET @Result = (SELECT dbo.RowRestrictByUser ('tractorprofile', rowsec_rsrv_id, '', '', '')
							FROM tractorprofile 
							WHERE trc_number = @asgn_id)
		END
		ELSE IF @asgn_type = 'TRL' BEGIN
			--PTS 38816 JJF 20080312 add additional needed parms
			--PTS 51570 JJF 20100510
			--SET @Result = COALESCE ((SELECT dbo.RowRestrictByUser (trl_terminal, '', '', '')
			SET @Result = COALESCE ((SELECT dbo.RowRestrictByUser ('trailerprofile', rowsec_rsrv_id, '', '', '')
							FROM trailerprofile 
							WHERE trl_number = @asgn_id
							AND trl_ilt = 'N'), 1)
		END
		--PTS 51570 JJF 20100510
		ELSE IF @asgn_type = 'CAR' BEGIN
			SET @Result = (SELECT dbo.RowRestrictByUser ('carrier', rowsec_rsrv_id, '', '', '')
							FROM carrier
							WHERE car_id = @asgn_id)
		END
		ELSE BEGIN
			SET @Result = 1
		END
	END
	RETURN @Result
END
GO
GRANT EXECUTE ON  [dbo].[RowRestrictByAsgn] TO [public]
GO
