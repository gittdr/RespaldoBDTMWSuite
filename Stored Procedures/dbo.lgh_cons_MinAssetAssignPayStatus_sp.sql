SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_MinAssetAssignPayStatus_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for MinAssetAssignPayStatus GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/

DECLARE @changecount INT
	,@donotpay_status AS VARCHAR(6)
	,@donotpay_type AS VARCHAR(6)
	,@donotpay_field AS VARCHAR(20)


/* PTS 31021 - DJM - Set the Pay Status to the specified code if the specified condition exists    */


  SELECT 
    @donotpay_status = gi_string1
  , @donotpay_type = gi_string2
  , @donotpay_field = gi_string3
  FROM 
    dbo.generalinfo 
  WHERE 
    gi_name = 'MinAssetAssignPayStatus';

BEGIN

  /* Check for changes to the proper lgh_type field    */
  IF @donotpay_field = 'lgh_type1'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(d.lgh_type1,'ZZZ') <> @donotpay_type
        AND 
      i.lgh_type1 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type2'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(d.lgh_type2,'ZZZ') <> @donotpay_type
        AND 
      i.lgh_type2 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type3'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(d.lgh_type3,'ZZZ') <> @donotpay_type
        AND 
      i.lgh_type3 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type4'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(d.lgh_type4,'ZZZ') <> @donotpay_type
        AND 
      i.lgh_type4 = @donotpay_type;
  END;
  
  
  
  IF @changecount > 0
  BEGIN
    /* Set the Asset Assignment status to the non-payable status for all the
      AssetAssignment records of the Leg that are not already paid    */
  
    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      @inserted i
    WHERE 
      assetassignment.asgn_type = 'DRV'
        AND 
      assetassignment.pyd_status NOT IN ('PPD', @donotpay_status)
        AND 
      assetassignment.asgn_id IN (i.lgh_driver1, i.lgh_driver2)
        AND 
      assetassignment.lgh_number = i.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN i.lgh_type1
                         WHEN 'lgh_type2' THEN i.lgh_type2
                         WHEN 'lgh_type3' THEN i.lgh_type3
                         WHEN 'lgh_type4' THEN i.lgh_type4
                       END
        AND 
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );
    

 
    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      @inserted i
    WHERE 
      assetassignment.asgn_type = 'TRC'
        AND 
      assetassignment.pyd_status NOT IN ('PPD', @donotpay_status)
        AND 
      assetassignment.asgn_id = i.lgh_tractor
        AND 
      assetassignment.lgh_number = i.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN i.lgh_type1
                         WHEN 'lgh_type2' THEN i.lgh_type2
                         WHEN 'lgh_type3' THEN i.lgh_type3
                         WHEN 'lgh_type4' THEN i.lgh_type4
                       END
        AND 
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      @inserted i
    WHERE 
      assetassignment.asgn_type = 'TRL'
        AND 
      assetassignment.pyd_status NOT IN ('PPD', @donotpay_status)
        AND 
      assetassignment.asgn_id IN (i.lgh_primary_trailer, i.lgh_primary_pup)
        AND 
      assetassignment.lgh_number = i.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN i.lgh_type1
                         WHEN 'lgh_type2' THEN i.lgh_type2
                         WHEN 'lgh_type3' THEN i.lgh_type3
                         WHEN 'lgh_type4' THEN i.lgh_type4
                       END
        AND 
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

     
    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = @donotpay_status
    FROM 
      @inserted i
    WHERE 
      assetassignment.asgn_type = 'CAR'
        AND 
      assetassignment.pyd_status NOT IN ('PPD', @donotpay_status)
        AND 
      assetassignment.asgn_id = i.lgh_carrier
        AND 
      assetassignment.lgh_number = i.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN i.lgh_type1
                         WHEN 'lgh_type2' THEN i.lgh_type2
                         WHEN 'lgh_type3' THEN i.lgh_type3
                         WHEN 'lgh_type4' THEN i.lgh_type4
                       END
        AND 
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

  END;--IF @changecount > 0

        
  /* Set the Asset Assignement status to NPD if the lgh_type1 status
    is changed to a status that should allow the Trip Segment to be paid.  */
  IF @donotpay_field = 'lgh_type1'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(i.lgh_type1,'ZZZ') <> @donotpay_type
        AND 
      d.lgh_type1 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type2'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(i.lgh_type2,'ZZZ') <> @donotpay_type
        AND 
      d.lgh_type2 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type3'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(i.lgh_type3,'ZZZ') <> @donotpay_type
        AND 
      d.lgh_type3 = @donotpay_type;
  END;
  ELSE IF @donotpay_field = 'lgh_type4'
  BEGIN
    SELECT 
      @changecount = COUNT(*) 
    FROM 
      @inserted i 
        INNER JOIN 
      @deleted d ON i.lgh_number = d.lgh_number 
    WHERE 
      ISNULL(i.lgh_type3,'ZZZ') <> @donotpay_type
        AND 
      d.lgh_type3 = @donotpay_type;
  END;

  IF @changecount > 0 
  BEGIN
    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = 'NPD'
    FROM 
      @deleted d
    WHERE 
      assetassignment.asgn_type = 'DRV'
        AND 
      assetassignment.asgn_id IN(d.lgh_driver1, d.lgh_driver2)
        AND 
      assetassignment.lgh_number = d.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN d.lgh_type1
                         WHEN 'lgh_type2' THEN d.lgh_type2
                         WHEN 'lgh_type3' THEN d.lgh_type3
                         WHEN 'lgh_type4' THEN d.lgh_type4
                       END
        AND  --if it was somehow already paid let's not set ourselves up to pay it again!
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );
    

    
    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = 'NPD'
    FROM 
      @deleted d
    WHERE 
      assetassignment.asgn_type = 'TRC'
        AND 
      assetassignment.asgn_id = d.lgh_tractor
        AND 
      assetassignment.lgh_number = d.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN d.lgh_type1
                         WHEN 'lgh_type2' THEN d.lgh_type2
                         WHEN 'lgh_type3' THEN d.lgh_type3
                         WHEN 'lgh_type4' THEN d.lgh_type4
                       END
        AND  --if it was somehow already paid let's not set ourselves up to pay it again!
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = 'NPD'
    FROM 
      @deleted d
    WHERE 
      assetassignment.asgn_type = 'TRL'
        AND 
      assetassignment.asgn_id IN (d.lgh_primary_trailer, d.lgh_primary_pup)
        AND 
      assetassignment.lgh_number = d.lgh_number
        AND 
      @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN d.lgh_type1
                         WHEN 'lgh_type2' THEN d.lgh_type2
                         WHEN 'lgh_type3' THEN d.lgh_type3
                         WHEN 'lgh_type4' THEN d.lgh_type4
                       END
        AND  --if it was somehow already paid let's not set ourselves up to pay it again!
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

    UPDATE 
      dbo.AssetAssignment
    SET 
      pyd_status = 'NPD'
    FROM 
      @deleted d
    WHERE 
      assetassignment.asgn_type = 'CAR'
        AND 
      assetassignment.asgn_id = d.lgh_carrier
        AND 
      assetassignment.lgh_number = d.lgh_number
        AND 
     @donotpay_type = CASE @donotpay_field 
                         WHEN 'lgh_type1' THEN d.lgh_type1
                         WHEN 'lgh_type2' THEN d.lgh_type2
                         WHEN 'lgh_type3' THEN d.lgh_type3
                         WHEN 'lgh_type4' THEN d.lgh_type4
                       END
        AND  --if it was somehow already paid let's not set ourselves up to pay it again!
      assetassignment.asgn_number NOT IN (SELECT p.asgn_number FROM dbo.paydetail p WHERE p.asgn_number = AssetAssignment.asgn_number AND p.asgn_number > 0 );

  END;--IF @changecount > 0 
END;--IF EXISTS (SELECT gi_string1 FROM @GIKEY WHERE gi_name = 'MinAssetAssignPayCode' AND gi_string1 ='Y')


GO
GRANT EXECUTE ON  [dbo].[lgh_cons_MinAssetAssignPayStatus_sp] TO [public]
GO
