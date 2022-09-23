SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_TrlComntsResetStatus_sp] (
@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY

	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			          Handle logic for TrailerCommentsResetStatus GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/
BEGIN
  UPDATE 
    dbo.trailerprofile
  SET 
    trl_worksheet_comment1 = NULL
  , trl_worksheet_comment2 = NULL
  FROM
    @inserted i
      INNER JOIN
    @deleted d ON i.lgh_number = d.lgh_number 
      CROSS JOIN
    generalinfo g 
  WHERE 
    trailerprofile.trl_id IN (i.lgh_primary_trailer, i.lgh_primary_pup) 
      AND
    trailerprofile.trl_id <> 'UNKNOWN'
      AND
    i.lgh_outstatus <> COALESCE(d.lgh_outstatus, 'AVL')
      AND
    CHARINDEX(',' + i.lgh_outstatus + ',', ',' + gi_string1 + ',') > 0
      AND
    g.gi_name = 'TrailerCommentsResetStatus';
END;
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_TrlComntsResetStatus_sp] TO [public]
GO
