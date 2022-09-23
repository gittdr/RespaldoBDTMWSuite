SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[UtStopsConsolidated_TMailChangeForms_sp]
(
  @inserted UtStopsConsolidated READONLY,
  @deleted  UtStopsConsolidated READONLY,
  @tmwuser  VARCHAR(255),
  @GETDATE  DATETIME,
  @TMailStopChangeFormID  INTEGER,
  @TMailDateChangeFormID     INTEGER
)
AS

DECLARE @OutputTable TABLE
  (
    msg_FilterData  VARCHAR(254),
    msg_To          VARCHAR(100),
    msg_ID          INTEGER,
    msg_FormID      INTEGER
  );

INSERT INTO TMSQLMessage
  (
    msg_date,
    msg_FormID,
    msg_To,
    msg_ToType, 
    msg_FilterData,
    msg_FilterDataDupWaitSeconds,
    msg_From,
    msg_FromType,
    msg_Subject
  )
  OUTPUT inserted.msg_FilterData, inserted.msg_To, inserted.msg_ID, inserted.msg_FormID INTO @OutputTable
  SELECT  @GETDATE,
          CASE
            WHEN i.cmp_id <> d.cmp_id THEN @TMailStopChangeFormID
            WHEN i.stp_schdtearliest <> d.stp_schdtearliest OR i.stp_schdtlatest <> d.stp_schdtlatest THEN @TMailDateChangeFormID
          END,
          lgh.lgh_tractor,
          4,
          lgh.lgh_tractor + CONVERT(VARCHAR(5), CASE
                                                  WHEN i.cmp_id <> d.cmp_id THEN @TMailStopChangeFormID
                                                  WHEN i.stp_schdtearliest <> d.stp_schdtearliest OR i.stp_schdtlatest <> d.stp_schdtlatest THEN @TMailDateChangeFormID
                                                END) + CONVERT(VARCHAR(15), CASE
                                                                              WHEN i.cmp_id <> d.cmp_id THEN i.lgh_number
                                                                              WHEN i.stp_schdtearliest <> d.stp_schdtearliest OR i.stp_schdtlatest <> d.stp_schdtlatest THEN i.stp_number
                                                                            END),
          30,
          @tmwuser,
          0,
          CASE
            WHEN i.cmp_id <> d.cmp_id THEN 'Stop Information Change'
            WHEN i.stp_schdtearliest <> d.stp_schdtearliest OR i.stp_schdtlatest <> d.stp_schdtlatest THEN 'Stop Date Time Change'
          END
    FROM  @inserted i
            INNER JOIN @deleted d ON d.stp_number = i.stp_number
            INNER JOIN legheader lgh WITH(NOLOCK) ON lgh.lgh_number = i.lgh_number
   WHERE  i.stp_type IN ('PUP', 'DRP')
     AND  lgh.lgh_tractor <> 'UNKNOWN'
     AND  lgh.lgh_outstatus NOT IN ('AVL', 'CMP', 'PLN')
     AND  lgh_dsp_date IS NOT NULL
     AND  ((i.cmp_id <> d.cmp_id AND @TMailStopChangeFormID <> 0)
      OR   ((i.stp_schdtearliest <> d.stp_schdtearliest
      OR     i.stp_schdtlatest <> d.stp_schdtlatest)
     AND    @TMailDateChangeFormID <> 0));

    INSERT INTO dbo.TMSQLMessageData 
      (
        msg_ID,
        msd_Seq,
        msd_FieldName,
        msd_FieldValue
      )
      SELECT  msg_ID,
              1,
              CASE msg_FormID
                WHEN @TMailStopChangeFormID THEN 'lgh_number'
                WHEN @TMailDateChangeFormID THEN 'StopNumber'
              END,
              RIGHT(msg_FilterData, LEN(msg_FilterData) - LEN(CAST(msg_FormID AS VARCHAR(5))) - LEN(msg_To))
    FROM
      @OutputTable;
GO
GRANT EXECUTE ON  [dbo].[UtStopsConsolidated_TMailChangeForms_sp] TO [public]
GO
