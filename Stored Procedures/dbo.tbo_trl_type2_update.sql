SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tbo_trl_type2_update] (
	@p_trl	VARCHAR(13))
AS
/**
 * 
 * NAME:
 * dbo.tbo_trl_type2_update
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is to update trailer type 2 based on TBO requests that are open
 *
 * PARAMETERS:
 * 001 - @p_trl, varchar(13)
 *       This parameter indicates the trailer number to be updated 
 * REVISION HISTORY:
 * 11/13/2006 ? PTS33640 - Ron Eyink ? Original version
 *
 **/
BEGIN
	IF EXISTS(SELECT	*
			    FROM	tborequest
			   WHERE	tbo_trlid = @p_trl AND
						tbo_jobcode = 'TB1' AND
						ISNULL(tbo_completed, 'N') = 'N')
	BEGIN
		UPDATE	trailerprofile
		   SET	trl_type2 = 'UNLD'
		 WHERE	trl_id = @p_trl AND
				ISNULL(trl_type2, 'UNK') <> 'UNLD'
	END
	ELSE
	BEGIN
		UPDATE	trailerprofile
		   SET	trl_type2 = 'LD'
		 WHERE	trl_id = @p_trl AND
				ISNULL(trl_type2, 'UNK') <> 'LD'
	END
END
GO
GRANT EXECUTE ON  [dbo].[tbo_trl_type2_update] TO [public]
GO
