SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_TMCancelOrderFormId_sp] (
	@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
  ,@TMailTRCChangeFormID INT
	
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			          Handle logic for TMCancelOrderFormId GI setttings that are used in ut_legheader_consolidated.
********************************************************************************************************************/
-- Send the Cancel Order message to the driver if set up to do so.
BEGIN
	DECLARE	@lgh_number INT,
					@lgh_tractor VARCHAR(8),
					@ord_number VARCHAR(12),
					@msg_id	INT

	DECLARE LegCursor CURSOR LOCAL FAST_FORWARD FOR
	SELECT	d.lgh_number,
						d.lgh_tractor,
						d.ord_number
		FROM	@inserted i
								INNER JOIN @deleted d ON d.lgh_number = i.lgh_number
		WHERE	ISNULL(d.lgh_tm_status, 'NOSENT') <> 'NOSENT'
			AND	(d.lgh_tractor <> i.lgh_tractor OR d.lgh_driver1 <> i.lgh_driver1)
			AND	i.lgh_outstatus IN ('AVL', 'PLN', 'DSP')
			AND i.lgh_tractor <> ''
			AND d.lgh_tractor <> 'UNKNOWN';

	OPEN LegCursor;

	FETCH NEXT FROM LegCursor		
		INTO @lgh_number,
				 @lgh_tractor,
				 @ord_number
		
WHILE @@FETCH_STATUS = 0		
BEGIN			
	INSERT dbo.TMSQLMessage (
		msg_date
		,msg_FormID
		,msg_To
		,msg_ToType
		,msg_FilterData
		,msg_FilterDataDupWaitSeconds
		,msg_From
		,msg_FromType
		,msg_Subject
		)
	SELECT GETDATE()
		,@TMailTRCChangeFormID
		,@lgh_tractor
		,4 --type 4 tractor
		,@lgh_tractor + CONVERT(VARCHAR(5), @TMailTRCChangeFormID) + CONVERT(VARCHAR(15), @ord_number) --filter duplicate rows
		,30 --wait 30 seconds
		,SUSER_NAME()
		,0 --0 who knows
		,'CANCEL ORDER (ORD: ' + @ord_number + ')'

	SELECT @msg_id = SCOPE_IDENTITY()

	INSERT dbo.TMSQLMessageData (
		msg_ID
		,msd_Seq
		,msd_FieldName
		,msd_FieldValue
		)
	SELECT @msg_ID
		,1
		,'ord_number'
		,@ord_number;

	INSERT dbo.TMSQLMessageData (
		msg_ID
		,msd_Seq
		,msd_FieldName
		,msd_FieldValue
		)
	SELECT @msg_ID
		,1
		,'Field01'
		,@ord_number

	INSERT dbo.TMSQLMessageData (
		msg_ID
		,msd_Seq
		,msd_FieldName
		,msd_FieldValue
		)
	SELECT @msg_ID
		,1
		,'lgh_number'
		,@lgh_number

	FETCH NEXT FROM LegCursor		
		INTO @lgh_number,
				 @lgh_tractor,
				 @ord_number
	END
END;--IF @TMailTRCChangeFormID > 0 AND EXISTS(SELECT TOP 1 1 FROm @LegTMStatus WHERE lgh_tractor <> '')

CLOSE LegCursor;

DEALLOCATE LegCursor;

GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_TMCancelOrderFormId_sp] TO [public]
GO
