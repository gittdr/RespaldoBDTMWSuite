SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_tmtrcchange_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
  ,@TMailTRCChangeFormID VARCHAR(30)
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			        Handle logic for TMailTRCChangeFormID GI setttings that are used in	ut_legheader_consolidated.
********************************************************************************************************************/
  
BEGIN

DECLARE @ord INT
	,@lgh INT
	,@trc VARCHAR(8)
	,@IDENT2 INT
  
  SELECT   
    @ord = i.ord_hdrnumber
  , @lgh = i.lgh_number
  , @trc = d.lgh_tractor
  FROM 
    @inserted i
      INNER JOIN
    @deleted d ON i.lgh_number = d.lgh_number
  WHERE
    i.lgh_dsp_date IS NOT NULL
      AND
    d.lgh_outstatus IN ('DSP','STD')
      AND
    (  COALESCE(i.lgh_outstatus, '') IN ('CAN','AVL') --canceled;
          OR    
        i.lgh_tractor <> d.lgh_tractor
    )

  IF @@ROWCOUNT = 1
  BEGIN
    INSERT dbo.TMSQLMessage (
      msg_date
    , msg_FormID
    , msg_To
    , msg_ToType
    , msg_FilterData
    , msg_FilterDataDupWaitSeconds
    , msg_From
    , msg_FromType
    , msg_Subject)
    VALUES (
      GETDATE()
    , @TMailTRCChangeFormID
    , @trc
    , 4 --type 4 tractor
    , @trc+CONVERT(VARCHAR(5),@TMailTRCChangeFormID)+CONVERT(VARCHAR(15),@lgh) --filter duplicate rows
    , 30 --wait 30 seconds
    , SUSER_NAME()
    , 0 --0 who knows
    , 'Trip Assignment Changed');
      
    SET @IDENT2 = SCOPE_IDENTITY();--pts 73672

    INSERT dbo.TMSQLMessageData (
      msg_ID
    , msd_Seq
    , msd_FieldName
    , msd_FieldValue)
    VALUES (
      @IDENT2
    , 1
    , 'lgh_number'
    , @lgh);
      
    INSERT dbo.TMSQLMessageData (
      msg_ID
    , msd_Seq
    , msd_FieldName
    , msd_FieldValue)
    VALUES (
      @IDENT2
    , 1
    , 'Field01'
    , @ord);

    INSERT dbo.TMSQLMessageData (
      msg_ID
    , msd_Seq
    , msd_FieldName
    , msd_FieldValue)
    VALUES (
      @IDENT2
    , 1
    , 'ord_number'
    , @ord);
  END;   

END;
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_tmtrcchange_sp] TO [public]
GO
