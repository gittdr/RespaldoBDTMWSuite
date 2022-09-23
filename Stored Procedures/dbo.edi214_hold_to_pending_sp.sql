SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi214_hold_to_pending_sp] @stp_num int, @activity varchar(6)

/* 
  7/08/05 AROSS: Stored procedure to move records from pending_hold table to the edi_214_pending table
  		After update to missing data item.
  		
*/

AS



		INSERT INTO edi_214_pending(
			e214p_ord_hdrnumber,
			e214p_billto,
			e214p_level,
			e214p_ps_status,
			e214p_stp_number,
			e214p_dttm,
			e214p_activity,
			e214p_arrive_earlyorlate,
			e214p_depart_earlyorlate,
			e214p_stpsequence,
			e214p_consolidation,
			ckc_number,
			e214p_firstlastflags,
			e214p_created,
			e214p_ReplicateForEachDropFlag,
			e214p_source,
			e214p_user)
			
		SELECT e214ph_ord_hdrnumber,
		       e214ph_billto,
		       e214ph_level,
		       e214ph_ps_status,
		       @stp_num,
		       e214ph_dttm,
		       @activity,
		       e214ph_arrive_earlyorlate,
		       e214ph_depart_earlyorlate,
		       e214ph_stpsequence,
		       e214ph_consolidation,
		       ckc_number,
		       e214ph_firstlastflags,
		       Getdate(),
		       'N',
			   e214ph_source,
			   e214ph_user
		FROM 	edi_214_pending_hold with(nolock)
		WHERE 	e214ph_stp_number = @stp_num
			AND e214ph_activity = @activity
			
--Remove the record from the pending_hold table
Delete from edi_214_pending_hold where e214ph_stp_number = @stp_num and e214ph_activity = @activity
				
GO
GRANT EXECUTE ON  [dbo].[edi214_hold_to_pending_sp] TO [public]
GO
